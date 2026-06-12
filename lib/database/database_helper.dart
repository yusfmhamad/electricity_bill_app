import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bill_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'electricity_bills.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month TEXT NOT NULL,
        unit_used REAL NOT NULL,
        rebate_percentage REAL NOT NULL,
        total_charges REAL NOT NULL,
        final_cost REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertBill(BillRecord bill) async {
    final db = await database;
    return await db.insert('bills', bill.toMap());
  }

  Future<List<BillRecord>> getAllBills() async {
    final db = await database;
    final maps = await db.query('bills', orderBy: 'id DESC');
    return maps.map((m) => BillRecord.fromMap(m)).toList();
  }

  Future<BillRecord?> getBillById(int id) async {
    final db = await database;
    final maps = await db.query('bills', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return BillRecord.fromMap(maps.first);
  }

  Future<int> updateBill(BillRecord bill) async {
    final db = await database;
    return await db.update(
      'bills',
      bill.toMap(),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  Future<int> deleteBill(int id) async {
    final db = await database;
    return await db.delete('bills', where: 'id = ?', whereArgs: [id]);
  }
}
