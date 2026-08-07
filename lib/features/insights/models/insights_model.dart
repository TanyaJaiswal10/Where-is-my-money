import 'package:flutter/material.dart';

class StructuredInsightModel {
  final String type;
  final String title;
  final String description;
  final double importanceScore;
  final double confidence;
  final String currency;

  StructuredInsightModel({
    required this.type,
    required this.title,
    required this.description,
    required this.importanceScore,
    required this.confidence,
    required this.currency,
  });

  factory StructuredInsightModel.fromJson(Map<String, dynamic> json) {
    return StructuredInsightModel(
      type: json['type'] ?? 'TREND',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      importanceScore: (json['importance_score'] as num? ?? 0.5).toDouble(),
      confidence: (json['confidence'] as num? ?? 0.8).toDouble(),
      currency: json['currency'] ?? 'INR',
    );
  }
}

class CategoryBreakdownModel {
  final String category;
  final double totalAmount;
  final double percentage;
  final int count;
  final int rank;
  final String emoji;
  final IconData icon;

  CategoryBreakdownModel({
    required this.category,
    required this.totalAmount,
    required this.percentage,
    required this.count,
    required this.rank,
    required this.emoji,
    required this.icon,
  });

  factory CategoryBreakdownModel.fromJson(Map<String, dynamic> json) {
    IconData iconData = Icons.shopping_bag_outlined;
    switch ((json['category'] as String? ?? '').toLowerCase()) {
      case 'food':
        iconData = Icons.fastfood_outlined;
        break;
      case 'transport':
        iconData = Icons.directions_car_outlined;
        break;
      case 'housing':
        iconData = Icons.home_outlined;
        break;
      case 'bills':
        iconData = Icons.receipt_long_outlined;
        break;
      case 'shopping':
        iconData = Icons.shopping_bag_outlined;
        break;
      case 'entertainment':
        iconData = Icons.movie_outlined;
        break;
      case 'health':
        iconData = Icons.medical_services_outlined;
        break;
      case 'education':
        iconData = Icons.school_outlined;
        break;
      case 'travel':
        iconData = Icons.flight_takeoff_outlined;
        break;
      case 'income':
        iconData = Icons.account_balance_wallet_outlined;
        break;
    }

    return CategoryBreakdownModel(
      category: json['category'] ?? 'Other',
      totalAmount: (json['total_amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      count: json['count'] ?? 0,
      rank: json['rank'] ?? 1,
      emoji: json['emoji'] ?? '🛒',
      icon: iconData,
    );
  }
}

class DailySpendingPointModel {
  final String date;
  final double amount;
  final int count;

  DailySpendingPointModel({
    required this.date,
    required this.amount,
    this.count = 0,
  });

  factory DailySpendingPointModel.fromJson(Map<String, dynamic> json) {
    return DailySpendingPointModel(
      date: json['date'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}

class PeriodComparisonModel {
  final bool hasComparison;
  final double currentTotal;
  final double previousTotal;
  final double amountChange;
  final double percentageChange;
  final bool isIncrease;
  final String message;

  PeriodComparisonModel({
    required this.hasComparison,
    required this.currentTotal,
    required this.previousTotal,
    required this.amountChange,
    required this.percentageChange,
    required this.isIncrease,
    required this.message,
  });

  factory PeriodComparisonModel.fromJson(Map<String, dynamic> json) {
    return PeriodComparisonModel(
      hasComparison: json['has_comparison'] ?? false,
      currentTotal: (json['current_total'] as num? ?? 0.0).toDouble(),
      previousTotal: (json['previous_total'] as num? ?? 0.0).toDouble(),
      amountChange: (json['amount_change'] as num? ?? 0.0).toDouble(),
      percentageChange: (json['percentage_change'] as num? ?? 0.0).toDouble(),
      isIncrease: json['is_increase'] ?? false,
      message: json['message'] ?? 'Keep tracking to see your trends.',
    );
  }
}

class InsightsModel {
  final String period;
  final String currency;
  final double totalIncome;
  final double totalSpent;
  final double netRemaining;
  final bool hasIncome;
  final int transactionCount;
  final int expenseCount;
  final double averageDailySpending;
  final double averageTransactionAmount;
  final CategoryBreakdownModel? topCategory;
  final List<CategoryBreakdownModel> categoryBreakdown;
  final List<DailySpendingPointModel> dailySpendingTrend;
  final PeriodComparisonModel previousPeriodComparison;
  final List<String> generatedInsights;
  final List<StructuredInsightModel> structuredInsights;

  InsightsModel({
    required this.period,
    required this.currency,
    required this.totalIncome,
    required this.totalSpent,
    required this.netRemaining,
    required this.hasIncome,
    required this.transactionCount,
    required this.expenseCount,
    required this.averageDailySpending,
    required this.averageTransactionAmount,
    this.topCategory,
    required this.categoryBreakdown,
    required this.dailySpendingTrend,
    required this.previousPeriodComparison,
    required this.generatedInsights,
    required this.structuredInsights,
  });

  factory InsightsModel.fromJson(Map<String, dynamic> json) {
    return InsightsModel(
      period: json['period'] ?? 'month',
      currency: json['currency'] ?? 'INR',
      totalIncome: (json['total_income'] as num? ?? 0.0).toDouble(),
      totalSpent: (json['total_spent'] as num? ?? 0.0).toDouble(),
      netRemaining: (json['net_remaining'] as num? ?? 0.0).toDouble(),
      hasIncome: json['has_income'] ?? false,
      transactionCount: json['transaction_count'] ?? 0,
      expenseCount: json['expense_count'] ?? 0,
      averageDailySpending: (json['average_daily_spending'] as num? ?? 0.0).toDouble(),
      averageTransactionAmount: (json['average_transaction_amount'] as num? ?? 0.0).toDouble(),
      topCategory: json['top_category'] != null
          ? CategoryBreakdownModel.fromJson(json['top_category'])
          : null,
      categoryBreakdown: (json['category_breakdown'] as List? ?? [])
          .map((e) => CategoryBreakdownModel.fromJson(e))
          .toList(),
      dailySpendingTrend: (json['daily_spending_trend'] as List? ?? [])
          .map((e) => DailySpendingPointModel.fromJson(e))
          .toList(),
      previousPeriodComparison: PeriodComparisonModel.fromJson(
        json['previous_period_comparison'] ?? {},
      ),
      generatedInsights: (json['generated_insights'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      structuredInsights: (json['structured_insights'] as List? ?? [])
          .map((e) => StructuredInsightModel.fromJson(e))
          .toList(),
    );
  }
}
