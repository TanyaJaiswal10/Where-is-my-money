import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/insights_model.dart';

class TopCategoryCard extends StatelessWidget {
  final CategoryBreakdownModel topCategory;
  final String currency;

  const TopCategoryCard({
    super.key,
    required this.topCategory,
    required this.currency,
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Emoji Avatar Icon Box
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  topCategory.emoji,
                  style: const TextStyle(fontSize: 26.0),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),

            // Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "YOUR BIGGEST EXPENSE",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    topCategory.category,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${_formatAmount(topCategory.totalAmount)} • ${topCategory.percentage.toStringAsFixed(0)}% of total spending",
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
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
