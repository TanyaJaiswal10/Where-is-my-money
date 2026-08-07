import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/insights_model.dart';

class SmartInsightsSection extends StatelessWidget {
  final List<String> insights;
  final List<StructuredInsightModel> structuredInsights;

  const SmartInsightsSection({
    super.key,
    required this.insights,
    this.structuredInsights = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (insights.isEmpty && structuredInsights.isEmpty) return const SizedBox.shrink();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: AppSpacing.xs + 2),
              Text(
                "PERSONALIZED FINANCIAL INTELLIGENCE",
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          if (structuredInsights.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: structuredInsights.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final item = structuredInsights[index];
                return _buildStructuredCard(context, item, isDark);
              },
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: insights.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final text = insights[index];
                return _buildStringCard(context, text, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStructuredCard(BuildContext context, StructuredInsightModel item, bool isDark) {
    Color cardBorder;
    Color iconColor;
    IconData iconData;

    switch (item.type) {
      case 'ANOMALY':
        cardBorder = AppColors.roseAccent;
        iconColor = AppColors.roseAccent;
        iconData = Icons.warning_amber_rounded;
        break;
      case 'BUDGET_RISK':
        cardBorder = AppColors.amberAccent;
        iconColor = AppColors.amberAccent;
        iconData = Icons.speed_rounded;
        break;
      case 'SUBSCRIPTION':
      case 'RECURRING_EXPENSE':
        cardBorder = AppColors.primary;
        iconColor = AppColors.primary;
        iconData = Icons.repeat_rounded;
        break;
      case 'GOAL_PROGRESS':
        cardBorder = AppColors.primaryLight;
        iconColor = AppColors.primaryLight;
        iconData = Icons.flag_rounded;
        break;
      default:
        cardBorder = AppColors.primary;
        iconColor = AppColors.primary;
        iconData = Icons.trending_up_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightCard,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: cardBorder.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, size: 18, color: iconColor),
              const SizedBox(width: AppSpacing.xs + 2),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: AppSpacing.borderRadiusPill,
                ),
                child: Text(
                  item.type.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: TextStyle(
              fontSize: 13.0,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStringCard(BuildContext context, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle.withValues(alpha: 0.5),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
