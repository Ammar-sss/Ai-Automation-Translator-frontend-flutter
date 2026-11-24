import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_translator_test/core/util/translation_language.dart';
import 'package:smart_translator_test/features/translate/presentation/widgets/language_bar.dart';

void main() {
  group('LanguageBar Tests', () {
    testWidgets('LanguageBar renders with source and target languages', (
      WidgetTester tester,
    ) async {
      int swapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageBar(
              source: TranslationLanguage.english,
              target: TranslationLanguage.spanish,
              onSourceChanged: (_) {},
              onTargetChanged: (_) {},
              onSwap: () => swapCount++,
            ),
          ),
        ),
      );

      // Verify both dropdowns are rendered
      expect(
        find.byType(DropdownButton<TranslationLanguage>),
        findsNWidgets(2),
      );

      // Verify swap button is present
      expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);

      // Verify initial language labels
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);
    });

    testWidgets(
      'LanguageBar calls onSourceChanged when source dropdown changes',
      (WidgetTester tester) async {
        TranslationLanguage? selectedSource;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LanguageBar(
                source: TranslationLanguage.english,
                target: TranslationLanguage.spanish,
                onSourceChanged: (lang) => selectedSource = lang,
                onTargetChanged: (_) {},
                onSwap: () {},
              ),
            ),
          ),
        );

        // Tap the source dropdown (first dropdown)
        await tester.tap(
          find.byType(DropdownButton<TranslationLanguage>).first,
        );
        await tester.pumpAndSettle();

        // Select French from the dropdown
        await tester.tap(find.text('French'));
        await tester.pumpAndSettle();

        expect(selectedSource, TranslationLanguage.french);
      },
    );

    testWidgets(
      'LanguageBar calls onTargetChanged when target dropdown changes',
      (WidgetTester tester) async {
        TranslationLanguage? selectedTarget;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LanguageBar(
                source: TranslationLanguage.english,
                target: TranslationLanguage.spanish,
                onSourceChanged: (_) {},
                onTargetChanged: (lang) => selectedTarget = lang,
                onSwap: () {},
              ),
            ),
          ),
        );

        // Tap the target dropdown (second dropdown)
        await tester.tap(find.byType(DropdownButton<TranslationLanguage>).last);
        await tester.pumpAndSettle();

        // Select a language from the target dropdown
        await tester.tap(find.text('French').last);
        await tester.pumpAndSettle();

        expect(selectedTarget, TranslationLanguage.french);
      },
    );

    testWidgets('LanguageBar calls onSwap when swap button tapped', (
      WidgetTester tester,
    ) async {
      int swapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageBar(
              source: TranslationLanguage.english,
              target: TranslationLanguage.spanish,
              onSourceChanged: (_) {},
              onTargetChanged: (_) {},
              onSwap: () => swapCount++,
            ),
          ),
        ),
      );

      // Tap swap button
      await tester.tap(find.byIcon(Icons.swap_horiz_rounded));
      await tester.pump();

      expect(swapCount, 1);
    });

    testWidgets('LanguageBar displays all available languages in dropdown', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageBar(
              source: TranslationLanguage.english,
              target: TranslationLanguage.spanish,
              onSourceChanged: (_) {},
              onTargetChanged: (_) {},
              onSwap: () {},
            ),
          ),
        ),
      );

      // Open source dropdown
      await tester.tap(find.byType(DropdownButton<TranslationLanguage>).first);
      await tester.pumpAndSettle();

      // Verify all languages are listed (12 languages from TranslationLanguage enum)
      final dropdownItems = find.byType(DropdownMenuItem<TranslationLanguage>);
      expect(dropdownItems, findsNWidgets(12));

      // Check specific languages are present
      expect(find.text('English'), findsWidgets);
      expect(find.text('Spanish'), findsWidgets);
    });

    testWidgets('LanguageBar shows selected language with primary color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageBar(
              source: TranslationLanguage.english,
              target: TranslationLanguage.spanish,
              onSourceChanged: (_) {},
              onTargetChanged: (_) {},
              onSwap: () {},
            ),
          ),
        ),
      );

      // Verify English (source) and Spanish (target) are displayed
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);
    });
  });
}
