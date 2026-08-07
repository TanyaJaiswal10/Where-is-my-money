import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class UnusualAmountWarningCard extends StatelessWidget {
  final String category;
  final double originalAmount;
  final double suggestedAmount;
  final String message;
  final String question;
  final ValueChanged<double> onSelectAmount;
  final VoidCallback onEdit;

  const UnusualAmountWarningCard({
    super.key,
    required this.category,
    required this.originalAmount,
    required this.suggestedAmount,
    required this.message,
    required this.question,
    required this.onSelectAmount,
    required this.onEdit,
  });

  String _formatAmount(double amt) {
    final formattedNum = amt.toStringAsFixed(amt.truncateToDouble() == amt ? 0 : 2);
    final parts = formattedNum.split('.');
    RegExp reg = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
    String matchFunc(Match match) => '${match[1]},';
    final result = parts[0].replaceAllMapped(reg, matchFunc);
    return '₹$result';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusLg),
            topRight: Radius.circular(AppSpacing.radiusLg),
            bottomLeft: Radius.circular(AppSpacing.radiusSm),
            bottomRight: Radius.circular(AppSpacing.radiusLg),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: const Color(0xBF10164A), // Deep Navy Glass
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusLg),
                  topRight: Radius.circular(AppSpacing.radiusLg),
                  bottomLeft: Radius.circular(AppSpacing.radiusSm),
                  bottomRight: Radius.circular(AppSpacing.radiusLg),
                ),
                border: Border.all(
                  color: AppColors.darkBorder,
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 20.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Warning Header
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: AppColors.amberAccent,
                      ),
                      const SizedBox(width: AppSpacing.xs + 2),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white, // Pure White #FFFFFF
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Text(
                    question,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFD9DEFF), // Cool White #D9DEFF
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Choice Buttons: [ Use ₹60 ] [ Keep ₹6,000 ] [ Edit ]
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Suggested Amount Primary Button (e.g. Use ₹60)
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () => onSelectAmount(suggestedAmount),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryButtonGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x60B879FF),
                                  blurRadius: 12,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              "Use ${_formatAmount(suggestedAmount)}",
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white, // Pure White #FFFFFF
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Original Amount Option (e.g. Keep ₹6,000)
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () => onSelectAmount(originalAmount),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0x6019235A),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0x50B4C8FF), width: 1.0),
                            ),
                            child: Text(
                              "Keep ${_formatAmount(originalAmount)}",
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white, // Pure White #FFFFFF
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Edit Option Button
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: onEdit,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0x4019235A),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0x30B4C8FF), width: 1.0),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_outlined, size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  "Edit",
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white, // Pure White #FFFFFF
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
