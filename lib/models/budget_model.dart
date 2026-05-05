class Budget {
  int? budgetId;
  int userId;
  int categoryId;
  double budgetAmount;
  DateTime startDate;
  DateTime endDate;
  int alertThreshold;
  double spentAmount;
  String budgetStatus;
  DateTime createdAt;

  Budget({
    this.budgetId,
    required this.userId,
    required this.categoryId,
    required this.budgetAmount,
    required this.startDate,
    required this.endDate,
    required this.alertThreshold,
    required this.spentAmount,
    required this.budgetStatus,
    required this.createdAt,
  });

  double get spentPercentage =>
      budgetAmount > 0 ? spentAmount / budgetAmount : 0.0;
  double get remaining => budgetAmount - spentAmount;

  void addExpense(double amount) {
    spentAmount += amount;
    if (spentAmount >= budgetAmount) {
      budgetStatus = 'Exceeded';
    } else if (spentAmount >= budgetAmount * (alertThreshold / 100)) {
      budgetStatus = 'Near Limit';
    } else {
      budgetStatus = 'On Track';
    }
  }

  bool isExceeded() => spentAmount >= budgetAmount;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'userId': userId,
      'categoryId': categoryId,
      'budgetAmount': budgetAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'alertThreshold': alertThreshold,
      'spentAmount': spentAmount,
      'budgetStatus': budgetStatus,
      'createdAt': createdAt.toIso8601String(),
    };
    if (budgetId != null && budgetId != 0) {
      map['budgetId'] = budgetId;
    }
    return map;
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    String? createdAtStr = map['createdAt'];
    DateTime createdAtDate;
    if (createdAtStr == null) {
      createdAtDate = DateTime.parse(map['startDate']);
    } else {
      createdAtDate = DateTime.parse(createdAtStr);
    }
    return Budget(
      budgetId: map['budgetId'],
      userId: map['userId'],
      categoryId: map['categoryId'],
      budgetAmount: (map['budgetAmount'] as num).toDouble(),
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      alertThreshold: map['alertThreshold'],
      spentAmount: (map['spentAmount'] as num).toDouble(),
      budgetStatus: map['budgetStatus'],
      createdAt: createdAtDate,
    );
  }
}