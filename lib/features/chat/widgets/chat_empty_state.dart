import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'suggested_prompt_chip.dart';

class ChatEmptyState extends StatelessWidget {
  final ValueChanged<String> onSelectPrompt;

  const ChatEmptyState({
    super.key,
    required this.onSelectPrompt,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final suggestions = [
      {'prompt': '₹250 snacks', 'label': '₹250 snacks', 'icon': Icons.fastfood_outlined},
      {'prompt': '₹500 Uber', 'label': '₹500 Uber', 'icon': Icons.directions_car_outlined},
      {'prompt': '₹1,200 rent', 'label': '₹1,200 rent', 'icon': Icons.home_outlined},
      {'prompt': '₹300 lunch', 'label': '₹300 lunch', 'icon': Icons.restaurant_rounded},
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Branding Icon
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
                Icons.chat_bubble_outline_rounded,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Main Title
            Text(
              "Where’s My Money?",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Subtitle
            Text(
              "Tell me where your money went.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Prompt Suggestions Label
            Text(
              "TRY AN EXAMPLE",
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Wrap Grid of Example Suggestion Chips
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: suggestions.map((item) {
                return SuggestedPromptChip(
                  prompt: item['prompt'] as String,
                  label: item['label'] as String,
                  icon: item['icon'] as IconData,
                  onTap: () => onSelectPrompt(item['prompt'] as String),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
