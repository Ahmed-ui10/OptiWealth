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

  Future<void> deleteBudgetWithTransfer(int budgetId, int userId) async {
    final budgetToDelete = await _budgetRepo.getBudgetById(budgetId);
    if (budgetToDelete == null) return;
    final allBudgets = await _budgetRepo.getBudgetsByUser(
      userId,
      activeOnly: false,
    );
    final sameCategoryBudgets =
        allBudgets
            .where((b) => b.categoryId == budgetToDelete.categoryId)
            .toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));
    int index = sameCategoryBudgets.indexWhere((b) => b.budgetId == budgetId);
    if (index != -1 && index + 1 < sameCategoryBudgets.length) {
      final nextBudget = sameCategoryBudgets[index + 1];
      nextBudget.addExpense(budgetToDelete.spentAmount);
      await _budgetRepo.updateBudget(nextBudget);
    }
    await _budgetRepo.deleteBudget(budgetId);
  }

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

      if (txDate.isAfter(start.subtract(const Duration(days: 1))) &&
          txDate.isBefore(end.add(const Duration(days: 1)))) {
        relevantBudgets.add(b);
      }
    }

    if (relevantBudgets.isEmpty) return;

    relevantBudgets.sort((a, b) => a.startDate.compareTo(b.startDate));
    double remaining = amount;
    final notificationsToSend = <NotificationModel>[];

    if (amount > 0) {
      for (int i = 0; i < relevantBudgets.length; i++) {
        final budget = relevantBudgets[i];
        if (remaining <= 0) break;
        final availableSpace = budget.budgetAmount - budget.spentAmount;
        if (availableSpace <= 0 && i < relevantBudgets.length - 1)
          continue; 
        final toAdd = remaining > availableSpace ? availableSpace : remaining;
        budget.addExpense(toAdd);
        await _budgetRepo.updateBudget(budget);
        remaining -= toAdd;

        final translatedCat = _translateCategory(categoryNameRaw, isArabic);
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
        } else if (budget.spentPercentage >= budget.alertThreshold / 100) {
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
    } else {
      double toDeduct = -remaining;
      final reversed = relevantBudgets.reversed.toList(); 
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
          budget.addExpense(-deduction);
          await _budgetRepo.updateBudget(budget);
          toDeduct -= deduction;
        }
      }
    }

    for (var notif in notificationsToSend) {
      await _notificationService.notify(notif);
    }
  }

  Future<List<Budget>> getActiveBudgets(int userId) async {
    return await _budgetRepo.getBudgetsByUser(userId, activeOnly: true);
  }
}
