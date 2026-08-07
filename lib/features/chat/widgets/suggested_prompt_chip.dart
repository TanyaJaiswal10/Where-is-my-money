import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class SuggestedPromptChip extends StatelessWidget {
  final String prompt;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const SuggestedPromptChip({
    super.key,
    required this.prompt,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x9910164A), // Translucent dark navy glass pill
      borderRadius: AppSpacing.borderRadiusPill,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusPill,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md + 2,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusPill,
            border: Border.all(
              color: AppColors.darkBorder,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15.0,
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTextPrimary, // Pure White #FFFFFF
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
