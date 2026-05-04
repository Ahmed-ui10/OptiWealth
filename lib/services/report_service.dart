import '../models/financial_report_model.dart';
import '../models/category_model.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/category_repository.dart';

class ReportService {
  final TransactionRepository _transactionRepo = TransactionRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  Future<FinancialReport> generateReport(
    int userId,
    DateTime start,
    DateTime end,
  ) async {
    final startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);

    final transactions = await _transactionRepo.getTransactionsByUser(
      userId,
      startDate: startDate,
      endDate: endDate,
    );

    final categories = await _categoryRepo.getAllCategories();
    final Map<String, double> categoryTotals = {};
    final Map<String, double> incomeByMethod = {};
    final Map<String, double> expenseByMethod = {};
    double totalIncome = 0, totalExpense = 0;

    for (var t in transactions) {
      if (t.transactionType) {
        totalIncome += t.amount;
        incomeByMethod[t.paymentMethod] =
            (incomeByMethod[t.paymentMethod] ?? 0) + t.amount;
      } else {
        totalExpense += t.amount;
        expenseByMethod[t.paymentMethod] =
            (expenseByMethod[t.paymentMethod] ?? 0) + t.amount;
        final cat = categories.firstWhere(
          (c) => c.categoryId == t.categoryId,
          orElse: () =>
              Category(categoryId: -1, name: 'Unknown', type: 'expense'),
        );
        categoryTotals[cat.name] = (categoryTotals[cat.name] ?? 0) + t.amount;
      }
    }

    return FinancialReport(
      reportPeriodStart: start,
      reportPeriodEnd: end,
      categoryTotals: categoryTotals,
      incomeVsExpenseData: {'income': totalIncome, 'expense': totalExpense},
      incomeByMethod: incomeByMethod,
      expenseByMethod: expenseByMethod,
    );
  }
}
