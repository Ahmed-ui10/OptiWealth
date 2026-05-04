/// Represents a comprehensive summary of a user's financial activity over a specific time period.
///
/// This class acts as a Data Transfer Object (DTO) that aggregates various 
/// financial metrics into a single structure. This makes it highly efficient 
/// for the UI layer to render charts, graphs, and dashboard summaries without 
/// needing to perform complex calculations itself.
class FinancialReport {
  /// The starting date and time for the data included in this report.
  DateTime reportPeriodStart;
  
  /// The ending date and time for the data included in this report.
  DateTime reportPeriodEnd;
  
  /// A breakdown of total amounts grouped by category name.
  /// 
  /// Example: `{'Groceries': 1500.0, 'Rent': 4000.0}`
  Map<String, double> categoryTotals;
  
  /// Aggregated totals comparing overall income versus overall expenses.
  /// 
  /// Example: `{'Income': 8000.0, 'Expense': 5500.0}`
  Map<String, double> incomeVsExpenseData;
  
  /// A summary of budget utilization, mapping category names to their spent percentage.
  /// 
  /// Example: `{'Entertainment': 0.85}` indicates that 85% of the budget is spent.
  Map<String, double> budgetsSummary;

  /// Creates a new [FinancialReport] instance containing the aggregated data.
  FinancialReport({
    required this.reportPeriodStart,
    required this.reportPeriodEnd,
    required this.categoryTotals,
    required this.incomeVsExpenseData,
    required this.budgetsSummary,
  });
}
