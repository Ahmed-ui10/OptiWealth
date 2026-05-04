import '../models/financial_goal_model.dart';
import '../repositories/goal_repository.dart';

class GoalService {
  final GoalRepository _goalRepo = GoalRepository();

  Future<void> addGoal(FinancialGoal goal) async {
    await _goalRepo.createGoal(goal);
  }

  Future<List<FinancialGoal>> getUserGoals(int userId) async {
    return await _goalRepo.getGoalsByUser(userId);
  }

  Future<void> updateGoalProgress(int goalId, double amount) async {
    final goal = await _goalRepo.getGoalById(goalId);
    if (goal != null && goal.status != 'Completed') {
      goal.updateProgress(amount);
      await _goalRepo.updateGoal(goal);
    }
  }

  // أضف هذه الدالة
  Future<void> updateAllGoalsProgress(int userId, double amount) async {
    final goals = await _goalRepo.getGoalsByUser(userId);
    for (var goal in goals) {
      if (goal.status != 'Completed') {
        goal.updateProgress(amount);
        await _goalRepo.updateGoal(goal);
      }
    }
  }
}
