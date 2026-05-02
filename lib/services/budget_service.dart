import '../models/budget_model.dart';
import '../models/notification_model.dart';
import '../repositories/budget_repository.dart';
import 'notification_service.dart';

class BudgetService {
  final BudgetRepository _budgetRepo = BudgetRepository();
  final NotificationService _notificationService = NotificationService();

  Future<void> createBudget(Budget budget) async
  {
    await _budgetRepo.createBudget(budget);
  }

  Future<void> updateBudgetTracking(int userId, int categoryId, double amount, String categoryName) async
  {
    final budgets = await _budgetRepo.getBudgetsByUser(userId, activeOnly: true);
    
    final budgetsFound = budgets.where((b) => b.categoryId == categoryId).toList();
    if (budgetsFound.isEmpty) return; 

    final targetBudget = budgetsFound.first;
    targetBudget.addExpense(amount);
    await _budgetRepo.updateBudget(targetBudget);

    if (targetBudget.isExceeded())
    {
      _notificationService.notify(NotificationModel(
        notificationId: 0,
        userId: userId,
        type: 'BUDGET_EXCEEDED',
        message: 'Budget exceeded for category $categoryName',
        timestamp: DateTime.now(),
      ));
    }
    else if (targetBudget.spentPercentage >= (targetBudget.alertThreshold / 100))
    {
      _notificationService.notify(NotificationModel(
        notificationId: 0,
        userId: userId,
        type: 'BUDGET_WARNING',
        message: 'You have used ${(targetBudget.spentPercentage * 100).toInt()}% of your budget for $categoryName',
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<List<Budget>> getActiveBudgets(int userId) async
  {
    return await _budgetRepo.getBudgetsByUser(userId, activeOnly: true);
  }
}
