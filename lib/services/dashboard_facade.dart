import 'transaction_service.dart';
import 'budget_service.dart';
import 'goal_service.dart';
import '../repositories/user_repository.dart';

class DashboardFacade {
  final TransactionService _transactionService = TransactionService();
  final BudgetService _budgetService = BudgetService();
  final GoalService _goalService = GoalService();
  final UserRepository _userRepo = UserRepository();

  Future<Map<String, dynamic>> getDashboardData(int userId) async {
    final balance = await _transactionService.getCurrentBalance(userId);
    final allTransactions = await _transactionService.getUserTransactions(userId);
    final budgets = await _budgetService.getActiveBudgets(userId);
    final goals = await _goalService.getUserGoals(userId);
    final user = await _userRepo.getUserById(userId);
    final currency = user?.currency ?? 'EGP';
    return {
      'balance': balance,
      'recent': allTransactions,  
      'budgets': budgets,
      'goals': goals,
      'currency': currency,
    };
  }
}