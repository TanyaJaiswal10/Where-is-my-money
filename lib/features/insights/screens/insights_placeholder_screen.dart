import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_chip.dart';

class InsightsPlaceholderScreen extends StatelessWidget {
  const InsightsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Insights"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monthly Summary Overview
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "THIS MONTH",
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const StatusChip(
                          label: "August 2026",
                          icon: Icons.expand_more_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "₹42,850",
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.0,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Total spent so far",
                      style: TextStyle(
                        fontSize: 13.0,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem("Inflow", "₹75,000", AppColors.primary, isDark),
                        _buildStatItem("Outflow", "₹42,850", AppColors.roseAccent, isDark),
                        _buildStatItem("Saved", "₹32,150", AppColors.indigoAccent, isDark),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                "Category Breakdown",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Visual Empty/Placeholder Card for Category Analytics
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.indigoAccent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.donut_large_rounded,
                            size: 32,
                            color: AppColors.indigoAccent,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          "Spending Patterns Loading",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          "As you log expenses in Chat, automated category breakdown charts will render here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.0,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.0,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}
