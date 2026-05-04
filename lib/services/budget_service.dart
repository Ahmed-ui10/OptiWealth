import '../models/budget_model.dart';
import '../models/notification_model.dart';
import '../repositories/budget_repository.dart';
import 'notification_service.dart';

const Map<String, String> _enToAr = {
  'Food': 'طعام',
  'Transport': 'مواصلات',
  'Bills': 'فواتير',
  'Entertainment': 'ترفيه',
  'Salary': 'مرتب',
  'Gift': 'هدية',
};

const Map<String, String> _arToEn = {
  'طعام': 'Food',
  'مواصلات': 'Transport',
  'فواتير': 'Bills',
  'ترفيه': 'Entertainment',
  'مرتب': 'Salary',
  'هدية': 'Gift',
};

String _translateCategory(String name, bool isArabic) {
  if (isArabic) {
    return _enToAr[name] ?? name;
  } else {
    return _arToEn[name] ?? name;
  }
}

class BudgetService {
  final BudgetRepository _budgetRepo = BudgetRepository();
  final NotificationService _notificationService = NotificationService();

  Future<void> createBudget(Budget budget) async {
    await _budgetRepo.createBudget(budget);
  }

  Future<void> updateBudget(Budget budget) async {
    await _budgetRepo.updateBudget(budget);
  }

  Future<void> deleteBudget(int? budgetId) async {
    if (budgetId == null || budgetId == 0) return;
    await _budgetRepo.deleteBudget(budgetId);
  }

  Future<void> updateBudgetTracking(
    int userId,
    int categoryId,
    double amount,
    String categoryNameRaw,
    bool isArabic,
  ) async {
    print(
      '🔍 updateBudgetTracking: userId=$userId, catId=$categoryId, amount=$amount',
    );
    final budgets = await _budgetRepo.getBudgetsByUser(
      userId,
      activeOnly: true,
    );
    print('📋 Found ${budgets.length} active budgets');
    for (var b in budgets) {
      print(
        '   - budget: id=${b.budgetId}, catId=${b.categoryId}, spent=${b.spentAmount}, limit=${b.budgetAmount}, dates=${b.startDate.toLocal()} -> ${b.endDate.toLocal()}',
      );
    }
    Budget? targetBudget;
    for (var b in budgets) {
      if (b.categoryId == categoryId) {
        targetBudget = b;
        break;
      }
    }
    if (targetBudget == null) {
      print('❌ No budget found for categoryId $categoryId');
      return;
    }

    final oldSpent = targetBudget.spentAmount;
    targetBudget.addExpense(amount); 
    print(
      '💰 Updated spent from $oldSpent to ${targetBudget.spentAmount} (change: ${targetBudget.spentAmount - oldSpent})',
    );
    await _budgetRepo.updateBudget(targetBudget);

    final translatedCat = _translateCategory(categoryNameRaw, isArabic);

    if (targetBudget.isExceeded()) {
      _notificationService.notify(
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
    } else if (targetBudget.spentPercentage >=
        (targetBudget.alertThreshold / 100)) {
      final percent = (targetBudget.spentPercentage * 100).toInt();
      _notificationService.notify(
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

  Future<List<Budget>> getActiveBudgets(int userId) async {
    return await _budgetRepo.getBudgetsByUser(userId, activeOnly: true);
  }
}
