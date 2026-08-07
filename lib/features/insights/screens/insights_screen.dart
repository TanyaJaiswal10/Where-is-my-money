import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../chat/models/transaction_model.dart';
import '../../chat/services/transaction_api_service.dart';
import '../models/insights_model.dart';
import '../services/insights_api_service.dart';
import '../widgets/additional_stats_grid.dart';
import '../widgets/category_breakdown_section.dart';
import '../widgets/category_detail_view.dart';
import '../widgets/income_summary_card.dart';
import '../widgets/insights_empty_state.dart';
import '../widgets/insights_period_selector.dart';
import '../widgets/insights_summary_card.dart';
import '../widgets/smart_insights_section.dart';
import '../widgets/spending_donut_chart.dart';
import '../widgets/spending_trend_chart.dart';

class InsightsScreen extends StatefulWidget {
  final VoidCallback? onSwitchToChat;

  const InsightsScreen({
    super.key,
    this.onSwitchToChat,
  });

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String _selectedPeriod = "month";
  InsightsModel? _insightsData;
  List<TransactionModel> _allTransactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        InsightsApiService.fetchInsights(period: _selectedPeriod),
        TransactionApiService.fetchTransactions(),
      ]);

      setState(() {
        _insightsData = results[0] as InsightsModel;
        _allTransactions = results[1] as List<TransactionModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load insights: $e";
        _isLoading = false;
      });
    }
  }

  void _onPeriodChanged(String period) {
    if (_selectedPeriod == period) return;
    setState(() {
      _selectedPeriod = period;
    });
    _loadInsights();
  }

  void _openCategoryDrillDown(String categoryName) {
    if (_insightsData == null) return;

    final categoryTxs = _allTransactions.where((tx) {
      return tx.category.toLowerCase() == categoryName.toLowerCase() && !tx.isIncome;
    }).toList();

    final sum = categoryTxs.fold<double>(0.0, (acc, tx) => acc + tx.amount);

    CategoryDetailView.show(
      context,
      categoryTitle: categoryName,
      totalAmount: sum > 0 ? sum : (_findCategoryTotal(categoryName)),
      currency: _insightsData!.currency,
      transactions: categoryTxs,
    );
  }

  double _findCategoryTotal(String categoryName) {
    if (_insightsData == null) return 0.0;
    for (final item in _insightsData!.categoryBreakdown) {
      if (item.category.toLowerCase() == categoryName.toLowerCase()) {
        return item.totalAmount;
      }
    }
    return 0.0;
  }

  void _openDateDrillDown(String dateStr) {
    if (_insightsData == null) return;

    final dateTxs = _allTransactions.where((tx) {
      if (tx.isIncome) return false;
      final localDate = tx.timestamp.toLocal();
      final formatted = "${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}";
      return formatted == dateStr;
    }).toList();

    final sum = dateTxs.fold<double>(0.0, (acc, tx) => acc + tx.amount);

    String titleDate = dateStr;
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
        titleDate = "${months[dt.month - 1]} $day, $year";
      }
    } catch (_) {}

    CategoryDetailView.show(
      context,
      categoryTitle: titleDate,
      totalAmount: sum,
      currency: _insightsData!.currency,
      transactions: dateTxs,
    );
  }

  void _openIncomeDrillDown() {
    if (_insightsData == null) return;

    final incomeTxs = _allTransactions.where((tx) => tx.isIncome).toList();
    final sum = incomeTxs.fold<double>(0.0, (acc, tx) => acc + tx.amount);

    CategoryDetailView.show(
      context,
      categoryTitle: "Income",
      totalAmount: sum > 0 ? sum : _insightsData!.totalIncome,
      currency: _insightsData!.currency,
      transactions: incomeTxs,
    );
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'week':
        return 'This Week';
      case 'year':
        return 'This Year';
      case 'custom':
        return 'Custom';
      case 'month':
      default:
        return 'This Month';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insights"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: "Refresh Insights",
            onPressed: _loadInsights,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.darkBackground,
          gradient: RadialGradient(
            center: Alignment(0.0, -0.6),
            radius: 1.5,
            colors: [
              Color(0x38416FE0), // Cobalt blue ambient light source
              Color(0x24C98BFF), // Soft lilac ambient illumination
              Color(0x183159C9), // Royal blue glow
              Color(0xFF080D2B), // Deep Night Blue foundation
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _errorMessage != null
                ? _buildErrorState()
                : (_insightsData == null || _insightsData!.transactionCount == 0)
                    ? InsightsEmptyState(
                        onGoToChat: widget.onSwitchToChat ?? () {},
                      )
                    : RefreshIndicator(
                        onRefresh: _loadInsights,
                        color: AppColors.primary,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 720),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. Period Selector Pills
                                Center(
                                  child: InsightsPeriodSelector(
                                    selectedPeriod: _selectedPeriod,
                                    onSelectPeriod: _onPeriodChanged,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),

                                // 2. Summary Card (Total Income, Total Spending, Net Cash Flow)
                                InsightsSummaryCard(insights: _insightsData!),
                                const SizedBox(height: AppSpacing.lg),

                                // 3. PERSONALIZED FINANCIAL INTELLIGENCE (Moved above Donut Chart)
                                if (_insightsData!.generatedInsights.isNotEmpty ||
                                    _insightsData!.structuredInsights.isNotEmpty) ...[
                                  SmartInsightsSection(
                                    insights: _insightsData!.generatedInsights,
                                    structuredInsights: _insightsData!.structuredInsights,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                ],

                                // 4. SPENDING OVER TIME (Interactive Line Graph)
                                if (_insightsData!.dailySpendingTrend.isNotEmpty) ...[
                                  SpendingTrendChart(
                                    trendPoints: _insightsData!.dailySpendingTrend,
                                    currency: _insightsData!.currency,
                                    onSelectDate: _openDateDrillDown,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                ],

                                // 5. Spending Breakdown Donut Chart
                                if (_insightsData!.totalSpent > 0 &&
                                    _insightsData!.categoryBreakdown.isNotEmpty) ...[
                                  SpendingDonutChart(
                                    categories: _insightsData!.categoryBreakdown,
                                    totalSpent: _insightsData!.totalSpent,
                                    currency: _insightsData!.currency,
                                    periodLabel: _getPeriodLabel(),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                ],

                                // 6. Spending by Category List
                                if (_insightsData!.categoryBreakdown.isNotEmpty) ...[
                                  CategoryBreakdownSection(
                                    categories: _insightsData!.categoryBreakdown,
                                    currency: _insightsData!.currency,
                                    onTapCategory: _openCategoryDrillDown,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                ],

                                // 7. Additional Statistics Grid
                                AdditionalStatsGrid(insights: _insightsData!),
                                const SizedBox(height: AppSpacing.lg),

                                // 8. Income Summary Tile
                                IncomeSummaryCard(
                                  totalIncome: _insightsData!.totalIncome,
                                  currency: _insightsData!.currency,
                                  onTapViewHistory: _openIncomeDrillDown,
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                const SizedBox(height: AppSpacing.xxl),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.roseAccent),
            const SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage ?? "An error occurred",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14.0, color: AppColors.roseAccent),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _loadInsights,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
