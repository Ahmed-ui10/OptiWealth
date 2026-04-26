class FinancialReport
{
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

  factory FinancialReport.fromJson(Map<String, dynamic> json)
  {
    return FinancialReport(
      reportPeriodStart: DateTime.parse(json['reportPeriodStart']),
      reportPeriodEnd: DateTime.parse(json['reportPeriodEnd']),
      categoryTotals: Map<String, double>.from(json['categoryTotals']),
      incomeVsExpenseData: Map<String, double>.from(json['incomeVsExpenseData']),
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'reportPeriodStart': reportPeriodStart.toIso8601String(),
      'reportPeriodEnd': reportPeriodEnd.toIso8601String(),
      'categoryTotals': categoryTotals,
      'incomeVsExpenseData': incomeVsExpenseData,
    };
  }

  void generatePieChart() {}

  void generateBarChart() {}

  void calculateSummary(List<dynamic> transactions) {}
}
