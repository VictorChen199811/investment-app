import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/investment_account.dart';
import '../model/investment.dart';
import '../model/funding_record.dart';
import 'migration_manager.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal() {
    _initMigrationManager();
  }

  Database? _database;
  late final MigrationManager _migrationManager;

  void _initMigrationManager() {
    // 初始化遷移管理器，註冊所有遷移
    _migrationManager = MigrationManager([
      CreateAccountsTableMigration(),
      AddCategoryToAccountsMigration(),
      // 在這裡添加新的遷移
    ]);
  }

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
      version: _migrationManager.latestVersion,
      onCreate: (db, version) async {
        // 創建新數據庫時，執行所有遷移
        await _migrationManager.migrate(db, 0, version);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // 升級數據庫時，執行需要的遷移
        await _migrationManager.migrate(db, oldVersion, newVersion);
      },
    );
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

  Future<int> updateAccount(InvestmentAccount account) async {
    final db = await database;
    return db.update('accounts', account.toMap(),
        where: 'id = ?', whereArgs: [account.id]);
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    return db.delete('accounts', where: 'id = ?', whereArgs: [id]);
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

