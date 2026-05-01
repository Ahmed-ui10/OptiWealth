import '../database_helper.dart';
import '../../models/category_model.dart';

class CategoryRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Category>> getAllCategories() async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

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