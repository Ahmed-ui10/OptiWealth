import '../models/financial_goal_model.dart';
import '../models/notification_model.dart';
import '../repositories/goal_repository.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalService {
  final GoalRepository _goalRepo = GoalRepository();
  final NotificationService _notificationService = NotificationService();

  Future<void> addGoal(FinancialGoal goal) async {
    await _goalRepo.createGoal(goal);
  }

  Future<List<FinancialGoal>> getUserGoals(int userId) async {
    return await _goalRepo.getGoalsByUser(userId);
  }

  Future<bool> _isArabic() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'en';
    return langCode == 'ar';
  }

  Future<void> updateGoalProgress(int goalId, double amount) async {
    final goal = await _goalRepo.getGoalById(goalId);
    if (goal != null && goal.status != 'Completed') {
      final wasCompletedBefore = goal.status == 'Completed';
      goal.updateProgress(amount);
      await _goalRepo.updateGoal(goal);

      if (!wasCompletedBefore && goal.progress >= 1.0) {
        final isArabic = await _isArabic();
        final message = isArabic
            ? '🎉 مبروك! لقد حققت هدفك: ${goal.goalName} 🎉'
            : '🎉 Congratulations! You achieved your goal: ${goal.goalName} 🎉';

        await _notificationService.notify(
          NotificationModel(
            notificationId: null,
            userId: goal.userId,
            type: 'GOAL_ACHIEVED',
            message: message,
            isRead: false,
            timestamp: DateTime.now(),
          ),
        );
      }
    }
  }

  Future<void> updateAllGoalsProgress(int userId, double amount) async {
    final goals = await _goalRepo.getGoalsByUser(userId);
    for (var goal in goals) {
      if (goal.status != 'Completed') {
        final wasCompletedBefore = goal.status == 'Completed';
        goal.updateProgress(amount);
        await _goalRepo.updateGoal(goal);

        if (!wasCompletedBefore && goal.progress >= 1.0) {
          final isArabic = await _isArabic();
          final message = isArabic
              ? '🎉 مبروك! لقد حققت هدفك: ${goal.goalName} 🎉'
              : '🎉 Congratulations! You achieved your goal: ${goal.goalName} 🎉';

          await _notificationService.notify(
            NotificationModel(
              notificationId: null,
              userId: userId,
              type: 'GOAL_ACHIEVED',
              message: message,
              isRead: false,
              timestamp: DateTime.now(),
            ),
          );
        }
      }
    }
  }
}
