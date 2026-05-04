/// Represents a financial budget for a specific category over a defined period.
///
/// This class encapsulates essential domain logic, ensuring that calculations 
/// for remaining funds and status updates are handled internally rather than 
/// scattered across external services.
class Budget {
  /// The unique identifier for the budget (can be null before database insertion).
  int? budgetId;
  
  /// The ID of the user who owns this budget.
  int userId;
  
  /// The ID of the category this budget monitors.
  int categoryId;
  
  /// The total monetary amount allocated for this budget period.
  double budgetAmount;
  
  /// The starting date of the budget period.
  DateTime startDate;
  
  /// The ending date of the budget period.
  DateTime endDate;
  
  /// The percentage threshold (0-100) at which a warning should be triggered.
  int alertThreshold;
  
  /// The total amount of money spent so far in this category.
  double spentAmount;
  
  /// The current state of the budget (e.g., 'On Track', 'Near Limit', 'Exceeded').
  String budgetStatus;

  /// Creates a new [Budget] instance.
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
  });

  /// Calculates the ratio of the amount spent to the total budget amount.
  /// 
  /// Returns a decimal representing the percentage, or `0.0` if the budget is zero.
  double get spentPercentage =>
      budgetAmount > 0 ? spentAmount / budgetAmount : 0.0;
      
  /// Calculates the remaining funds available in this budget.
  double get remaining => budgetAmount - spentAmount;

  /// Adds a specified [amount] to the total spent and automatically updates the status.
  /// 
  /// The [budgetStatus] transitions to 'Exceeded' if spending surpasses the limit,
  /// or to 'Near Limit' if spending surpasses the [alertThreshold] percentage.
  void addExpense(double amount)
  {
    spentAmount += amount;
    if (spentAmount < 0) spentAmount = 0;
    
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

  /// Evaluates whether the current spending has reached or surpassed the budget limit.
  bool isExceeded() => spentAmount >= budgetAmount;

  /// Converts the [Budget] instance into a Map for database insertion.
  ///
  /// The dates are converted to ISO-8601 strings, and the [budgetId] is 
  /// intentionally omitted if it is null or zero to allow auto-incrementation.
  Map<String, dynamic> toMap()
  {
    final map = <String, dynamic>{
      'userId': userId,
      'categoryId': categoryId,
      'budgetAmount': budgetAmount,
      'startDate': startDate.toIso8601String().split('.')[0],
      'endDate': endDate.toIso8601String().split('.')[0],
      'alertThreshold': alertThreshold,
      'spentAmount': spentAmount,
      'budgetStatus': budgetStatus,
    };
    if (budgetId != null && budgetId != 0)
    {
      map['budgetId'] = budgetId;
    }
    return map;
  }

  /// Reconstructs a [Budget] instance from a local SQLite database [map].
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
