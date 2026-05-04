import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/account_repository.dart';
import '../repositories/category_repository.dart';
import 'budget_service.dart';
import 'goal_service.dart';

class TransactionService {
  final TransactionRepository _transactionRepo = TransactionRepository();
  final AccountRepository _accountRepo = AccountRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final BudgetService _budgetService = BudgetService();
  final GoalService _goalService = GoalService();

  Future<void> addTransaction(Transaction transaction) async {
    if (!transaction.validate()) throw Exception('Invalid transaction');
    await _transactionRepo.createTransaction(transaction);

    final account = await _accountRepo.getAccountByUserId(transaction.userId);
    if (account != null) {
      if (transaction.transactionType) {
        account.deposit(transaction.amount);
      } else {
        account.withdraw(transaction.amount);
      }
      await _accountRepo.updateAccount(account);
    }

    final category = await _categoryRepo.getCategoryById(
      transaction.categoryId,
    );
    final categoryName = category?.name ?? "Unknown Category";
    await _budgetService.updateBudgetTracking(
      transaction.userId,
      transaction.categoryId,
      transaction.amount,
      transaction.transactionType,
      categoryName,
    );

    if (transaction.transactionType) {
      await _goalService.updateAllGoalsProgress(
        transaction.userId,
        transaction.amount,
      );
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final oldTxList = await _transactionRepo.getTransactionsByUser(
      transaction.userId,
      startDate: transaction.dateTime,
      endDate: transaction.dateTime,
    );
    Transaction? oldTx;
    if (oldTxList.isNotEmpty) oldTx = oldTxList.first;
    if (oldTx != null) {
      final account = await _accountRepo.getAccountByUserId(transaction.userId);
      if (account != null) {
        if (oldTx.transactionType) {
          account.withdraw(oldTx.amount);
        } else {
          account.deposit(oldTx.amount);
        }
        if (transaction.transactionType) {
          account.deposit(transaction.amount);
        } else {
          account.withdraw(transaction.amount);
        }
        await _accountRepo.updateAccount(account);
      }

      final oldCategory = await _categoryRepo.getCategoryById(oldTx.categoryId);
      await _budgetService.updateBudgetTracking(
        transaction.userId,
        oldTx.categoryId,
        oldTx.amount,
        oldTx.transactionType,
        oldCategory?.name ?? "Unknown",
      );

      final newCategory = await _categoryRepo.getCategoryById(
        transaction.categoryId,
      );
      await _budgetService.updateBudgetTracking(
        transaction.userId,
        transaction.categoryId,
        transaction.amount,
        transaction.transactionType,
        newCategory?.name ?? "Unknown",
      );

      if (oldTx.transactionType) {
        await _goalService.updateAllGoalsProgress(
          transaction.userId,
          -oldTx.amount,
        );
      }
      if (transaction.transactionType) {
        await _goalService.updateAllGoalsProgress(
          transaction.userId,
          transaction.amount,
        );
      }
    }
    await _transactionRepo.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(int transactionId) async {
    final transaction = await _transactionRepo.getTransactionById(
      transactionId,
    );
    if (transaction == null) return;

    final account = await _accountRepo.getAccountByUserId(transaction.userId);
    if (account != null) {
      if (transaction.transactionType) {
        account.withdraw(transaction.amount);
      } else {
        account.deposit(transaction.amount);
      }
      await _accountRepo.updateAccount(account);
    }

    final category = await _categoryRepo.getCategoryById(
      transaction.categoryId,
    );
    await _budgetService.updateBudgetTracking(
      transaction.userId,
      transaction.categoryId,
      transaction.amount,
      transaction.transactionType,
      category?.name ?? "Unknown",
    );

    if (transaction.transactionType) {
      await _goalService.updateAllGoalsProgress(
        transaction.userId,
        -transaction.amount,
      );
    }

    await _transactionRepo.deleteTransaction(transactionId);
  }

  Future<double> getCurrentBalance(int userId) async {
    final account = await _accountRepo.getAccountByUserId(userId);
    return account?.balance ?? 0.0;
  }

  Future<List<Transaction>> getUserTransactions(int userId) async {
    return await _transactionRepo.getTransactionsByUser(userId);
  }

  Future<List<Transaction>> getRecentTransactions(
    int userId, {
    int limit = 5,
  }) async {
    final all = await _transactionRepo.getTransactionsByUser(userId);
    return all.take(limit).toList();
  }
}
