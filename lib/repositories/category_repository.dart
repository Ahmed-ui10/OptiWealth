import '../database_helper.dart';
import '../../models/category_model.dart';

// Repository class for handling Category database operations
class CategoryRepository {
  final dbHelper = DatabaseHelper(); // Database helper instance

  // Retrieve all categories from the database
  Future<List<Category>> getAllCategories() async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  // Retrieve a single category by its ID (returns null if not found)
  Future<Category?> getCategoryById(int id) async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'categoryId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return Category.fromMap(maps.first);
    return null;
  }
}