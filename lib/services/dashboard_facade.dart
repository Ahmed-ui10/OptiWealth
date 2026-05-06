import 'transaction_service.dart';
import 'budget_service.dart';
import 'goal_service.dart';
import '../repositories/user_repository.dart';

// Facade pattern implementation that aggregates data from multiple services for the dashboard
class DashboardFacade {
  final TransactionService _transactionService = TransactionService();
  final BudgetService _budgetService = BudgetService();
  final GoalService _goalService = GoalService();
  final UserRepository _userRepo = UserRepository();

  // Fetch all dashboard data in a single method call
  // Returns a map containing balance, recent transactions, active budgets, goals, and user currency
  Future<Map<String, dynamic>> getDashboardData(int userId) async {
    // Get current account balance
    final balance = await _transactionService.getCurrentBalance(userId);
    
    // Get all user transactions
    final allTransactions = await _transactionService.getUserTransactions(userId);
    
    // Get active budgets for the current period
    final budgets = await _budgetService.getActiveBudgets(userId);
    
    // Get user's financial goals
    final goals = await _goalService.getUserGoals(userId);
    
    // Get user's preferred currency
    final user = await _userRepo.getUserById(userId);
    final currency = user?.currency ?? 'EGP'; // Default to EGP if not found
    
    return {
      'balance': balance,
      'recent': allTransactions,  // Recent transactions list
      'budgets': budgets,
      'goals': goals,
      'currency': currency,
    };
  }
}