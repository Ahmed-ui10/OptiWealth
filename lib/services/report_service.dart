import '../models/financial_report_model.dart';
import '../models/category_model.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/category_repository.dart';

// Service class for generating financial reports (income/expense summaries)
class ReportService {
  final TransactionRepository _transactionRepo = TransactionRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  // Generate a financial report for a user within a date range
  Future<FinancialReport> generateReport(
    int userId,
    DateTime start,
    DateTime end,
  ) async {
    // Normalize dates to full day ranges (start at midnight, end at 23:59:59)
    final startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);

    // Fetch all transactions within the date range
    final transactions = await _transactionRepo.getTransactionsByUser(
      userId,
      startDate: startDate,
      endDate: endDate,
    );

    // Get all categories for name lookups
    final categories = await _categoryRepo.getAllCategories();
    
    // Data aggregators
    final Map<String, double> categoryTotals = {}; // Expenses grouped by category
    final Map<String, double> incomeByMethod = {}; // Income grouped by payment method
    final Map<String, double> expenseByMethod = {}; // Expenses grouped by payment method
    double totalIncome = 0, totalExpense = 0;

    // Process each transaction
    for (var t in transactions) {
      if (t.transactionType) {
        // Income transaction
        totalIncome += t.amount;
        incomeByMethod[t.paymentMethod] =
            (incomeByMethod[t.paymentMethod] ?? 0) + t.amount;
      } else {
        // Expense transaction
        totalExpense += t.amount;
        expenseByMethod[t.paymentMethod] =
            (expenseByMethod[t.paymentMethod] ?? 0) + t.amount;
        
        // Find category name for this expense
        final cat = categories.firstWhere(
          (c) => c.categoryId == t.categoryId,
          orElse: () =>
              Category(categoryId: -1, name: 'Unknown', type: 'expense'),
        );
        // Aggregate expense by category
        categoryTotals[cat.name] = (categoryTotals[cat.name] ?? 0) + t.amount;
      }
    }

    // Return the compiled report
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