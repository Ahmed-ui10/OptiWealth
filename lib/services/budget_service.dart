import '../models/budget_model.dart';
import '../models/notification_model.dart';
import '../repositories/budget_repository.dart';
import 'notification_service.dart';

// English to Arabic translation mapping for budget categories
const Map<String, String> _enToAr = {
  'Food': 'طعام',
  'Transport': 'مواصلات',
  'Bills': 'فواتير',
  'Entertainment': 'ترفيه',
  'Salary': 'مرتب',
  'Gift': 'هدية',
};

// Arabic to English translation mapping for budget categories
const Map<String, String> _arToEn = {
  'طعام': 'Food',
  'مواصلات': 'Transport',
  'فواتير': 'Bills',
  'ترفيه': 'Entertainment',
  'مرتب': 'Salary',
  'هدية': 'Gift',
};

// Helper function to translate category names based on language
String _translateCategory(String name, bool isArabic) {
  if (isArabic) {
    return _enToAr[name] ?? name;
  } else {
    return _arToEn[name] ?? name;
  }
}

// Service class for budget management including CRUD operations and expense tracking
class BudgetService {
  final BudgetRepository _budgetRepo = BudgetRepository();
  final NotificationService _notificationService = NotificationService();

  // Create a new budget
  Future<void> createBudget(Budget budget) async {
    await _budgetRepo.createBudget(budget);
  }

  // Update an existing budget
  Future<void> updateBudget(Budget budget) async {
    await _budgetRepo.updateBudget(budget);
  }

  // Delete a budget by ID (basic deletion without transfer logic)
  Future<void> deleteBudget(int? budgetId) async {
    if (budgetId == null || budgetId == 0) return;
    await _budgetRepo.deleteBudget(budgetId);
  }

  // Delete a budget with transfer of remaining expenses to the next budget period
  Future<void> deleteBudgetWithTransfer(int budgetId, int userId) async {
    final budgetToDelete = await _budgetRepo.getBudgetById(budgetId);
    if (budgetToDelete == null) return;
    
    final allBudgets = await _budgetRepo.getBudgetsByUser(
      userId,
      activeOnly: false,
    );
    
    // Find budgets with same category and sort by start date
    final sameCategoryBudgets =
        allBudgets
            .where((b) => b.categoryId == budgetToDelete.categoryId)
            .toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));
            
    int index = sameCategoryBudgets.indexWhere((b) => b.budgetId == budgetId);
    
    // If there's a next budget, transfer the spent amount to it
    if (index != -1 && index + 1 < sameCategoryBudgets.length) {
      final nextBudget = sameCategoryBudgets[index + 1];
      nextBudget.addExpense(budgetToDelete.spentAmount);
      await _budgetRepo.updateBudget(nextBudget);
    }
    
    await _budgetRepo.deleteBudget(budgetId);
  }

  // Track expenses against budgets and send notifications when thresholds are reached
  Future<void> updateBudgetTracking(
    int userId,
    int categoryId,
    double amount,
    String categoryNameRaw,
    bool isArabic,
    DateTime transactionDate,
  ) async {
    if (amount == 0) return;

    final allBudgets = await _budgetRepo.getBudgetsByUser(
      userId,
      activeOnly: false,
    );
    final relevantBudgets = <Budget>[];

    // Find budgets that overlap with the transaction date
    for (var b in allBudgets) {
      if (b.categoryId != categoryId) continue;
      if (b.createdAt.isAfter(transactionDate)) continue;

      final start = DateTime(
        b.startDate.year,
        b.startDate.month,
        b.startDate.day,
      );
      final end = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);
      final txDate = DateTime(
        transactionDate.year,
        transactionDate.month,
        transactionDate.day,
      );

      // Check if transaction date falls within budget period
      if (txDate.isAfter(start.subtract(const Duration(days: 1))) &&
          txDate.isBefore(end.add(const Duration(days: 1)))) {
        relevantBudgets.add(b);
      }
    }

    if (relevantBudgets.isEmpty) return;

    // Sort budgets chronologically
    relevantBudgets.sort((a, b) => a.startDate.compareTo(b.startDate));
    double remaining = amount;
    final notificationsToSend = <NotificationModel>[];

    // Handle expense (positive amount)
    if (amount > 0) {
      for (int i = 0; i < relevantBudgets.length; i++) {
        final budget = relevantBudgets[i];
        if (remaining <= 0) break;
        
        final availableSpace = budget.budgetAmount - budget.spentAmount;
        // Skip this budget if full and there are more budgets
        if (availableSpace <= 0 && i < relevantBudgets.length - 1) continue; 
        
        final toAdd = remaining > availableSpace ? availableSpace : remaining;
        budget.addExpense(toAdd);
        await _budgetRepo.updateBudget(budget);
        remaining -= toAdd;

        final translatedCat = _translateCategory(categoryNameRaw, isArabic);
        
        // Send notification if budget is exceeded
        if (budget.isExceeded()) {
          notificationsToSend.add(
            NotificationModel(
              notificationId: null,
              userId: userId,
              type: 'BUDGET_EXCEEDED',
              message: isArabic
                  ? 'تجاوزت الميزانية لفئة $translatedCat'
                  : 'Budget exceeded for category $translatedCat',
              timestamp: DateTime.now(),
            ),
          );
        } 
        // Send warning notification if threshold is reached
        else if (budget.spentPercentage >= budget.alertThreshold / 100) {
          final percent = (budget.spentPercentage * 100).toInt();
          notificationsToSend.add(
            NotificationModel(
              notificationId: null,
              userId: userId,
              type: 'BUDGET_WARNING',
              message: isArabic
                  ? 'لقد استخدمت $percent% من ميزانيتك لـ $translatedCat'
                  : 'You have used $percent% of your budget for $translatedCat',
              timestamp: DateTime.now(),
            ),
          );
        }
      }
      
      // Send notification for amount spent beyond all budgets
      if (remaining > 0) {
        final translatedCat = _translateCategory(categoryNameRaw, isArabic);
        notificationsToSend.add(
          NotificationModel(
            notificationId: null,
            userId: userId,
            type: 'NO_BUDGET',
            message: isArabic
                ? 'أنفقت $remaining خارج الميزانية'
                : 'You spent an extra $remaining outside budget',
            timestamp: DateTime.now(),
          ),
        );
      }
    } 
    // Handle income (negative amount) - deduct from budgets in reverse chronological order
    else {
      double toDeduct = -remaining;
      final reversed = relevantBudgets.reversed.toList(); // Most recent first
      for (int i = 0; i < reversed.length; i++) {
        if (toDeduct <= 0) break;
        final budget = reversed[i];
        final bool isOldest = (i == reversed.length - 1);
        double deduction;
        if (!isOldest) {
          deduction = (toDeduct > budget.spentAmount)
              ? budget.spentAmount
              : toDeduct;
        } else {
          deduction = toDeduct;
        }
        if (deduction.abs() > 0) {
          budget.addExpense(-deduction); // Reduce spent amount
          await _budgetRepo.updateBudget(budget);
          toDeduct -= deduction;
        }
      }
    }

    // Send all accumulated notifications
    for (var notif in notificationsToSend) {
      await _notificationService.notify(notif);
    }
  }

  // Get all active budgets for a user (current date range)
  Future<List<Budget>> getActiveBudgets(int userId) async {
    return await _budgetRepo.getBudgetsByUser(userId, activeOnly: true);
  }
}