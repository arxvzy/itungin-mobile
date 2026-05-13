import 'transaction_model.dart';
import '../core/utils/json_parsers.dart';

class DashboardModel {
  const DashboardModel({
    required this.totalWealth,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.recentTransactions,
    required this.chart,
  });

  final int totalWealth;
  final int monthlyIncome;
  final int monthlyExpense;
  final List<TransactionModel> recentTransactions;
  final DashboardChartModel chart;

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final recent = data['recent_transactions'];
    return DashboardModel(
      totalWealth: parseIntValue(data['total_wealth']),
      monthlyIncome: parseIntValue(data['monthly_income']),
      monthlyExpense: parseIntValue(data['monthly_expense']),
      recentTransactions: recent is List
          ? recent
                .map(
                  (item) => TransactionModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList()
          : const [],
      chart: DashboardChartModel.fromJson(
        data['chart'] is Map
            ? Map<String, dynamic>.from(data['chart'] as Map)
            : const {},
      ),
    );
  }
}

class DashboardChartModel {
  const DashboardChartModel({
    required this.labels,
    required this.actual,
    required this.target,
  });

  final List<int> labels;
  final List<double> actual;
  final List<double> target;

  factory DashboardChartModel.fromJson(Map<String, dynamic> json) =>
      DashboardChartModel(
        labels: (json['labels'] as List? ?? const [])
            .map((item) => parseIntValue(item))
            .toList(),
        actual: (json['actual'] as List? ?? const [])
            .map((item) => parseDoubleValue(item))
            .toList(),
        target: (json['target'] as List? ?? const [])
            .map((item) => parseDoubleValue(item))
            .toList(),
      );
}
