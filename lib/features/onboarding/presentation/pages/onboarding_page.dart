import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_translator/core/network/token_storage.dart';
import 'package:smart_translator/core/router/route_name.dart';
import 'package:smart_translator/features/onboarding/presentation/widgets/onboarding_page_indicator.dart';
import 'package:smart_translator/features/onboarding/presentation/widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingSlideData> _slides = const [
    OnboardingSlideData(
      title: 'Translate any word',
      subtitle: 'Instant contextual definitions',
      description: 'Instant contextual definitions and pronunciation on the fly.',
      illustrationType: OnboardingIllustrationType.translate,
    ),
    OnboardingSlideData(
      title: 'Save & sync your terms',
      subtitle: 'Personal Cloud Library',
      description: 'Build your personal library and access it across all devices.',
      illustrationType: OnboardingIllustrationType.sync,
    ),
    OnboardingSlideData(
      title: 'Practice with flashcards',
      subtitle: 'Spaced Repetition',
      description: 'Smart spaced repetition to commit vocabulary to memory.',
      illustrationType: OnboardingIllustrationType.flashcard,
    ),
  ];

  Future<void> _completeOnboarding() async {
    await context.read<TokenStorage>().setOnboardingSeen();
    if (!mounted) return;
    context.go(RouteName.login);
  }

  void _onNextPressed() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const surfaceColor = Color(0xFF11131D);
    const primaryOrange = Color(0xFFFF5A2C);

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar (Back button + Skip button + Profile Icon Avatar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_currentIndex > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _currentIndex > 0 ? Colors.white : Colors.transparent,
                      size: 20,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Color(0xFFAB8981),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                    ],
                  ),
                ],
              ),
            ),
            // PageView Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingSlide(data: _slides[index]);
                },
              ),
            ),
            // Bottom Controls (Indicator + CTA)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  OnboardingPageIndicator(
                    currentIndex: _currentIndex,
                    count: _slides.length,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        shadowColor: primaryOrange.withValues(alpha: 0.45),
                      ),
                      onPressed: _onNextPressed,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentIndex == _slides.length - 1
                                ? 'Get started'
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
