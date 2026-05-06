import '../models/financial_goal_model.dart';
import '../models/notification_model.dart';
import '../repositories/goal_repository.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Service class for managing financial goals and tracking progress
class GoalService {
  final GoalRepository _goalRepo = GoalRepository();
  final NotificationService _notificationService = NotificationService();

  // Add a new financial goal
  Future<void> addGoal(FinancialGoal goal) async {
    await _goalRepo.createGoal(goal);
  }

  // Retrieve all goals for a specific user
  Future<List<FinancialGoal>> getUserGoals(int userId) async {
    return await _goalRepo.getGoalsByUser(userId);
  }

  // Helper method to check if the current language is Arabic
  Future<bool> _isArabic() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'en';
    return langCode == 'ar';
  }

  // Update progress for a single goal by adding amount
  // Sends congratulatory notification when goal is achieved
  Future<void> updateGoalProgress(int goalId, double amount) async {
    final goal = await _goalRepo.getGoalById(goalId);
    if (goal != null && goal.status != 'Completed') {
      final wasCompletedBefore = goal.status == 'Completed';
      goal.updateProgress(amount); // Update the goal's current amount
      await _goalRepo.updateGoal(goal);

      // Send notification if goal just reached completion
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

  // Update progress for all incomplete goals of a user by adding amount
  // Useful when an income transaction affects multiple savings goals
  Future<void> updateAllGoalsProgress(int userId, double amount) async {
    final goals = await _goalRepo.getGoalsByUser(userId);
    for (var goal in goals) {
      if (goal.status != 'Completed') {
        final wasCompletedBefore = goal.status == 'Completed';
        goal.updateProgress(amount);
        await _goalRepo.updateGoal(goal);

        // Send completion notification for each goal that reaches 100%
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