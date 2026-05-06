import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Singleton helper class for SQLite database initialization and management
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db; // Singleton database instance

  // Get database instance (creates if doesn't exist)
  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  // Initialize database with path and version
  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'budgeting_app.db');
    return await openDatabase(
      path,
      version: 5, // Current database version
      onCreate: _onCreate, // Called when DB is first created
      onUpgrade: _onUpgrade, // Called when version increases
    );
  }

  // Called when database is created for the first time
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _insertDefaultCategories(db);
  }

  // Handle database migrations from older versions
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      try {
        // Add createdAt column to budgets table (version 4 migration)
        await db.execute('ALTER TABLE budgets ADD COLUMN createdAt TEXT');
        // Populate createdAt with startDate for existing records
        await db.execute('UPDATE budgets SET createdAt = startDate WHERE createdAt IS NULL');
      } catch (e) {
        print('Error upgrading to version 4: $e');
      }
    }
    if (oldVersion < 5) {
      // Version 5 migration (currently empty, reserved for future changes)
    }
  }

  // Create all database tables
  Future<void> _createTables(Database db) async {
    // Users table - stores account information
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

    // Accounts table - stores user financial accounts (balance, currency)
    await db.execute('''
      CREATE TABLE accounts (
        accountId INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        balance REAL NOT NULL,
        currency TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Categories table - predefined income/expense categories
    await db.execute('''
      CREATE TABLE categories (
        categoryId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    // Transactions table - records all financial transactions
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        transactionType INTEGER NOT NULL, -- 1 for income, 0 for expense
        amount REAL NOT NULL,
        dateTime TEXT NOT NULL,
        description TEXT,
        paymentMethod TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (categoryId) REFERENCES categories (categoryId)
      )
    ''');

    // Budgets table - stores budget plans for categories
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
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (categoryId) REFERENCES categories (categoryId)
      )
    ''');

    // Goals table - stores financial savings goals
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

    // Notifications table - stores user notifications/alerts
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

  // Insert default categories (Arabic names) into the categories table
  Future<void> _insertDefaultCategories(Database db) async {
    await db.rawInsert(
        "INSERT INTO categories (name, type) VALUES "
        "('طعام', 'expense'), "        // Food
        "('مواصلات', 'expense'), "     // Transport
        "('فواتير', 'expense'), "      // Bills
        "('ترفيه', 'expense'), "       // Entertainment
        "('مرتب', 'income'), "         // Salary
        "('هدية', 'income')");         // Gift
  }
}