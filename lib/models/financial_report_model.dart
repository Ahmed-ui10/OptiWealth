class FinancialReport {
  DateTime reportPeriodStart;
  DateTime reportPeriodEnd;
  Map<String, double> categoryTotals;
  Map<String, double> incomeVsExpenseData;
  Map<String, double> incomeByMethod;
  Map<String, double> expenseByMethod;

  FinancialReport({
    required this.reportPeriodStart,
    required this.reportPeriodEnd,
    required this.categoryTotals,
    required this.incomeVsExpenseData,
    Map<String, double>? incomeByMethod,
    Map<String, double>? expenseByMethod,
  }) : incomeByMethod = incomeByMethod ?? {},
       expenseByMethod = expenseByMethod ?? {};
}