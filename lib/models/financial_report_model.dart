class FinancialReport {
  DateTime reportPeriodStart;
  DateTime reportPeriodEnd;
  Map<String, double> categoryTotals;
  Map<String, double> incomeVsExpenseData;

  FinancialReport({
    required this.reportPeriodStart,
    required this.reportPeriodEnd,
    required this.categoryTotals,
    required this.incomeVsExpenseData,
  });
}