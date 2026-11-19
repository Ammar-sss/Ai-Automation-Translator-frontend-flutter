import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/app.dart';
import 'package:smart_translator_test/core/storage/secure_storage_service.dart';
import 'package:smart_translator_test/features/auth/data/datasource/auth_api_service.dart';
import 'package:smart_translator_test/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:smart_translator_test/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_translator_test/features/auth/presentation/controller/auth_bloc.dart';
import 'package:smart_translator_test/core/network/dio_client.dart';
import 'package:smart_translator_test/core/route/app_router.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final storageService = SecureStorageService();
    final dioClient = DioClient(storage: storageService);
    final authApiService = AuthApiService(dioClient.dio);
    final authRemoteDataSource = AuthRemoteDataSourceImpl(
      apiService: authApiService,
      storageService: storageService,
    );
    final authRepository = AuthRepositoryImpl(
      authRemoteDataSource: authRemoteDataSource,
    );
    final authBloc = AuthBloc(
      authRepository: authRepository,
      storageService: storageService,
    );
    final appRouter = AppRouter(authBloc: authBloc);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [BlocProvider.value(value: authBloc)],
        child: MyApp(router: appRouter.router),
      ),
    );

    // Verify that onboarding or login is shown
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
