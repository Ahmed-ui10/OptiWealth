import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/budget_repository.dart';
import '../repositories/account_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/goal_repository.dart';
import 'budget_service.dart';
import 'goal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Service class for managing transaction operations (create, update, delete)
// Handles balance updates, budget tracking, and goal progress
class TransactionService {
  final TransactionRepository _transactionRepo = TransactionRepository();
  final AccountRepository _accountRepo = AccountRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final BudgetService _budgetService = BudgetService();
  final GoalService _goalService = GoalService();

  // Helper method to check if current language is Arabic
  Future<bool> _isArabic() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'en';
    return langCode == 'ar';
  }

  // Add a new transaction
  // Updates account balance, tracks budget usage, and updates goal progress for income
  Future<void> addTransaction(Transaction transaction) async {
    if (!transaction.validate()) throw Exception('Invalid transaction');

    // Save transaction to database
    await _transactionRepo.createTransaction(transaction);

    // Update user's account balance
    final account = await _accountRepo.getAccountByUserId(transaction.userId);
    if (account != null) {
      if (transaction.transactionType) {
        account.deposit(transaction.amount); // Income: add to balance
      } else {
        account.withdraw(transaction.amount); // Expense: subtract from balance
      }
      await _accountRepo.updateAccount(account);
    }

    // Track budget usage (positive for expense, negative for income)
    final category = await _categoryRepo.getCategoryById(
      transaction.categoryId,
    );
    final categoryName = category?.name ?? "Unknown Category";
    final isArabic = await _isArabic();

    final amountForBudget = transaction.transactionType
        ? -transaction.amount // Income reduces budget "spent" amount
        : transaction.amount; // Expense increases budget "spent" amount

    await _budgetService.updateBudgetTracking(
      transaction.userId,
      transaction.categoryId,
      amountForBudget,
      categoryName,
      isArabic,
      transaction.dateTime,
    );

    // For income transactions, update all goal progress
    if (transaction.transactionType) {
      await _goalService.updateAllGoalsProgress(
        transaction.userId,
        transaction.amount,
      );
    }
  }

  // Update an existing transaction
  // Reverts old transaction effects, then applies new transaction effects
  Future<void> updateTransaction(Transaction transaction) async {
    // Get the original transaction before update
    final oldTx = await _transactionRepo.getTransactionById(transaction.id!);
    if (oldTx == null) throw Exception('Transaction not found');

    // Get user's account
    final account = await _accountRepo.getAccountByUserId(transaction.userId);
    if (account == null) throw Exception('Account not found');

    // STEP 1: Revert the old transaction effects
    final oldCategory = await _categoryRepo.getCategoryById(oldTx.categoryId);
    final isArabic = await _isArabic();
    double oldBudgetEffect = oldTx.transactionType
        ? -oldTx.amount
        : oldTx.amount;
    await _budgetService.updateBudgetTracking(
      transaction.userId,
      oldTx.categoryId,
      -oldBudgetEffect, // Reverse the budget effect
      oldCategory?.name ?? "Unknown",
      isArabic,
      oldTx.dateTime,
    );

    // Reverse account balance change
    if (oldTx.transactionType) {
      account.withdraw(oldTx.amount); // Remove old income
      await _goalService.updateAllGoalsProgress(
        transaction.userId,
        -oldTx.amount, // Reverse goal progress
      );
    } else {
      account.deposit(oldTx.amount); // Reverse old expense
    }

    // STEP 2: Apply the new transaction effects
    if (transaction.transactionType) {
      account.deposit(transaction.amount); // Apply new income
      await _goalService.updateAllGoalsProgress(
        transaction.userId,
        transaction.amount,
      );
    } else {
      account.withdraw(transaction.amount); // Apply new expense
    }
    await _accountRepo.updateAccount(account);

    // Apply new budget tracking
    final newCategory = await _categoryRepo.getCategoryById(
      transaction.categoryId,
    );
    double newBudgetEffect = transaction.transactionType
        ? -transaction.amount
        : transaction.amount;
    await _budgetService.updateBudgetTracking(
      transaction.userId,
      transaction.categoryId,
      newBudgetEffect,
      newCategory?.name ?? "Unknown",
      isArabic,
      transaction.dateTime,
    );

    // Save updated transaction to database
    await _transactionRepo.updateTransaction(transaction);
  }

  // Delete a transaction
  // Reverses all effects (account balance, budget tracking, goal progress)
  Future<void> deleteTransaction(int transactionId) async {
    final transaction = await _transactionRepo.getTransactionById(
      transactionId,
    );
    if (transaction == null) return;

    // Reverse account balance change
    final account = await _accountRepo.getAccountByUserId(transaction.userId);
    if (account != null) {
      if (transaction.transactionType) {
        account.withdraw(transaction.amount); // Remove income
      } else {
        account.deposit(transaction.amount); // Refund expense
      }
      await _accountRepo.updateAccount(account);
    }

    // Reverse budget tracking
    final category = await _categoryRepo.getCategoryById(
      transaction.categoryId,
    );
    final isArabic = await _isArabic();

    double budgetEffect = transaction.transactionType
        ? -transaction.amount
        : transaction.amount;
    await _budgetService.updateBudgetTracking(
      transaction.userId,
      transaction.categoryId,
      -budgetEffect, // Reverse the budget effect
      category?.name ?? "Unknown",
      isArabic,
      transaction.dateTime,
    );

    // Reverse goal progress for income transactions
    if (transaction.transactionType) {
      await _goalService.updateAllGoalsProgress(
        transaction.userId,
        -transaction.amount,
      );
    }

    // Delete from database
    await _transactionRepo.deleteTransaction(transactionId);
  }

  // Get current account balance for a user
  Future<double> getCurrentBalance(int userId) async {
    final account = await _accountRepo.getAccountByUserId(userId);
    return account?.balance ?? 0.0;
  }

  // Get all transactions for a user
  Future<List<Transaction>> getUserTransactions(int userId) async {
    return await _transactionRepo.getTransactionsByUser(userId);
  }

  // Get most recent transactions for a user (limited by default to 5)
  Future<List<Transaction>> getRecentTransactions(
    int userId, {
    int limit = 5,
  }) async {
    final all = await _transactionRepo.getTransactionsByUser(userId);
    return all.take(limit).toList();
  }
}