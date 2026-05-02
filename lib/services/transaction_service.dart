import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/budget_repository.dart';
import '../repositories/account_repository.dart';
import '../repositories/category_repository.dart';
import 'budget_service.dart';

class TransactionService {
  final TransactionRepository _transactionRepo = TransactionRepository();
  final AccountRepository _accountRepo = AccountRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final BudgetService _budgetService = BudgetService();

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
    if (!transaction.transactionType) {
      final category = await _categoryRepo.getCategoryById(transaction.categoryId);
      final String categoryName = category?.name ?? "Unknown Category";
      await _budgetService.updateBudgetTracking(
        transaction.userId,
        transaction.categoryId,
        transaction.amount,
        categoryName,
      );
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final oldTxList = await _transactionRepo.getTransactionsByUser(transaction.userId,
        startDate: transaction.dateTime, endDate: transaction.dateTime);
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
      if (!oldTx.transactionType) {
        final oldCategory = await _categoryRepo.getCategoryById(oldTx.categoryId);
        await _budgetService.updateBudgetTracking(
          transaction.userId,
          oldTx.categoryId,
          -oldTx.amount,
          oldCategory?.name ?? "Unknown",
        );
      }
      if (!transaction.transactionType) {
        final newCategory = await _categoryRepo.getCategoryById(transaction.categoryId);
        await _budgetService.updateBudgetTracking(
          transaction.userId,
          transaction.categoryId,
          transaction.amount,
          newCategory?.name ?? "Unknown",
        );
      }
    }
    await _transactionRepo.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(int transactionId) async {
    final transaction = await _transactionRepo.getTransactionById(transactionId);
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

    if (!transaction.transactionType) {
      final category = await _categoryRepo.getCategoryById(transaction.categoryId);
      await _budgetService.updateBudgetTracking(
        transaction.userId,
        transaction.categoryId,
        -transaction.amount,
        category?.name ?? "Unknown",
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

  Future<List<Transaction>> getRecentTransactions(int userId, {int limit = 5}) async {
    final all = await _transactionRepo.getTransactionsByUser(userId);
    return all.take(limit).toList();
  }
}