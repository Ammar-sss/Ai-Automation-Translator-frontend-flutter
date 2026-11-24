import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_translator_test/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  testWidgets('OnboardingPage renders and navigates pages correctly', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: OnboardingPage()));

    // Verify first onboarding page content
    expect(find.text('Instant Translation'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Swipe left to next onboarding page
    await tester.drag(find.byType(PageView), const Offset(-1000, 0));
    await tester.pumpAndSettle();

    // Verify second onboarding page content
    expect(find.text('Smart Vocabulary'), findsOneWidget);

    // Swipe left again to third page
    await tester.drag(find.byType(PageView), const Offset(-1000, 0));
    await tester.pumpAndSettle();

    // Verify third onboarding page content
    expect(find.text('Learn & Connect'), findsOneWidget);
  });
}
