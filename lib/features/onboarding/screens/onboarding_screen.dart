import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/screens/auth_gate.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      title: "Finance, as simple as ",
      highlightText: "a message.",
      description: "Just type '250 snacks' or '1200 uber'. We intelligently categorize and log every detail automatically.",
      icon: Icons.chat_bubble_outline_rounded,
      tag: "Conversational",
    ),
    OnboardingPageData(
      title: "Crystal clear ",
      highlightText: "insights.",
      description: "Understand where every rupee goes without messy spreadsheets or manual entry forms.",
      icon: Icons.donut_large_rounded,
      tag: "Analytics",
    ),
    OnboardingPageData(
      title: "Smart Financial ",
      highlightText: "Intelligence.",
      description: "Discover spending trends, category breakdowns, and personalized insights effortlessly.",
      icon: Icons.auto_awesome_rounded,
      tag: "Intelligence",
    ),
  ];

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastPage = _currentIndex == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Brand Title + Skip
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        "Where's My Money?",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (!isLastPage)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page View Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPageView(data: _pages[index]);
                },
              ),
            ),

            // Bottom Navigation Controls
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: _currentIndex == index ? 24.0 : 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? AppColors.primary
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          borderRadius: AppSpacing.borderRadiusPill,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Action Button
                  CustomButton(
                    fullWidth: true,
                    text: isLastPage ? "Get Started" : "Continue",
                    icon: isLastPage ? Icons.arrow_forward_rounded : null,
                    onPressed: () {
                      if (isLastPage) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
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
