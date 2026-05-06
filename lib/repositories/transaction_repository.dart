import '../database_helper.dart';
import '../../models/transaction_model.dart';

// Repository class for handling Transaction database operations
class TransactionRepository {
  final dbHelper = DatabaseHelper(); // Database helper instance

  // Create a new transaction record in the database
  Future<int> createTransaction(Transaction transaction) async {
    final db = await dbHelper.db;
    return await db.insert('transactions', transaction.toMap());
  }

  // Update an existing transaction record
  Future<int> updateTransaction(Transaction transaction) async {
    final db = await dbHelper.db;
    return await db.update('transactions', transaction.toMap(),
        where: 'id = ?', whereArgs: [transaction.id]);
  }

  // Delete a transaction record by ID
  Future<int> deleteTransaction(int id) async {
    final db = await dbHelper.db;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Retrieve a single transaction by its ID (returns null if not found)
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

  // Retrieve transactions for a specific user with optional filters
  // - categoryId: filter by specific category
  // - startDate: filter transactions on or after this date
  // - endDate: filter transactions on or before this date
  Future<List<Transaction>> getTransactionsByUser(int userId,
      {int? categoryId, DateTime? startDate, DateTime? endDate}) async {
    final db = await dbHelper.db;
    String where = 'userId = ?';
    List<dynamic> args = [userId];
    
    // Add category filter if provided
    if (categoryId != null) {
      where += ' AND categoryId = ?';
      args.add(categoryId);
    }
    
    // Add start date filter if provided
    if (startDate != null) {
      where += ' AND dateTime >= ?';
      args.add(startDate.toIso8601String());
    }
    
    // Add end date filter if provided
    if (endDate != null) {
      where += ' AND dateTime <= ?';
      args.add(endDate.toIso8601String());
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: where,
      whereArgs: args,
      orderBy: 'dateTime DESC', // Most recent transactions first
    );
    return maps.map((m) => Transaction.fromMap(m)).toList();
  }
}