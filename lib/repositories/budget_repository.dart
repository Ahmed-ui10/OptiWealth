import '../database_helper.dart';
import '../../models/budget_model.dart';

// Repository class for handling Budget database operations
class BudgetRepository {
  final dbHelper = DatabaseHelper(); // Database helper instance

  // Create a new budget record in the database
  Future<int> createBudget(Budget budget) async {
    final db = await dbHelper.db;
    return await db.insert('budgets', budget.toMap());
  }

  // Update an existing budget record
  Future<int> updateBudget(Budget budget) async {
    final db = await dbHelper.db;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'budgetId = ?',
      whereArgs: [budget.budgetId],
    );
  }

  // Delete a budget record by ID
  Future<int> deleteBudget(int budgetId) async {
    final db = await dbHelper.db;
    return await db.delete(
      'budgets',
      where: 'budgetId = ?',
      whereArgs: [budgetId],
    );
  }

  // Retrieve a single budget by its ID (returns null if not found)
  Future<Budget?> getBudgetById(int budgetId) async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'budgetId = ?',
      whereArgs: [budgetId],
    );
    if (maps.isNotEmpty) return Budget.fromMap(maps.first);
    return null;
  }

  // Retrieve all budgets for a specific user
  // If activeOnly is true, only returns budgets where current date is between startDate and endDate
  Future<List<Budget>> getBudgetsByUser(
    int userId, {
    bool activeOnly = false,
  }) async {
    final db = await dbHelper.db;
    String where = 'userId = ?';
    List<dynamic> args = [userId];
    
    // Add date range filter for active budgets only
    if (activeOnly) {
      final now = DateTime.now();
      final nowIso = now.toIso8601String();
      where += ' AND startDate <= ? AND endDate >= ?';
      args.addAll([nowIso, nowIso]);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: where,
      whereArgs: args,
      orderBy: 'startDate ASC', // Order by start date ascending
    );
    return maps.map((m) => Budget.fromMap(m)).toList();
  }
}