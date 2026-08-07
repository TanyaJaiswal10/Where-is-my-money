import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback? onTap;

  const StatusChip({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppSpacing.borderRadiusPill,
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14.0, color: color),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
