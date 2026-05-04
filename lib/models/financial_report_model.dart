class FinancialReport {
  DateTime reportPeriodStart;
  DateTime reportPeriodEnd;
  Map<String, double> categoryTotals;
  Map<String, double> incomeVsExpenseData;
  Map<String, double> budgetsSummary;

  FinancialReport({
    required this.reportPeriodStart,
    required this.reportPeriodEnd,
    required this.categoryTotals,
    required this.incomeVsExpenseData,
    required this.budgetsSummary,
  });
}
