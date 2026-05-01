import '../database_helper.dart';
import '../../models/user_model.dart';

class UserRepository {
  final dbHelper = DatabaseHelper();

  Future<int> createUser(User user) async {
    final db = await dbHelper.db;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<User?> getUserById(int id) async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await dbHelper.db;
    return await db.update('users', user.toMap(),
        where: 'id = ?', whereArgs: [user.id]);
  }
}