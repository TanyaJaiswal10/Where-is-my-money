import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../models/insights_model.dart';

class InsightsSummaryCard extends StatelessWidget {
  final InsightsModel insights;

  const InsightsSummaryCard({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final comp = insights.previousPeriodComparison;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: TOTAL INCOME
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TOTAL INCOME",
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(insights.totalIncome, insights.currency),
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (comp.hasComparison)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: comp.isIncrease
                        ? AppColors.roseAccent.withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: AppSpacing.borderRadiusPill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        comp.isIncrease ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 12,
                        color: comp.isIncrease ? AppColors.roseAccent : AppColors.primary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "${comp.percentageChange.toStringAsFixed(1)}% vs last period",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: comp.isIncrease ? AppColors.roseAccent : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: AppSpacing.lg),

          // Row 2: TOTAL SPENDING & NET CASH FLOW
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TOTAL SPENDING",
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(insights.totalSpent, insights.currency),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "NET CASH FLOW",
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(insights.netRemaining, insights.currency),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: insights.netRemaining >= 0 ? AppColors.primary : AppColors.roseAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
