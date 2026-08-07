import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class InsightsPeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onSelectPeriod;

  const InsightsPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onSelectPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const periods = [
      {'label': 'This Week', 'id': 'week'},
      {'label': 'This Month', 'id': 'month'},
      {'label': 'This Year', 'id': 'year'},
      {'label': 'Custom', 'id': 'custom'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightCard,
        borderRadius: AppSpacing.borderRadiusPill,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: periods.map((p) {
            final isSelected = selectedPeriod == p['id'];
            return GestureDetector(
              onTap: () => onSelectPeriod(p['id']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md + 2,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: AppSpacing.borderRadiusPill,
                ),
                child: Text(
                  p['label']!,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
