import 'package:flutter/material.dart';
import '../../../core/services/api_client.dart';
import '../models/transaction_model.dart';

class TransactionApiService {
  /// Send natural language prompt to backend parser (/transactions/parse).
  /// Handles success, clarification, conversational undo, and unusual amount warnings.
  static Future<Map<String, dynamic>> parseNaturalLanguage(
    String text, {
    String currency = "INR",
    bool confirmUnusual = false,
    double? overrideAmount,
    Map<String, dynamic>? pendingContext,
  }) async {
    final payload = {
      "text": text,
      "currency": currency,
      "confirm_unusual": confirmUnusual,
      if (overrideAmount != null) "override_amount": overrideAmount,
      if (pendingContext != null) "pending_context": pendingContext,
    };

    final response = await ApiClient.post("/transactions/parse", payload);
    final status = response['status'] ?? 'needs_clarification';

    if (status == 'needs_clarification') {
      return {
        'status': 'needs_clarification',
        'missing_field': response['missing_field'],
        'message': response['message'] ?? 'Could not parse transaction details.',
        'pending_context': response['pending_context'],
      };
    }

    if (status == 'undo_success') {
      return {
        'status': 'undo_success',
        'message': response['message'] ?? 'Transaction removed.',
      };
    }

    if (status == 'unusual_warning') {
      return {
        'status': 'unusual_warning',
        'original_amount': (response['original_amount'] as num).toDouble(),
        'suggested_amount': (response['suggested_amount'] as num).toDouble(),
        'category': response['category'] ?? 'General',
        'description': response['description'] ?? text,
        'message': response['message'] ?? 'Amount seems unusually high.',
        'question': response['question'] ?? 'Did you mean a lower amount?',
      };
    }

    final List<TransactionModel> transactionsList = [];
    if (response['transactions'] != null && response['transactions'] is List) {
      for (final txJson in response['transactions']) {
        transactionsList.add(_parseModel(txJson));
      }
    } else if (response['transaction'] != null) {
      transactionsList.add(_parseModel(response['transaction']));
    }

    final mainModel = transactionsList.isNotEmpty ? transactionsList.first : _parseModel(response['transaction']);

    return {
      'status': 'success',
      'confidence': response['confidence'] ?? 1.0,
      'transaction': mainModel,
      'transactions': transactionsList,
    };
  }

  /// Reverses / deletes the most recent transaction via POST /transactions/undo-latest
  static Future<Map<String, dynamic>> undoLatestTransaction() async {
    final response = await ApiClient.post("/transactions/undo-latest", {});
    return response;
  }

  /// Create structured transaction directly (POST /transactions)
  static Future<TransactionModel> createTransaction({
    required double amount,
    required String type,
    required String description,
    required String category,
    String currency = "INR",
  }) async {
    final payload = {
      "amount": amount,
      "type": type,
      "description": description,
      "category": category,
      "currency": currency,
    };

    final response = await ApiClient.post("/transactions", payload);
    return _parseModel(response);
  }

  /// Retrieve all transactions from database (GET /transactions)
  static Future<List<TransactionModel>> fetchTransactions() async {
    final response = await ApiClient.get("/transactions");
    if (response is List) {
      return response.map((item) => _parseModel(item)).toList();
    }
    return [];
  }

  /// Update existing transaction (PUT /transactions/{id})
  static Future<TransactionModel> updateTransaction(
    int id,
    Map<String, dynamic> updates,
  ) async {
    final response = await ApiClient.put("/transactions/$id", updates);
    return _parseModel(response);
  }

  /// Delete transaction from database (DELETE /transactions/{id})
  static Future<bool> deleteTransaction(int id) async {
    try {
      await ApiClient.delete("/transactions/$id");
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Maps backend FastAPI JSON response to frontend TransactionModel
  static TransactionModel _parseModel(Map<String, dynamic> json) {
    final String categoryStr = json['category'] ?? 'General';
    IconData icon = Icons.shopping_bag_outlined;
    String emoji = "🛒";

    switch (categoryStr.toLowerCase()) {
      case 'food':
        icon = Icons.fastfood_outlined;
        emoji = "🍔";
        break;
      case 'transport':
        icon = Icons.directions_car_outlined;
        emoji = "🚕";
        break;
      case 'housing':
        icon = Icons.home_outlined;
        emoji = "🏠";
        break;
      case 'bills':
        icon = Icons.receipt_long_outlined;
        emoji = "⚡";
        break;
      case 'shopping':
        icon = Icons.shopping_bag_outlined;
        emoji = "🛍️";
        break;
      case 'entertainment':
        icon = Icons.movie_outlined;
        emoji = "🎬";
        break;
      case 'health':
        icon = Icons.medical_services_outlined;
        emoji = "💊";
        break;
      case 'education':
        icon = Icons.school_outlined;
        emoji = "📚";
        break;
      case 'travel':
        icon = Icons.flight_takeoff_outlined;
        emoji = "✈️";
        break;
      case 'income':
        icon = Icons.account_balance_wallet_outlined;
        emoji = "💰";
        break;
    }

    final rawAmount = json['amount'];
    double doubleAmount = 0.0;
    if (rawAmount is num) {
      doubleAmount = rawAmount.toDouble();
    } else if (rawAmount is String) {
      doubleAmount = double.tryParse(rawAmount) ?? 0.0;
    }

    return TransactionModel(
      id: json['id'].toString(),
      amount: doubleAmount,
      currencySymbol: json['currency'] == 'USD'
          ? '\$'
          : (json['currency'] == 'EUR' ? '€' : (json['currency'] == 'GBP' ? '£' : '₹')),
      category: categoryStr,
      categoryIcon: icon,
      categoryEmoji: emoji,
      rawTitle: json['description'] ?? '',
      timestamp: _parseDateTime(json['transaction_date'] ?? json['created_at']),
      type: (json['type'] ?? 'expense').toString().toLowerCase(),
    );
  }

  static DateTime _parseDateTime(dynamic raw) {
    if (raw == null) return DateTime.now();
    final str = raw.toString().trim();
    if (str.isEmpty) return DateTime.now();

    String formattedStr = str;
    if (!formattedStr.endsWith('Z') && !RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(formattedStr)) {
      formattedStr = '${formattedStr}Z';
    }

    try {
      return DateTime.parse(formattedStr).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }
}
