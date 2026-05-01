class Budget {
  int budgetId;
  int userId;
  String category;
  double budgetAmount;
  DateTime startDate;
  DateTime endDate;
  int alertThreshold;
  double spentAmount;
  String budgetStatus;

  Budget({
    required this.budgetId,
    required this.userId,
    required this.category,
    required this.budgetAmount,
    required this.startDate,
    required this.endDate,
    required this.alertThreshold,
    this.spentAmount = 0.0,
    this.budgetStatus = 'Active',
  });

  double get spentPercentage => spentAmount / budgetAmount;

  void addExpense(double amount) {
    spentAmount += amount;
    if (spentAmount > budgetAmount) budgetStatus = 'Exceeded';
    else if (spentAmount >= budgetAmount * (alertThreshold / 100)) budgetStatus = 'Near Limit';
    else budgetStatus = 'On Track';
  }

  bool isExceeded() => spentAmount > budgetAmount;

  Map<String, dynamic> toMap() => {
        'budgetId': budgetId,
        'userId': userId,
        'category': category,
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
        category: map['category'],
        budgetAmount: map['budgetAmount'],
        startDate: DateTime.parse(map['startDate']),
        endDate: DateTime.parse(map['endDate']),
        alertThreshold: map['alertThreshold'],
        spentAmount: map['spentAmount'],
        budgetStatus: map['budgetStatus'],
      );
}