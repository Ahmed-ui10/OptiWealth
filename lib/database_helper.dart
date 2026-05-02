import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'budgeting_app.db');
    return await openDatabase(
      path,
      version: 2,          
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, 
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _insertDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {

    await _dropTables(db);
    await _createTables(db);
    await _insertDefaultCategories(db);
  }

  Future<void> _dropTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS notifications');
    await db.execute('DROP TABLE IF EXISTS goals');
    await db.execute('DROP TABLE IF EXISTS budgets');
    await db.execute('DROP TABLE IF EXISTS transactions');
    await db.execute('DROP TABLE IF EXISTS categories');
    await db.execute('DROP TABLE IF EXISTS accounts');
    await db.execute('DROP TABLE IF EXISTS users');
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        passwordHash TEXT NOT NULL,
        currency TEXT NOT NULL,
        language TEXT NOT NULL,
        notificationsEnabled INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE accounts (
        accountId INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        balance REAL NOT NULL,
        currency TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        categoryId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        transactionType INTEGER NOT NULL,
        amount REAL NOT NULL,
        dateTime TEXT NOT NULL,
        description TEXT,
        paymentMethod TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (categoryId) REFERENCES categories (categoryId)
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        budgetId INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        categoryId INTEGER NOT NULL,
        budgetAmount REAL NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        alertThreshold INTEGER NOT NULL,
        spentAmount REAL NOT NULL,
        budgetStatus TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (categoryId) REFERENCES categories (categoryId)
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        goalName TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        currentAmount REAL NOT NULL,
        deadline TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        notificationId INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        type TEXT NOT NULL,
        message TEXT NOT NULL,
        isRead INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _insertDefaultCategories(Database db) async {
    await db.rawInsert(
        "INSERT INTO categories (name, type) VALUES "
        "('طعام', 'expense'), "
        "('مواصلات', 'expense'), "
        "('فواتير', 'expense'), "
        "('ترفيه', 'expense'), "
        "('مرتب', 'income'), "
        "('هدية', 'income')");
  }
}