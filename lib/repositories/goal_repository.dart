import '../database_helper.dart';
import '../../models/financial_goal_model.dart';

class GoalRepository {
  final dbHelper = DatabaseHelper();

  Future<int> createGoal(FinancialGoal goal) async {
    final db = await dbHelper.db;
    return await db.insert('goals', goal.toMap());
  }

  Future<List<FinancialGoal>> getGoalsByUser(int userId) async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((m) => FinancialGoal.fromMap(m)).toList();
  }

  Future<FinancialGoal?> getGoalById(int id) async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return FinancialGoal.fromMap(maps.first);
    return null;
  }

  Future<int> updateGoal(FinancialGoal goal) async {
    final db = await dbHelper.db;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }
}
