import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/insights_model.dart';

class CategoryBreakdownSection extends StatelessWidget {
  final List<CategoryBreakdownModel> categories;
  final String currency;
  final ValueChanged<String>? onTapCategory;

  const CategoryBreakdownSection({
    super.key,
    required this.categories,
    required this.currency,
    this.onTapCategory,
  });

  String _formatAmount(double amt) {
    final formattedNum = amt.toStringAsFixed(amt.truncateToDouble() == amt ? 0 : 2);
    final parts = formattedNum.split('.');
    RegExp reg = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
    String matchFunc(Match match) => '${match[1]},';
    final result = parts[0].replaceAllMapped(reg, matchFunc);
    final sym = currency == 'USD'
        ? '\$'
        : (currency == 'EUR' ? '€' : (currency == 'GBP' ? '£' : '₹'));
    return '$sym$result';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SPENDING BY CATEGORY",
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return InkWell(
                onTap: () {
                  if (onTapCategory != null) {
                    onTapCategory!(cat.category);
                  }
                },
                borderRadius: AppSpacing.borderRadiusMd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row: Emoji + Name + Amount + Percentage + Cue (>)
                      Row(
                        children: [
                          Text(
                            cat.emoji,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              cat.category,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          Text(
                            _formatAmount(cat.totalAmount),
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            width: 36,
                            child: Text(
                              "${cat.percentage.toStringAsFixed(0)}%",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: AppSpacing.borderRadiusPill,
                        child: LinearProgressIndicator(
                          value: (cat.percentage / 100.0).clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightBorder.withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            index == 0
                                ? AppColors.primary
                                : (index == 1 ? AppColors.cyanAccent : AppColors.indigoAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
