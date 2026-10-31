import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator/core/database/app_database.dart';
import 'package:smart_translator/core/network/token_storage.dart';
import 'package:smart_translator/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_translator/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_translator/features/translation/data/repositories/translate_repository_impl.dart';
import 'package:smart_translator/features/translation/domain/repositories/translate_repository.dart';
import 'package:smart_translator/features/user/data/repositories/user_repository_impl.dart';
import 'package:smart_translator/features/user/domain/repositories/user_repository.dart';
import 'package:smart_translator/features/vocabulary/data/repositories/vocabulary_repository_impl.dart';
import 'package:smart_translator/features/vocabulary/domain/repositories/vocabulary_repository.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/controllers/auth_bloc.dart';
import 'features/user/presentation/controllers/user_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final TokenStorage tokenStorage = TokenStorage();

  late final AuthBloc authBloc;
  final apiClient = ApiClient(
    tokenStorage: tokenStorage,
    onSessionExpired: () => authBloc.add(const AuthSessionExpiredRequested()),
  );

  // Instantiating implementations, typed as abstract domain contracts
  final AuthRepository authRepository = AuthRepositoryImpl.fromDio(
    apiClient.dio,
  );
  final UserRepository userRepository = UserRepositoryImpl.fromDio(
    apiClient.dio,
  );
  final TranslateRepository translateRepository =
      TranslateRepositoryImpl.fromDio(apiClient.dio);

  final bool hasSeenOnboarding = await tokenStorage.hasSeenOnboarding();

  // Create AppDatabase instance
  final appDatabase = AppDatabase();

  // Pass both dio AND appDatabase to VocabularyRepositoryImpl
  final VocabularyRepository vocabularyRepository =
      VocabularyRepositoryImpl.create(apiClient.dio, appDatabase);

  authBloc = AuthBloc(
    userRepository: userRepository,
    authRepository: authRepository,
    tokenStorage: tokenStorage,
  );

  await authBloc.restoreSession();

  final router = createRouter(authBloc, hasSeenOnboarding: hasSeenOnboarding);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<UserRepository>.value(value: userRepository),
        RepositoryProvider<TranslateRepository>.value(value: translateRepository),
        RepositoryProvider<VocabularyRepository>.value(value: vocabularyRepository),
        RepositoryProvider.value(value: tokenStorage),
        RepositoryProvider.value(value: apiClient),
        RepositoryProvider.value(value: appDatabase),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider(
            create: (context) => UserCubit(userRepository)..loadProfile(),
          ),
        ],
        child: SmartTranslatorApp(router: router),
      ),
    ),
  );
}
