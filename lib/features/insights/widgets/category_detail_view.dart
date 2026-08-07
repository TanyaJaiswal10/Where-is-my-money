import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../chat/models/transaction_model.dart';

class CategoryDetailView extends StatelessWidget {
  final String categoryTitle;
  final double totalAmount;
  final String currency;
  final List<TransactionModel> transactions;

  const CategoryDetailView({
    super.key,
    required this.categoryTitle,
    required this.totalAmount,
    required this.currency,
    required this.transactions,
  });

  static void show(
    BuildContext context, {
    required String categoryTitle,
    required double totalAmount,
    required String currency,
    required List<TransactionModel> transactions,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return CategoryDetailView(
              categoryTitle: categoryTitle,
              totalAmount: totalAmount,
              currency: currency,
              transactions: transactions,
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${months[local.month - 1]} ${local.day}";
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: AppSpacing.borderRadiusPill,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Header: Category Title + Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryTitle,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          // Total Amount Subtitle
          Text(
            "${CurrencyFormatter.format(totalAmount, currency)} total",
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 4-Column Table Header: Item | Date | Time | Amount
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    "Item",
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Date",
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Time",
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Amount",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: AppSpacing.sm),

          // Table Rows
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Text(
                      "No transactions found for this period.",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                tx.rawTitle.isNotEmpty ? tx.rawTitle : tx.category,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                _formatDate(tx.timestamp),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                _formatTime(tx.timestamp),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                tx.formattedAmount,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
