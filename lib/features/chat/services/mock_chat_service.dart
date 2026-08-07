import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class MockChatService {
  /// Simple local mock parser that demonstrates real-time frontend expense extraction.
  /// Translates inputs like "250 snacks" into structured TransactionModel.
  static TransactionModel parseInput(String input) {
    final cleanInput = input.trim();
    final lower = cleanInput.toLowerCase();

    // Extract numerical amount using regex
    final amountRegex = RegExp(r'(\d+(?:,\d+)*(?:\.\d+)?)');
    final match = amountRegex.firstMatch(cleanInput);

    double amount = 0.0;
    if (match != null) {
      final rawNum = match.group(1)!.replaceAll(',', '');
      amount = double.tryParse(rawNum) ?? 0.0;
    }

    String category = "General";
    IconData icon = Icons.shopping_bag_outlined;
    String emoji = "🛒";

    // Category Keyword Matching
    if (lower.contains("snack") ||
        lower.contains("food") ||
        lower.contains("lunch") ||
        lower.contains("dinner") ||
        lower.contains("coffee") ||
        lower.contains("tea") ||
        lower.contains("pizza") ||
        lower.contains("zomato") ||
        lower.contains("swiggy") ||
        lower.contains("burger")) {
      category = "Food";
      icon = Icons.fastfood_outlined;
      emoji = "🍔";
    } else if (lower.contains("uber") ||
        lower.contains("cab") ||
        lower.contains("auto") ||
        lower.contains("ola") ||
        lower.contains("ride") ||
        lower.contains("petrol") ||
        lower.contains("fuel") ||
        lower.contains("taxi")) {
      category = "Transport";
      icon = Icons.directions_car_outlined;
      emoji = "🚕";
    } else if (lower.contains("rent") ||
        lower.contains("house") ||
        lower.contains("maintenance") ||
        lower.contains("wifi") ||
        lower.contains("bill")) {
      category = "Housing";
      icon = Icons.home_outlined;
      emoji = "🏠";
    } else if (lower.contains("salary") || lower.contains("bonus") || lower.contains("income")) {
      category = "Income";
      icon = Icons.account_balance_wallet_outlined;
      emoji = "💰";
    }

    return TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount > 0 ? amount : 100.0,
      category: category,
      categoryIcon: icon,
      categoryEmoji: emoji,
      rawTitle: cleanInput,
      timestamp: DateTime.now(),
    );
  }
}
