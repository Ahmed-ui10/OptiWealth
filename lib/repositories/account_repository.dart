import '../database_helper.dart';
import '../../models/account_model.dart';

class AccountRepository {
  final dbHelper = DatabaseHelper();

  Future<int> createAccount(Account account) async {
    final db = await dbHelper.db;
    return await db.insert('accounts', account.toMap());
  }

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

  Future<int> updateAccount(Account account) async {
    final db = await dbHelper.db;
    return await db.update('accounts', account.toMap(),
        where: 'accountId = ?', whereArgs: [account.accountId]);
  }
}