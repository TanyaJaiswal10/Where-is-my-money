import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/custom_button.dart';
import '../models/transaction_model.dart';

class EditTransactionSheet extends StatefulWidget {
  final TransactionModel transaction;
  final Function({
    required double amount,
    required String description,
    required String category,
    required DateTime date,
  }) onSave;

  const EditTransactionSheet({
    super.key,
    required this.transaction,
    required this.onSave,
  });

  @override
  State<EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<EditTransactionSheet> {
  late TextEditingController _amountController;
  late TextEditingController _descController;
  late String _selectedCategory;
  late DateTime _selectedDate;

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Food', 'icon': Icons.fastfood_outlined},
    {'name': 'Transport', 'icon': Icons.directions_car_outlined},
    {'name': 'Housing', 'icon': Icons.home_outlined},
    {'name': 'Bills', 'icon': Icons.receipt_long_outlined},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_outlined},
    {'name': 'Entertainment', 'icon': Icons.movie_outlined},
    {'name': 'Health', 'icon': Icons.medical_services_outlined},
    {'name': 'Other', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction.amount.toStringAsFixed(
        widget.transaction.amount.truncateToDouble() == widget.transaction.amount ? 0 : 2,
      ),
    );
    _descController = TextEditingController(text: widget.transaction.rawTitle);
    _selectedCategory = widget.transaction.category;
    _selectedDate = widget.transaction.timestamp;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSave() {
    final amount = double.tryParse(_amountController.text.trim());
    final desc = _descController.text.trim();
    if (amount == null || amount <= 0 || desc.isEmpty) return;

    widget.onSave(
      amount: amount,
      description: desc,
      category: _selectedCategory,
      date: _selectedDate,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sheet Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Edit Transaction",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Amount Field
          Text(
            "AMOUNT",
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              prefixText: "${widget.transaction.currencySymbol} ",
              prefixStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : AppColors.lightCard,
              border: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusMd,
                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Description Field
          Text(
            "DESCRIPTION",
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _descController,
            style: TextStyle(
              fontSize: 15.0,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : AppColors.lightCard,
              border: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusMd,
                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Category Chips
          Text(
            "CATEGORY",
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat['name'];
              return ChoiceChip(
                avatar: Icon(
                  cat['icon'] as IconData,
                  size: 15,
                  color: isSelected ? const Color(0xFF0F172A) : AppColors.primary,
                ),
                label: Text(cat['name'] as String),
                selected: isSelected,
                selectedColor: AppColors.primary,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategory = cat['name'] as String;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),

          // Date Picker Tile
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "Date",
              style: TextStyle(
                fontSize: 14.0,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            subtitle: Text(
              "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            trailing: const Icon(Icons.calendar_today_rounded, size: 20),
            onTap: _pickDate,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Save Action Button
          CustomButton(
            fullWidth: true,
            text: "Save Changes",
            onPressed: _handleSave,
          ),
        ],
      ),
    );
  }
}
