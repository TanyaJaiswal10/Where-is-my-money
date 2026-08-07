import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class OnboardingPageData {
  final String title;
  final String highlightText;
  final String description;
  final IconData icon;
  final String tag;

  const OnboardingPageData({
    required this.title,
    required this.highlightText,
    required this.description,
    required this.icon,
    required this.tag,
  });
}

class OnboardingPageView extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPageView({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container with Subtle Glow
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              data.icon,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Category Badge Tag
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightCard,
              borderRadius: AppSpacing.borderRadiusPill,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Text(
              data.tag.toUpperCase(),
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Main Headline with Accent Highlight
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                height: 1.25,
              ),
              children: [
                TextSpan(text: data.title),
                TextSpan(
                  text: data.highlightText,
                  style: const TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Description Paragraph
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
