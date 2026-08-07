import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/transaction_model.dart';

class TransactionConfirmationCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onUndo;
  final VoidCallback onEdit;
  final VoidCallback onChangeCategory;

  const TransactionConfirmationCard({
    super.key,
    required this.transaction,
    required this.onUndo,
    required this.onEdit,
    required this.onChangeCategory,
  });

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    if (transaction.isUndone) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: const Color(0x8010164A),
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.undo_rounded, size: 16, color: AppColors.roseAccent),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "Transaction removed (${transaction.formattedAmount})",
                style: const TextStyle(
                  fontSize: 13.0,
                  fontStyle: FontStyle.italic,
                  color: AppColors.darkTextMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.84,
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
                color: const Color(0xB310164A), // Translucent Dark Navy Glass
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusLg),
                  topRight: Radius.circular(AppSpacing.radiusLg),
                  bottomLeft: Radius.circular(AppSpacing.radiusSm),
                  bottomRight: Radius.circular(AppSpacing.radiusLg),
                ),
                border: Border.all(
                  color: AppColors.darkBorder,
                  width: 1.0,
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
                  // Header Row: Checkmark Badge + Category Tag + Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs + 2),
                          const Text(
                            "Added",
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkTextPrimary, // Pure White #FFFFFF
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatTime(transaction.timestamp.toLocal()),
                        style: const TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Amount & Category Details Row
                  Row(
                    children: [
                      Text(
                        transaction.formattedAmount,
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.darkTextPrimary, // Pure White #FFFFFF
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      InkWell(
                        onTap: onChangeCategory,
                        borderRadius: AppSpacing.borderRadiusPill,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x8019235A),
                            borderRadius: AppSpacing.borderRadiusPill,
                            border: Border.all(
                              color: AppColors.darkBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                transaction.categoryIcon,
                                size: 14,
                                color: AppColors.primaryLight,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                "${transaction.category} ${transaction.categoryEmoji}",
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkTextPrimary, // Pure White #FFFFFF
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Action Buttons Row: [ Undo ] [ Edit ] [ Change Category ]
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      // Undo Button
                      InkWell(
                        onTap: onUndo,
                        borderRadius: AppSpacing.borderRadiusSm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x6019235A),
                            borderRadius: AppSpacing.borderRadiusSm,
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.undo_rounded, size: 13, color: AppColors.darkTextSecondary),
                              SizedBox(width: 4),
                              Text(
                                "Undo",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Edit Button
                      InkWell(
                        onTap: onEdit,
                        borderRadius: AppSpacing.borderRadiusSm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x6019235A),
                            borderRadius: AppSpacing.borderRadiusSm,
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_outlined, size: 13, color: AppColors.darkTextSecondary),
                              SizedBox(width: 4),
                              Text(
                                "Edit",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Change Category Button
                      InkWell(
                        onTap: onChangeCategory,
                        borderRadius: AppSpacing.borderRadiusSm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x6019235A),
                            borderRadius: AppSpacing.borderRadiusSm,
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.category_outlined, size: 13, color: AppColors.darkTextSecondary),
                              SizedBox(width: 4),
                              Text(
                                "Category",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkTextSecondary,
                                ),
                              ),
                            ],
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
