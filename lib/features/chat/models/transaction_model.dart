import 'package:flutter/material.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String currencySymbol;
  final String category;
  final IconData categoryIcon;
  final String categoryEmoji;
  final String rawTitle;
  final DateTime timestamp;
  final String type;
  bool isUndone;

  TransactionModel({
    required this.id,
    required this.amount,
    this.currencySymbol = '₹',
    required this.category,
    required this.categoryIcon,
    required this.categoryEmoji,
    required this.rawTitle,
    required this.timestamp,
    this.type = 'expense',
    this.isUndone = false,
  });

  bool get isIncome => type.toLowerCase() == 'income' || category.toLowerCase() == 'income';

  String get formattedAmount {
    final formattedNum = amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
    final parts = formattedNum.split('.');
    RegExp reg = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
    String matchFunc(Match match) => '${match[1]},';
    final result = parts[0].replaceAllMapped(reg, matchFunc);
    return '$currencySymbol$result';
  }
}
