import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_translator_test/core/storage/app_database.dart';
import 'package:smart_translator_test/core/storage/secure_storage_service.dart';
import 'package:smart_translator_test/features/auth/data/models/login_request.dart';
import 'package:smart_translator_test/features/auth/data/models/login_response.dart';
import 'package:smart_translator_test/features/auth/data/models/refresh_token_request.dart';
import 'package:smart_translator_test/features/auth/data/models/register_request.dart';
import 'package:smart_translator_test/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_translator_test/features/auth/presentation/controller/auth_bloc.dart';
import 'package:smart_translator_test/features/user/data/models/user.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart'
    as models;
import 'package:smart_translator_test/features/vocabulary/data/models/term_definitions.dart';

class FakeAuthRepository implements AuthRepository {
  bool logoutCalled = false;

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
  Future<void> logout(RefreshTokenRequest request) async {
    logoutCalled = true;
  }

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
  final Map<String, String> values = {'refresh_token': 'fake_refresh_token'};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values[key];

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
  }) async {
    if (value != null) {
      values[key] = value;
    } else {
      values.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    values.remove(key);
  }
}

void main() {
  late AppDatabase db;
  late FakeAuthRepository authRepository;
  late SecureStorageService storageService;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    authRepository = FakeAuthRepository();
    storageService = SecureStorageService(storage: FakeSecureStorage());
  });

  tearDown(() async {
    await db.close();
  });

  group('Logout Clear Database Tests', () {
    test(
      'AuthLogoutRequested clears all SQLite tables and user tokens',
      () async {
        final folderId = await db.createFolder('User A Folder');
        await db.saveTermToFolder(
          term: models.Term(
            id: 1,
            termWord: 'apple',
            termDefinitions: {TermDefinition(id: 1, definition: 'A fruit')},
            termExamples: {},
            exampleDefinitions: {},
          ),
          folderId: folderId,
        );

        // Confirm data exists prior to logout
        expect(await db.getTermsCount(), equals(1));
        final initialFolders = await db.getAllFoldersWithTermCount();
        expect(initialFolders.length, equals(1));

        final authBloc = AuthBloc(
          authRepository: authRepository,
          storageService: storageService,
          appDatabase: db,
        );

        authBloc.add(AuthLogoutRequested());
        await expectLater(
          authBloc.stream,
          emitsInOrder([isA<AuthLogoutLoading>(), isA<AuthUnAuthenticated>()]),
        );

        // Verify DB cleared
        expect(await db.getTermsCount(), equals(0));
        final postLogoutFolders = await db.getAllFoldersWithTermCount();
        expect(postLogoutFolders, isEmpty);
        expect(authRepository.logoutCalled, isTrue);
      },
    );
  });
}
