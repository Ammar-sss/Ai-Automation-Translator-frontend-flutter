import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_translator_test/core/util/api_response.dart';
import 'package:smart_translator_test/features/translate/data/models/ai_response.dart';
import 'package:smart_translator_test/features/translate/data/models/translate_request.dart';
import 'package:smart_translator_test/features/translate/domain/repositories/translate_repository.dart';
import 'package:smart_translator_test/features/translate/presentation/controller/translate_cubit.dart';
import 'package:smart_translator_test/features/translate/presentation/pages/translate_page.dart';

class FakeTranslateRepository implements TranslateRepository {
  @override
  Future<ApiResponse<AiResponse>> translate(
    TranslateRequest translateRequest,
  ) async {
    return ApiResponse(
      statusCode: 200,
      message: 'Success',
      data: AiResponse(
        termWord: translateRequest.termWord,
        termDefinitions: {'A translation meaning'},
        exampleSentence: 'Example sentence here.',
        exampleDefinition: 'Example definition translation.',
      ),
    );
  }
}

void main() {
  testWidgets('TranslatePage renders correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final translateRepository = FakeTranslateRepository();
    final translateCubit = TranslateCubit(
      translateRepository: translateRepository,
    );

    addTearDown(() {
      translateCubit.close();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<TranslateCubit>.value(
            value: translateCubit,
            child: const TranslatePage(),
          ),
        ),
      ),
    );

    // Verify initial state shows text field
    expect(find.byType(TextField), findsOneWidget);
  });
}
