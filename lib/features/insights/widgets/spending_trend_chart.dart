import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../models/insights_model.dart';

class SpendingTrendChart extends StatefulWidget {
  final List<DailySpendingPointModel> trendPoints;
  final String currency;
  final ValueChanged<String>? onSelectDate;

  const SpendingTrendChart({
    super.key,
    required this.trendPoints,
    required this.currency,
    this.onSelectDate,
  });

  @override
  State<SpendingTrendChart> createState() => _SpendingTrendChartState();
}

class _SpendingTrendChartState extends State<SpendingTrendChart> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectHighestPeakByDefault();
  }

  @override
  void didUpdateWidget(covariant SpendingTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trendPoints != widget.trendPoints) {
      _selectHighestPeakByDefault();
    }
  }

  void _selectHighestPeakByDefault() {
    if (widget.trendPoints.isEmpty) {
      _selectedIndex = null;
      return;
    }
    int maxIdx = 0;
    double maxAmt = widget.trendPoints[0].amount;
    for (int i = 1; i < widget.trendPoints.length; i++) {
      if (widget.trendPoints[i].amount > maxAmt) {
        maxAmt = widget.trendPoints[i].amount;
        maxIdx = i;
      }
    }
    _selectedIndex = maxIdx;
  }

  String _formatFullDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        final dt = DateTime(year, month, day);
        const months = [
          "January", "February", "March", "April", "May", "June",
          "July", "August", "September", "October", "November", "December"
        ];
        return "${months[dt.month - 1]} ${dt.day}, $year";
      }
    } catch (_) {}
    return dateStr;
  }

  void _handleTouch(Offset localPosition, Size size) {
    if (widget.trendPoints.isEmpty) return;
    const paddingLeft = 16.0;
    const paddingRight = 16.0;
    final chartWidth = size.width - paddingLeft - paddingRight;
    if (chartWidth <= 0) return;

    final dx = (localPosition.dx - paddingLeft).clamp(0.0, chartWidth);
    final count = widget.trendPoints.length;
    final step = count > 1 ? chartWidth / (count - 1) : chartWidth;

    final index = (dx / step).round().clamp(0, count - 1);
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.trendPoints.isEmpty) return const SizedBox.shrink();

    final selectedPt = (_selectedIndex != null && _selectedIndex! < widget.trendPoints.length)
        ? widget.trendPoints[_selectedIndex!]
        : widget.trendPoints.last;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SPENDING OVER TIME",
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              Text(
                "Tap / Drag graph to inspect",
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Floating Selected Point Info Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatFullDate(selectedPt.date),
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            "${CurrencyFormatter.format(selectedPt.amount, widget.currency)} spent",
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: AppSpacing.borderRadiusPill,
                            ),
                            child: Text(
                              "${selectedPt.count} ${selectedPt.count == 1 ? 'tx' : 'txs'}",
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (selectedPt.count > 0 && widget.onSelectDate != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => widget.onSelectDate!(selectedPt.date),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "View transactions",
                          style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Interactive Line Graph Canvas
          LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth;
              const chartHeight = 160.0;
              final size = Size(chartWidth, chartHeight);

              return GestureDetector(
                onPanDown: (details) => _handleTouch(details.localPosition, size),
                onPanUpdate: (details) => _handleTouch(details.localPosition, size),
                onTapDown: (details) => _handleTouch(details.localPosition, size),
                child: MouseRegion(
                  onHover: (event) => _handleTouch(event.localPosition, size),
                  child: CustomPaint(
                    size: size,
                    painter: _LineGraphPainter(
                      trendPoints: widget.trendPoints,
                      selectedIndex: _selectedIndex,
                      isDark: isDark,
                    ),
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

class _LineGraphPainter extends CustomPainter {
  final List<DailySpendingPointModel> trendPoints;
  final int? selectedIndex;
  final bool isDark;

  _LineGraphPainter({
    required this.trendPoints,
    required this.selectedIndex,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (trendPoints.isEmpty) return;

    const paddingLeft = 16.0;
    const paddingRight = 16.0;
    const paddingTop = 16.0;
    const paddingBottom = 28.0;

    final drawWidth = size.width - paddingLeft - paddingRight;
    final drawHeight = size.height - paddingTop - paddingBottom;

    // Determine max value
    double maxVal = 0.0;
    for (var pt in trendPoints) {
      if (pt.amount > maxVal) maxVal = pt.amount;
    }
    if (maxVal == 0.0) maxVal = 1.0;

    final count = trendPoints.length;
    final stepX = count > 1 ? drawWidth / (count - 1) : drawWidth;

    // Calculate screen points
    final List<Offset> points = [];
    for (int i = 0; i < count; i++) {
      final x = paddingLeft + (i * stepX);
      final y = paddingTop + drawHeight - ((trendPoints[i].amount / maxVal) * drawHeight);
      points.add(Offset(x, y));
    }

    // 1. Draw Grid Lines
    final gridPaint = Paint()
      ..color = isDark ? const Color(0xFF334155).withValues(alpha: 0.4) : const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 3; i++) {
      final y = paddingTop + (drawHeight * (i / 3));
      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), gridPaint);
    }

    // 2. Build Smooth Path & Gradient Area Fill
    final linePath = Path();
    final fillPath = Path();

    linePath.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, paddingTop + drawHeight);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 0; i < count - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

      linePath.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p1.dx, p1.dy,
      );
      fillPath.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p1.dx, p1.dy,
      );
    }

    fillPath.lineTo(points.last.dx, paddingTop + drawHeight);
    fillPath.close();

    // Render Gradient Fill
    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.pinkAccent.withValues(alpha: 0.30),
        AppColors.primary.withValues(alpha: 0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Render Smooth Line
    final lineGradient = const LinearGradient(
      colors: [AppColors.primary, AppColors.pinkAccent],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..shader = lineGradient
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // 3. Render Axis Date Labels (Sampled for clean display)
    final textStyle = TextStyle(
      fontSize: 10.0,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
    );

    final labelInterval = max(1, (count / 5).ceil());
    for (int i = 0; i < count; i += labelInterval) {
      final rawDate = trendPoints[i].date;
      final label = rawDate.length >= 10 ? rawDate.substring(5) : rawDate; // MM-DD
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelX = (points[i].dx - (textPainter.width / 2)).clamp(
        paddingLeft,
        size.width - paddingRight - textPainter.width,
      );
      textPainter.paint(canvas, Offset(labelX, size.height - 20));
    }

    // 4. Highlight Selected Data Point & Vertical Cursor Line
    if (selectedIndex != null && selectedIndex! < points.length) {
      final selectedPt = points[selectedIndex!];

      // Vertical Indicator Line
      final indicatorPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.5)
        ..strokeWidth = 1.5;

      canvas.drawLine(
        Offset(selectedPt.dx, paddingTop),
        Offset(selectedPt.dx, paddingTop + drawHeight),
        indicatorPaint,
      );

      // Outer Glowing Ring
      final outerGlowPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(selectedPt, 12, outerGlowPaint);

      // Middle Ring
      final midRingPaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill;
      canvas.drawCircle(selectedPt, 6, midRingPaint);

      // Center White Dot
      final centerDotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(selectedPt, 3, centerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineGraphPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.trendPoints != trendPoints ||
        oldDelegate.isDark != isDark;
  }
}
