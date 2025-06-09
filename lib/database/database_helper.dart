import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/investment_account.dart';
import '../model/investment.dart';
import '../model/funding_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'investment.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        currency TEXT,
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE investments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountId INTEGER,
        symbol TEXT,
        buyPrice REAL,
        quantity INTEGER,
        fee REAL,
        tax REAL,
        otherCost REAL,
        currentPrice REAL,
        buyDate INTEGER,
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE funding_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountId INTEGER,
        transferDate INTEGER,
        sourceAmount REAL,
        exchangeRate REAL,
        targetAmount REAL,
        wireFee REAL,
        note TEXT
      )
    ''');
  }

  Future<int> insertAccount(InvestmentAccount account) async {
    final db = await database;
    return db.insert('accounts', account.toMap());
  }

  Future<List<InvestmentAccount>> getAccounts() async {
    final db = await database;
    final result = await db.query('accounts');
    return result.map((e) => InvestmentAccount.fromMap(e)).toList();
  }

  Future<int> insertInvestment(Investment investment) async {
    final db = await database;
    return db.insert('investments', investment.toMap());
  }

  Future<List<Investment>> getInvestments(int accountId) async {
    final db = await database;
    final result = await db.query('investments',
        where: 'accountId = ?', whereArgs: [accountId]);
    return result.map((e) => Investment.fromMap(e)).toList();
  }

  Future<int> deleteInvestment(int id) async {
    final db = await database;
    return db.delete('investments', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertFundingRecord(FundingRecord record) async {
    final db = await database;
    return db.insert('funding_records', record.toMap());
  }

  Future<List<FundingRecord>> getFundingRecords(int accountId) async {
    final db = await database;
    final result = await db.query('funding_records',
        where: 'accountId = ?', whereArgs: [accountId]);
    return result.map((e) => FundingRecord.fromMap(e)).toList();
  }
}

