import '../models/expense.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE income(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      month TEXT,
      income REAL
    )
  ''');
    await db.execute('''
  CREATE TABLE categories(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE
  )
''');
    await db.execute('''
    CREATE TABLE expenses(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      expenseDate TEXT,
      category TEXT,
      item TEXT,
      amount REAL,
      paymentMethod TEXT
    )
  ''');
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await instance.database;

    final result = await db.query('expenses', orderBy: 'id DESC');

    return result.map((json) {
      return Expense(
        id: json['id'] as int,
        expenseDate: json['expenseDate'] as String,
        category: json['category'] as String,
        item: json['item'] as String,
        amount: (json['amount'] as num).toDouble(),
        paymentMethod: json['paymentMethod'] as String,
      );
    }).toList();
  }

  Future<int> updateExpense(int id, String item, double amount) async {
    final db = await instance.database;

    return await db.update(
      'expenses',
      {'item': item, 'amount': amount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await instance.database;

    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await instance.database;

    return await db.insert('expenses', expense.toMap());
  }

  Future<int> saveIncome(String month, double income) async {
    final db = await instance.database;

    return await db.insert('income', {'month': month, 'income': income});
  }

  Future<double> getCurrentMonthIncome(String month) async {
    final db = await instance.database;

    final result = await db.query(
      'income',
      where: 'month = ?',
      whereArgs: [month],
    );

    print('Searching income for month: $month');
    print('Rows found: ${result.length}');
    print(result);

    if (result.isEmpty) return 0;

    return (result.last['income'] as num).toDouble();
  }

  Future<int> insertCategory(String name) async {
    final db = await instance.database;

    return await db.insert('categories', {
      'name': name,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<String>> getCategories() async {
    final db = await instance.database;

    final result = await db.query('categories', orderBy: 'name');

    return result.map((e) => e['name'] as String).toList();
  }

  Future<Map<String, double>> getMonthlyExpenseTotals() async {
    final db = await database;

    final expenses = await db.query('expenses');

    Map<String, double> monthlyTotals = {};

    for (var expense in expenses) {
      final date = expense['expenseDate'] as String;

      // date format = dd-MM-yyyy
      final month = date.substring(0, 7);

      final amount = (expense['amount'] as num).toDouble();

      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + amount;
    }

    return monthlyTotals;
  }
}
