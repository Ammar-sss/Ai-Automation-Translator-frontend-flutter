import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator/core/database/app_database.dart';
import 'package:smart_translator/core/network/token_storage.dart';
import 'package:smart_translator/features/translation/data/repositories/translate_repository.dart';
import 'package:smart_translator/features/vocabulary/data/repositories/vocabulary_repository.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/controllers/auth_bloc.dart';
import 'features/user/data/repositories/user_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final TokenStorage tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage: tokenStorage);
  final authRepository = AuthRepository(apiClient.dio);
  final userRepository = UserRepository(apiClient.dio);
  final translateRepository = TranslateRepository(apiClient.dio);

  // Create AppDatabase instance
  final appDatabase = AppDatabase();

  // Pass both dio AND appDatabase to VocabularyRepository
  final vocabularyRepository = VocabularyRepository(apiClient.dio, appDatabase);

  final authBloc = AuthBloc(
    userRepository: userRepository,
    authRepository: authRepository,
    tokenStorage: tokenStorage,
  );

  await authBloc.restoreSession();

  final router = createRouter(authBloc);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: translateRepository),
        RepositoryProvider.value(value: vocabularyRepository),
        RepositoryProvider.value(value: tokenStorage),
        RepositoryProvider.value(value: apiClient),
        RepositoryProvider.value(value: appDatabase),
      ],
      child: BlocProvider.value(
        value: authBloc,
        child: SmartTranslatorApp(router: router),
      ),
    ),
  );
}
