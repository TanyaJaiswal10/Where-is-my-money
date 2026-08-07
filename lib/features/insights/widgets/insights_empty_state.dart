import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/custom_button.dart';

class InsightsEmptyState extends StatelessWidget {
  final VoidCallback onGoToChat;

  const InsightsEmptyState({
    super.key,
    required this.onGoToChat,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              "Your insights will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Text(
              "Start by telling me where your money went.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            CustomButton(
              text: "Go to Chat",
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: onGoToChat,
            ),
          ],
        ),
      ),
    );
  }
}
