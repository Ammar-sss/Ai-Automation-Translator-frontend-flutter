import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_translator_test/core/util/api_response.dart';
import 'package:smart_translator_test/features/translate/data/models/ai_response.dart';
import 'package:smart_translator_test/features/translate/presentation/controller/translate_cubit.dart';
import 'package:smart_translator_test/features/translate/presentation/widgets/result_card.dart';
import 'package:smart_translator_test/features/translate/domain/repositories/translate_repository.dart';
import 'package:smart_translator_test/features/translate/data/models/translate_request.dart';

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
  group('ResultCard Tests', () {
    late ValueNotifier<bool> isSaving;

    setUp(() {
      isSaving = ValueNotifier<bool>(false);
    });

    tearDown(() {
      isSaving.dispose();
    });

    testWidgets('ResultCard renders correctly with translation data', (
      WidgetTester tester,
    ) async {
      final aiResponse = AiResponse(
        termWord: 'Hello',
        exampleSentence: 'Hello, how are you?',
        termDefinitions: {'A greeting', 'An expression of welcome'},
        exampleDefinition: 'Hola, ¿cómo estás?',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultCard(
              state: TranslateLoaded(aiResponse: aiResponse),
              isSaving: isSaving,
              onSave: () {},
              targetLanguageCode: 'es',
            ),
          ),
        ),
      );

      // Verify translated word is displayed
      expect(find.text('Hello'), findsOneWidget);

      // Verify definitions are shown as chips
      expect(find.text('A greeting'), findsOneWidget);
      expect(find.text('An expression of welcome'), findsOneWidget);

      // Verify example sentence section
      expect(find.text('EXAMPLE SENTENCE'), findsOneWidget);
      expect(find.text('Hello, how are you?'), findsOneWidget);
      expect(find.text('Hola, ¿cómo estás?'), findsOneWidget);

      // Verify save button
      expect(find.text('Save to vocabulary'), findsOneWidget);
    });

    testWidgets('ResultCard shows loading state when saving', (
      WidgetTester tester,
    ) async {
      final aiResponse = AiResponse(
        termWord: 'Test',
        exampleSentence: 'Test sentence.',
        termDefinitions: {'Test definition'},
        exampleDefinition: 'Test example',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultCard(
              state: TranslateLoaded(aiResponse: aiResponse),
              isSaving: isSaving,
              onSave: () {},
              targetLanguageCode: 'es',
            ),
          ),
        ),
      );

      // Initially not saving
      expect(find.text('Save to vocabulary'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Set saving to true
      isSaving.value = true;
      await tester.pump();

      // Should show loading indicator and saving text
      expect(find.text('Saving to vocabulary…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ResultCard calls onSave when save button tapped', (
      WidgetTester tester,
    ) async {
      final aiResponse = AiResponse(
        termWord: 'SaveTest',
        exampleSentence: 'Save this.',
        termDefinitions: {'To store'},
        exampleDefinition: 'Guardar.',
      );

      bool saveCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultCard(
              state: TranslateLoaded(aiResponse: aiResponse),
              isSaving: isSaving,
              onSave: () => saveCalled = true,
              targetLanguageCode: 'es',
            ),
          ),
        ),
      );

      // Tap save button
      await tester.tap(find.text('Save to vocabulary'));
      await tester.pump();

      expect(saveCalled, isTrue);
    });

    testWidgets('ResultCard does not call onSave when already saving', (
      WidgetTester tester,
    ) async {
      final aiResponse = AiResponse(
        termWord: 'SaveTest',
        exampleSentence: 'Save this.',
        termDefinitions: {'To store'},
        exampleDefinition: 'Guardar.',
      );

      bool saveCalled = false;
      isSaving.value = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultCard(
              state: TranslateLoaded(aiResponse: aiResponse),
              isSaving: isSaving,
              onSave: () => saveCalled = true,
              targetLanguageCode: 'es',
            ),
          ),
        ),
      );

      // Button should be disabled when saving
      final saveButton = find.byType(FilledButton);
      expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);
      expect(saveCalled, isFalse);
    });
  });
}
