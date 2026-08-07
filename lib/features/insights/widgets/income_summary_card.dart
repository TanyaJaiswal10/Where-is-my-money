import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_card.dart';

class IncomeSummaryCard extends StatelessWidget {
  final double totalIncome;
  final String currency;
  final VoidCallback onTapViewHistory;

  const IncomeSummaryCard({
    super.key,
    required this.totalIncome,
    required this.currency,
    required this.onTapViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "INCOME",
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 20,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          Text(
            CurrencyFormatter.format(totalIncome, currency),
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          InkWell(
            onTap: onTapViewHistory,
            borderRadius: AppSpacing.borderRadiusMd,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "View income history",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
