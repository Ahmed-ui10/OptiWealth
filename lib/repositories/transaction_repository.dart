import '../database_helper.dart';
import '../../models/transaction_model.dart';

class TransactionRepository {
  final dbHelper = DatabaseHelper();

  Future<int> createTransaction(Transaction transaction) async {
    final db = await dbHelper.db;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await dbHelper.db;
    return await db.update('transactions', transaction.toMap(),
        where: 'id = ?', whereArgs: [transaction.id]);
  }

  Future<int> deleteTransaction(int id) async {
    final db = await dbHelper.db;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<Transaction?> getTransactionById(int id) async {
    final db = await dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return Transaction.fromMap(maps.first);
    return null;
  }

  Future<List<Transaction>> getTransactionsByUser(int userId,
      {int? categoryId, DateTime? startDate, DateTime? endDate}) async {
    final db = await dbHelper.db;
    String where = 'userId = ?';
    List<dynamic> args = [userId];
    if (categoryId != null) {
      where += ' AND categoryId = ?';
      args.add(categoryId);
    }
    if (startDate != null) {
      where += ' AND dateTime >= ?';
      args.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      where += ' AND dateTime <= ?';
      args.add(endDate.toIso8601String());
    }
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: where,
      whereArgs: args,
      orderBy: 'dateTime DESC',
    );
    return maps.map((m) => Transaction.fromMap(m)).toList();
  }
}