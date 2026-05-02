class Budget {
  int budgetId;
  int userId;
  int categoryId;
  double budgetAmount;
  DateTime startDate;
  DateTime endDate;
  int alertThreshold;
  double spentAmount;
  String budgetStatus;

  Budget({
    required this.budgetId,
    required this.userId,
    required this.categoryId,
    required this.budgetAmount,
    required this.startDate,
    required this.endDate,
    required this.alertThreshold,
    this.spentAmount = 0.0,
    this.budgetStatus = 'Active',
  });

  double get spentPercentage => budgetAmount > 0 ? spentAmount / budgetAmount : 0.0;

  void addExpense(double amount)
  {
    spentAmount += amount;
    if (spentAmount >= budgetAmount)
    {
      budgetStatus = 'Exceeded';
    }
    else if (spentAmount >= budgetAmount * (alertThreshold / 100))
    {
      budgetStatus = 'Near Limit';
    }
    else
    {
      budgetStatus = 'On Track';
    }
  }

  bool isExceeded() => spentAmount >= budgetAmount;

  Map<String, dynamic> toMap() => {
        'budgetId': budgetId,
        'userId': userId,
        'categoryId': categoryId,
        'budgetAmount': budgetAmount,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'alertThreshold': alertThreshold,
        'spentAmount': spentAmount,
        'budgetStatus': budgetStatus,
      };

  factory Budget.fromMap(Map<String, dynamic> map) => Budget(
        budgetId: map['budgetId'],
        userId: map['userId'],
        categoryId: map['categoryId'],
        budgetAmount: (map['budgetAmount'] as num).toDouble(),
        startDate: DateTime.parse(map['startDate']),
        endDate: DateTime.parse(map['endDate']),
        alertThreshold: map['alertThreshold'],
        spentAmount: (map['spentAmount'] as num).toDouble(),
        budgetStatus: map['budgetStatus'],
      );
}
