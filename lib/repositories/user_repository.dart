import '../database_helper.dart';
import '../../models/user_model.dart';

// Repository class for handling User database operations
class UserRepository {
  final dbHelper = DatabaseHelper(); // Database helper instance

  // Create a new user record in the database
  // Removes id field if it's null or 0 to let SQLite auto-generate the ID
  Future<int> createUser(User user) async {
    final db = await dbHelper.db;
    Map<String, dynamic> map = user.toMap();
    // Remove id field if it's null or 0 (auto-increment will handle it)
    map.removeWhere((key, value) => key == 'id' && (value == null || value == 0));
    return await db.insert('users', map);
  }

  // Retrieve a user by their email address (returns null if not found)
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

  // Retrieve a user by their ID (returns null if not found)
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

  // Update an existing user record
  Future<int> updateUser(User user) async {
    final db = await dbHelper.db;
    return await db.update('users', user.toMap(),
        where: 'id = ?', whereArgs: [user.id]);
  }
}