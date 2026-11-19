import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/app.dart';
import 'package:smart_translator_test/core/network/dio_client.dart';
import 'package:smart_translator_test/core/network/network_cubit.dart';
import 'package:smart_translator_test/core/network/server_health_cubit.dart';
import 'package:smart_translator_test/core/network/server_health_service.dart';
import 'package:smart_translator_test/core/route/app_router.dart';
import 'package:smart_translator_test/core/storage/secure_storage_service.dart';
import 'package:smart_translator_test/features/auth/data/datasource/auth_api_service.dart';
import 'package:smart_translator_test/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:smart_translator_test/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_translator_test/features/auth/presentation/controller/auth_bloc.dart';
import 'package:smart_translator_test/features/setting/presentation/controller/theme_cubit.dart';
import 'package:smart_translator_test/features/translate/data/datasource/translate_remote_data_source.dart';
import 'package:smart_translator_test/features/translate/data/repositories/dart_repository_impl.dart';
import 'package:smart_translator_test/features/translate/presentation/controller/translate_cubit.dart';
import 'package:smart_translator_test/features/user/data/datasource/user_remote_data_source.dart';
import 'package:smart_translator_test/features/user/data/repositories/user_repository_impl.dart';
import 'package:smart_translator_test/features/user/presentation/controller/user_cubit.dart';
import 'package:smart_translator_test/features/vocabulary/data/datasource/vocabulary_remote_datasource.dart';
import 'package:smart_translator_test/features/vocabulary/data/repositories/vocabulary_repository_impl.dart';
import 'package:smart_translator_test/features/vocabulary/presentation/controller/vocabulary_cubit.dart';

import 'features/setting/presentation/pages/refresh_rate_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Detect 60/120 Hz support and apply the saved choice.
  // A failure here must never stop the app from starting.
  try {
    await RefreshRateService.init();
  } catch (_) {}

  final storageService = SecureStorageService();
  final networkCubit = NetworkCubit();

  late final AuthBloc authBloc;

  final dioClient = DioClient(
    storage: storageService,
    networkCubit: networkCubit,
    onUnauthenticated: () {
      authBloc.add(AuthLogoutRequested());
    },
  );

  final authApiService = AuthApiService(dioClient.dio);
  final authRemoteDataSource = AuthRemoteDataSourceImpl(
    apiService: authApiService,
    storageService: storageService,
  );

  final authRepository = AuthRepositoryImpl(
    authRemoteDataSource: authRemoteDataSource,
  );

  authBloc = AuthBloc(
    authRepository: authRepository,
    storageService: storageService,
  )..add(AuthCheckRequested());

  // Server health checker
  final serverHealthService = ServerHealthService();
  final serverHealthCubit = ServerHealthCubit(service: serverHealthService)
    ..wakeServer();

  final themeCubit = ThemeCubit();

  final translateRemoteDataSource = TranslateRemoteDataSource(dioClient.dio);
  final translateRepository = TranslateRepositoryImpl(
    translateRemoteDataSource: translateRemoteDataSource,
  );
  final translateCubit = TranslateCubit(
    translateRepository: translateRepository,
  );

  final vocabularyRemoteDataSource = VocabularyRemoteDatasource(dioClient.dio);
  final vocabularyRepository = VocabularyRepositoryImpl(
    vocabularyRemoteDatasource: vocabularyRemoteDataSource,
  );
  final vocabularyCubit = VocabularyCubit(vocabularyRepository);

  final userRemoteDataSource = UserRemoteDataSource(dioClient.dio);
  final userRepository = UserRepositoryImpl(
    userRemoteDataSource: userRemoteDataSource,
    secureStorageService: storageService,
  );
  final userCubit = UserCubit(userRepository: userRepository)..getProfile();

  final appRouter = AppRouter(authBloc: authBloc);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: networkCubit),
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: serverHealthCubit),
        BlocProvider.value(value: themeCubit),
        BlocProvider.value(value: translateCubit),
        BlocProvider.value(value: vocabularyCubit),
        BlocProvider.value(value: userCubit),
      ],
      child: MyApp(router: appRouter.router),
    ),
  );
}
