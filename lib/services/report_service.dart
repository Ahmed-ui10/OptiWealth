import '../models/financial_report_model.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/category_repository.dart';

class ReportService {
  final TransactionRepository _transactionRepo = TransactionRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  Future<FinancialReport> generateReport(int userId, DateTime start, DateTime end) async {
    final transactions = await _transactionRepo.getTransactionsByUser(userId, startDate: start, endDate: end);
    final categories = await _categoryRepo.getAllCategories();
    final Map<String, double> categoryTotals = {};
    double totalIncome = 0, totalExpense = 0;

    for (var t in transactions) {
      if (t.transactionType) totalIncome += t.amount;
      else {
        totalExpense += t.amount;
        final catName = categories.firstWhere((c) => c.categoryId.toString() == t.categoryId).name;
        categoryTotals[catName] = (categoryTotals[catName] ?? 0) + t.amount;
      }
    }
    return FinancialReport(
      reportPeriodStart: start,
      reportPeriodEnd: end,
      categoryTotals: categoryTotals,
      incomeVsExpenseData: {'income': totalIncome, 'expense': totalExpense},
    );
  }
}