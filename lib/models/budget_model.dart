class Budget
{
  int budgetId;
  String category;
  double budgetAmount;
  DateTime startDate;
  DateTime endDate;
  int alertThreshold;
  double spentAmount;
  String budgetStatus;

  Budget({
    required this.budgetId,
    required this.category,
    required this.budgetAmount,
    required this.startDate,
    required this.endDate,
    required this.alertThreshold,
    this.spentAmount = 0.0,
    this.budgetStatus = 'Active',
  });

  factory Budget.fromJson(Map<String, dynamic> json)
  {
    return Budget(
      budgetId: json['budgetId'],
      category: json['category'],
      budgetAmount: (json['budgetAmount'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      alertThreshold: json['alertThreshold'],
      spentAmount: (json['spentAmount'] as num).toDouble(),
      budgetStatus: json['budgetStatus'],
    );
  }

 Map<String, dynamic> toJson()
  {
    return
    {
      'budgetId': budgetId,
      'category': category,
      'budgetAmount': budgetAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'alertThreshold': alertThreshold,
      'spentAmount': spentAmount,
      'budgetStatus': budgetStatus,
    };
  }

  static Budget createBudget({
    required int id,
    required String category,
    required double amount,
    required DateTime start,
    required DateTime end,
    required int alertThreshold,
  })
  {
    return Budget(
      budgetId: id,
      category: category,
      budgetAmount: amount,
      startDate: start,
      endDate: end,
      alertThreshold: alertThreshold,
    );
  }

  void editBudget({
    double? newAmount,
    String? newCategory,
    DateTime? newStartDate,
    DateTime? newEndDate,
    int? newAlertThreshold,
  })
  {
    if (newAmount != null) budgetAmount = newAmount;
    if (newCategory != null) category = newCategory;
    if (newStartDate != null) startDate = newStartDate;
    if (newEndDate != null) endDate = newEndDate;
    if (newAlertThreshold != null) alertThreshold = newAlertThreshold;
  }

  bool checkLimit()
  {
    double thresholdAmount = budgetAmount * (alertThreshold / 100);
    return spentAmount >= thresholdAmount;
  }

  bool isExceeded()
  {
    if (spentAmount > budgetAmount)
    {
      budgetStatus = 'Exceeded';
      return true;
    }
    return false;
  }

  void addExpense(double amount)
  {
    spentAmount += amount;
    isExceeded();
  }
}
