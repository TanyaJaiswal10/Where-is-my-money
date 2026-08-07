import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/insights_model.dart';

class AdditionalStatsGrid extends StatelessWidget {
  final InsightsModel insights;

  const AdditionalStatsGrid({
    super.key,
    required this.insights,
  });

  String _formatAmount(double amt) {
    final formattedNum = amt.toStringAsFixed(amt.truncateToDouble() == amt ? 0 : 2);
    final parts = formattedNum.split('.');
    RegExp reg = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
    String matchFunc(Match match) => '${match[1]},';
    final result = parts[0].replaceAllMapped(reg, matchFunc);
    final sym = insights.currency == 'USD'
        ? '\$'
        : (insights.currency == 'EUR' ? '€' : (insights.currency == 'GBP' ? '£' : '₹'));
    return '$sym$result';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            label: "Daily Average",
            value: _formatAmount(insights.averageDailySpending),
            icon: Icons.calendar_today_rounded,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatItem(
            context,
            label: "Avg Transaction",
            value: _formatAmount(insights.averageTransactionAmount),
            icon: Icons.receipt_outlined,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatItem(
            context,
            label: "Transactions",
            value: "${insights.transactionCount}",
            icon: Icons.format_list_bulleted_rounded,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
