import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_translator_test/core/network/network_cubit.dart';
import 'package:smart_translator_test/core/network/server_health_cubit.dart';
import 'package:smart_translator_test/core/network/server_health_service.dart';
import 'package:smart_translator_test/core/storage/secure_storage_service.dart';
import 'package:smart_translator_test/features/auth/data/models/login_request.dart';
import 'package:smart_translator_test/features/auth/data/models/login_response.dart';
import 'package:smart_translator_test/features/auth/data/models/refresh_token_request.dart';
import 'package:smart_translator_test/features/auth/data/models/register_request.dart';
import 'package:smart_translator_test/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_translator_test/features/auth/presentation/controller/auth_bloc.dart';
import 'package:smart_translator_test/features/auth/presentation/pages/login_page.dart';
import 'package:smart_translator_test/features/user/data/models/user.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<LoginResponse> login(LoginRequest request) async => LoginResponse(
    token: 'token',
    refreshToken: 'refresh',
    expiresIn: 3600,
    refreshExpiresIn: 7200,
    user: null,
    roles: [],
  );

  @override
  Future<void> logout(RefreshTokenRequest request) async {}

  @override
  Future<LoginResponse> refreshToken(RefreshTokenRequest request) async =>
      LoginResponse(
        token: 'token2',
        refreshToken: 'refresh2',
        expiresIn: 3600,
        refreshExpiresIn: 7200,
        user: null,
        roles: [],
      );

  @override
  Future<User> register(RegisterRequest request) async => User(
    id: 1,
    email: 'test@example.com',
    username: 'testuser',
    enabled: true,
  );
}

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => null;

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {}

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {}
}

void main() {
  testWidgets('LoginPage renders and handles login submission', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final authRepository = FakeAuthRepository();
    final secureStorage = SecureStorageService(storage: FakeSecureStorage());
    final authBloc = AuthBloc(
      authRepository: authRepository,
      storageService: secureStorage,
    );
    final networkCubit = NetworkCubit();
    final serverHealthCubit = ServerHealthCubit(
      service: ServerHealthService(),
      networkCubit: networkCubit,
    );
    addTearDown(() {
      serverHealthCubit.close();
      authBloc.close();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<NetworkCubit>.value(value: networkCubit),
            BlocProvider<ServerHealthCubit>.value(value: serverHealthCubit),
          ],
          child: const LoginPage(),
        ),
      ),
    );

    // Verify initial UI elements
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Enter email and password
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    // Tap Login button
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verify state transitioned to loading or authenticated upon valid form submission
    expect(authBloc.state, anyOf(isA<AuthLoading>(), isA<AuthAuthenticated>()));
  });
}
