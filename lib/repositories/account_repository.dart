import '../database_helper.dart';
import '../../models/account_model.dart';

// Repository class for handling Account database operations
class AccountRepository {
  final dbHelper = DatabaseHelper(); // Database helper instance

  // Create a new account record in the database
  Future<int> createAccount(Account account) async {
    final db = await dbHelper.db;
    return await db.insert('accounts', account.toMap());
  }

  // Retrieve an account by user ID (returns null if not found)
  Future<Account?> getAccountByUserId(int userId) async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) return Account.fromMap(maps.first);
    return null;
  }

  // Update an existing account record
  Future<int> updateAccount(Account account) async {
    final db = await dbHelper.db;
    return await db.update('accounts', account.toMap(),
        where: 'accountId = ?', whereArgs: [account.accountId]);
  }
}