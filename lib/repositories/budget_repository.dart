import '../database_helper.dart';
import '../../models/budget_model.dart';

class BudgetRepository {
  final dbHelper = DatabaseHelper();

  Future<int> createBudget(Budget budget) async {
    final db = await dbHelper.db;
    return await db.insert('budgets', budget.toMap());
  }

  Future<int> updateBudget(Budget budget) async {
    final db = await dbHelper.db;
    return await db.update('budgets', budget.toMap(),
        where: 'budgetId = ?', whereArgs: [budget.budgetId]);
  }

  Future<int> deleteBudget(int budgetId) async {
    final db = await dbHelper.db;
    return await db.delete('budgets', where: 'budgetId = ?', whereArgs: [budgetId]);
  }

  Future<List<Budget>> getBudgetsByUser(int userId, {bool activeOnly = false}) async {
    final db = await dbHelper.db;
    String where = 'userId = ?';
    List<dynamic> args = [userId];
    if (activeOnly) {
      final now = DateTime.now().toIso8601String();
      where += ' AND startDate <= ? AND endDate >= ?';
      args.addAll([now, now]);
    }
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: where,
      whereArgs: args,
    );
    return maps.map((m) => Budget.fromMap(m)).toList();
  }
}