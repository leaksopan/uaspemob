import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static const _databaseName = 'catatan_pengeluaran.db';
  static const _databaseVersion = 1;

  // Table names
  static const usersTable = 'users';
  static const expensesTable = 'expenses';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // Initialize for web platform
  static void _initializeForWeb() {
    if (kIsWeb) {
      // Set the database factory for web
      databaseFactory = databaseFactoryFfiWeb;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize for web if needed
    _initializeForWeb();

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;

    if (kIsWeb) {
      // For web platform, use simple path
      path = _databaseName;
    } else {
      // For mobile platforms, use standard path
      path = join(await getDatabasesPath(), _databaseName);
    }

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE $usersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create expenses table
    await db.execute('''
      CREATE TABLE $expensesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        image_path TEXT,
        date TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $usersTable (id) ON DELETE CASCADE
      )
    ''');
  }

  // User operations
  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert(usersTable, user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      usersTable,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      usersTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // Expense operations
  Future<int> insertExpense(Expense expense) async {
    Database db = await database;
    return await db.insert(expensesTable, expense.toMap());
  }

  Future<List<Expense>> getExpensesByUserId(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      expensesTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return result.map((map) => Expense.fromMap(map)).toList();
  }

  Future<int> updateExpense(Expense expense) async {
    Database db = await database;
    return await db.update(
      expensesTable,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    Database db = await database;
    return await db.delete(expensesTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalExpensesByUserId(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $expensesTable WHERE user_id = ?',
      [userId],
    );

    return result.first['total'] ?? 0.0;
  }

  Future<List<Map<String, dynamic>>> getExpensesByCategory(int userId) async {
    Database db = await database;
    return await db.rawQuery(
      '''
      SELECT category, SUM(amount) as total 
      FROM $expensesTable 
      WHERE user_id = ? 
      GROUP BY category 
      ORDER BY total DESC
    ''',
      [userId],
    );
  }

  Future<void> close() async {
    Database db = await database;
    db.close();
  }
}
