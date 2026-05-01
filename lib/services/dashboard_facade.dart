import 'transaction_service.dart';
import 'budget_service.dart';
import 'goal_service.dart';

class DashboardFacade {
  final TransactionService _transactionService = TransactionService();
  final BudgetService _budgetService = BudgetService();
  final GoalService _goalService = GoalService();

  Future<Map<String, dynamic>> getDashboardData(int userId) async {
    final balance = await _transactionService.getCurrentBalance(userId);
    final recent = await _transactionService.getRecentTransactions(userId);
    final budgets = await _budgetService.getActiveBudgets(userId);
    final goals = await _goalService.getUserGoals(userId);
    return {
      'balance': balance,
      'recent': recent,
      'budgets': budgets,
      'goals': goals,
    };
  }
}