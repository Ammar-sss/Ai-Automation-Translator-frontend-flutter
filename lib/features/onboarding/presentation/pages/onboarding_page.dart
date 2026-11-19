import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_translator_test/core/route/app_routes.dart';
import 'package:smart_translator_test/core/util/responsive.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: "Instant Translation",
      description: "Translate text, voice, and documents across multiple languages instantly and accurately.",
      icon: Icons.translate_rounded,
    ),
    OnboardingItem(
      title: "Smart Vocabulary",
      description: "Save words, create flashcards, and expand your vocabulary effectively with smart tools.",
      icon: Icons.menu_book_rounded,
    ),
    OnboardingItem(
      title: "Learn & Connect",
      description: "Communicate seamlessly anywhere in the world and master new languages with ease.",
      icon: Icons.public_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconBoxSize = context.sp(130, min: 100, max: 180);
    final iconSize = context.sp(65, min: 50, max: 90);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.wp(5),
                vertical: context.hp(1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      context.go(AppRoutes.login);
                    },
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        fontSize: context.sp(15, min: 13, max: 17),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.wp(8)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: iconBoxSize,
                          height: iconBoxSize,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            size: iconSize,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: context.hp(4)),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: context.sp(26, min: 20, max: 30),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: context.hp(1.5)),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: context.sp(15, min: 13, max: 17),
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.wp(6),
                vertical: context.hp(2.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _items.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _items.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.go(AppRoutes.login);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.wp(6).clamp(24.0, 40.0),
                        vertical: context.hp(1.6).clamp(12.0, 18.0),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.defaultRadius),
                      ),
                    ),
                    child: Text(
                      _currentPage == _items.length - 1 ? "Get Started" : "Next",
                      style: TextStyle(
                        fontSize: context.sp(15, min: 14, max: 17),
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

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
