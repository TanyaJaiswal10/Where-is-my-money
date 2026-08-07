import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../models/insights_model.dart';

class SpendingDonutChart extends StatelessWidget {
  final List<CategoryBreakdownModel> categories;
  final double totalSpent;
  final String currency;
  final String periodLabel;

  const SpendingDonutChart({
    super.key,
    required this.categories,
    required this.totalSpent,
    required this.currency,
    this.periodLabel = "This Month",
  });

  static const List<Color> palette = [
    AppColors.primary,
    AppColors.pinkAccent,
    AppColors.lilacAccent,
    AppColors.indigoAccent,
    AppColors.cyanAccent,
    AppColors.purpleAccent,
    AppColors.pinkGlow,
    AppColors.tealAccent,
    AppColors.amberAccent,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SPENDING BREAKDOWN",
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: _DonutChartPainter(
                      categories: categories,
                      palette: palette,
                      isDark: isDark,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CurrencyFormatter.format(totalSpent, currency),
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Total Spent",
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Donut Legend Pills
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            alignment: WrapAlignment.center,
            children: List.generate(categories.length, (index) {
              final cat = categories[index];
              final color = palette[index % palette.length];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightCard,
                  borderRadius: AppSpacing.borderRadiusPill,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      "${cat.category} (${cat.percentage.toStringAsFixed(0)}%)",
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<CategoryBreakdownModel> categories;
  final List<Color> palette;
  final bool isDark;

  _DonutChartPainter({
    required this.categories,
    required this.palette,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const strokeWidth = 24.0;

    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    if (categories.isEmpty) return;

    double startAngle = -pi / 2;
    for (int i = 0; i < categories.length; i++) {
      final sweepAngle = (categories[i].percentage / 100.0) * (2 * pi);
      final paint = Paint()
        ..color = palette[i % palette.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        max(0.02, sweepAngle - 0.04), // slight gap between segments
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}
