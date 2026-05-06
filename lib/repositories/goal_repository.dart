import '../database_helper.dart';
import '../../models/financial_goal_model.dart';

// Repository class for handling Financial Goal database operations
class GoalRepository {
  final dbHelper = DatabaseHelper(); // Database helper instance

  // Create a new financial goal record in the database
  Future<int> createGoal(FinancialGoal goal) async {
    final db = await dbHelper.db;
    return await db.insert('goals', goal.toMap());
  }

  // Retrieve all financial goals for a specific user
  Future<List<FinancialGoal>> getGoalsByUser(int userId) async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((m) => FinancialGoal.fromMap(m)).toList();
  }

  // Retrieve a single financial goal by its ID (returns null if not found)
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

  // Update an existing financial goal record
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