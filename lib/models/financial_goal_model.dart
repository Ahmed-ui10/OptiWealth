class FinancialGoal
{
  String goalName;
  double targetAmount;
  double currentAmount;
  DateTime deadline;
  String status;

  FinancialGoal({
    required this.goalName,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.deadline,
    this.status = 'In Progress',
  });

  factory FinancialGoal.fromJson(Map<String, dynamic> json)
  {
    return FinancialGoal(
      goalName: json['goalName'],
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      deadline: DateTime.parse(json['deadline']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'goalName': goalName,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'status': status,
    };
  }

  void addGoal() {}

  void updateProgress(double amountAdded)
  {
    currentAmount += amountAdded;
    if (isCompleted())
    {
      status = 'Completed';
    }
  }

  bool isCompleted()
  {
    return currentAmount >= targetAmount;
  }
}
