import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class DateSeparatorWidget extends StatelessWidget {
  final DateTime date;

  const DateSeparatorWidget({
    super.key,
    required this.date,
  });

  String _formatDateHeader(DateTime dt) {
    final localDate = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(localDate.year, localDate.month, localDate.day);

    if (msgDate == today) {
      return "TODAY";
    } else if (msgDate == yesterday) {
      return "YESTERDAY";
    } else {
      const months = [
        "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
        "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"
      ];
      return "${months[localDate.month - 1]} ${localDate.day}, ${localDate.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: AppSpacing.borderRadiusPill,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.0,
            ),
          ),
          child: Text(
            _formatDateHeader(date),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ),
      ),
    );
  }
}
