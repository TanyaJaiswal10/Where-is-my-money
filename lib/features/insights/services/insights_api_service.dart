import '../../../core/services/api_client.dart';
import '../models/insights_model.dart';

class InsightsApiService {
  /// Fetch calculated financial metrics and insights from backend (/insights?period=...)
  static Future<InsightsModel> fetchInsights({
    String period = "month",
    String? startDate,
    String? endDate,
    String currency = "INR",
  }) async {
    String endpoint = "/insights?period=$period&currency=$currency";
    if (period == "custom" && startDate != null && endDate != null) {
      endpoint += "&start_date=$startDate&end_date=$endDate";
    }

    final response = await ApiClient.get(endpoint);
    return InsightsModel.fromJson(response);
  }
}
