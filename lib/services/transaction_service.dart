import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/budget_repository.dart';
import '../repositories/account_repository.dart';
import 'budget_service.dart';

class TransactionService {
  final TransactionRepository _transactionRepo = TransactionRepository();
  final AccountRepository _accountRepo = AccountRepository();
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
      await _budgetService.updateBudgetTracking(transaction.userId, transaction.categoryId, transaction.amount);
    }
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