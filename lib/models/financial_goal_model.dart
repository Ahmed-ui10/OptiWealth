/// Represents a user's financial savings target.
///
/// This class encapsulates the logic for tracking progress towards a specific 
/// monetary goal, automatically managing its completion status.
class FinancialGoal {
  /// The unique identifier for the goal (can be null before database insertion).
  int? id;
  
  /// The ID of the user who created this goal.
  int userId;
  
  /// A descriptive name for the goal (e.g., 'Emergency Fund', 'New Car').
  String goalName;
  
  /// The total monetary amount required to achieve the goal.
  double targetAmount;
  
  /// The amount of money saved towards the goal so far.
  double currentAmount;
  
  /// The target date by which the goal should be completed.
  DateTime deadline;
  
  /// The current state of the goal (defaults to 'In Progress').
  String status;

  /// Creates a new [FinancialGoal] instance.
  FinancialGoal({
    this.id,
    required this.userId,
    required this.goalName,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.status = 'In Progress',
  });

  /// Calculates the completion percentage of the goal.
  /// 
  /// Returns a decimal between `0.0` and `1.0` (or higher if exceeded).
  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0.0;

  /// Increases the [currentAmount] by the specified [amount].
  /// 
  /// If the new total meets or exceeds the [targetAmount], the [status] 
  /// is automatically updated to 'Completed'.
  void updateProgress(double amount)
  {
    currentAmount += amount;
    if (currentAmount >= targetAmount) status = 'Completed';
  }

  /// Converts the [FinancialGoal] instance into a Map for database storage.
  ///
  /// The [deadline] is converted to an ISO-8601 string. The [id] is omitted 
  /// if it is null or zero to allow the database to auto-increment it.
  Map<String, dynamic> toMap()
  {
    final map = <String, dynamic>{
      'userId': userId,
      'goalName': goalName,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline.toIso8601String().split('.')[0],
      'status': status,
    };
    if (id != null && id != 0)
    {
      map['id'] = id;
    }
    return map;
  }

  /// Reconstructs a [FinancialGoal] instance from a local SQLite database [map].
  factory FinancialGoal.fromMap(Map<String, dynamic> map) => FinancialGoal(
    id: map['id'],
    userId: map['userId'],
    goalName: map['goalName'],
    targetAmount: (map['targetAmount'] as num).toDouble(),
    currentAmount: (map['currentAmount'] as num).toDouble(),
    deadline: DateTime.parse(map['deadline']),
    status: map['status'],
  );
}
