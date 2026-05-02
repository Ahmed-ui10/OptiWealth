class FinancialGoal {
  int id;
  int userId;
  String goalName;
  double targetAmount;
  double currentAmount;
  DateTime deadline;
  String status;

  FinancialGoal({
    required this.id,
    required this.userId,
    required this.goalName,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.status = 'In Progress',
  });

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0.0;

  void updateProgress(double amount)
  {
    currentAmount += amount;
    if (currentAmount >= targetAmount) status = 'Completed';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'goalName': goalName,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'deadline': deadline.toIso8601String(),
        'status': status,
      };

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
