import 'package:sqflite/sqflite.dart';

/// 數據庫遷移腳本接口
abstract class Migration {
  /// 遷移版本號
  int get version;
  
  /// 執行遷移
  Future<void> up(Database db);
  
  /// 回滾遷移（如果需要）
  Future<void> down(Database db);
}

/// 遷移管理器
class MigrationManager {
  final List<Migration> migrations;
  
  MigrationManager(this.migrations) {
    // 確保遷移按版本號排序
    migrations.sort((a, b) => a.version.compareTo(b.version));
  }
  
  /// 獲取最新版本號
  int get latestVersion => migrations.isEmpty ? 0 : migrations.last.version;
  
  /// 執行所有需要的遷移
  Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == newVersion) return;
    
    // 開始事務
    await db.transaction((txn) async {
      // 獲取需要執行的遷移
      final migrationsToRun = migrations.where(
        (m) => m.version > oldVersion && m.version <= newVersion
      );
      
      // 按順序執行遷移
      for (final migration in migrationsToRun) {
        await migration.up(txn);
      }
    });
  }
}

/// 具體的遷移實現示例
class CreateAccountsTableMigration implements Migration {
  @override
  int get version => 1;
  
  @override
  Future<void> up(Database db) async {
    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        currency TEXT,
        note TEXT
      )
    ''');
  }
  
  @override
  Future<void> down(Database db) async {
    await db.execute('DROP TABLE IF EXISTS accounts');
  }
}

class AddCategoryToAccountsMigration implements Migration {
  @override
  int get version => 2;
  
  @override
  Future<void> up(Database db) async {
    await db.execute('ALTER TABLE accounts ADD COLUMN category TEXT');
  }
  
  @override
  Future<void> down(Database db) async {
    // 注意：SQLite 不支持刪除列，這裡需要重建表
    // 實際應用中可能需要更複雜的處理
    await db.transaction((txn) async {
      // 創建臨時表
      await txn.execute('''
        CREATE TABLE accounts_temp(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          currency TEXT,
          note TEXT
        )
      ''');
      
      // 複製數據
      await txn.execute('''
        INSERT INTO accounts_temp(id, name, currency, note)
        SELECT id, name, currency, note FROM accounts
      ''');
      
      // 刪除原表
      await txn.execute('DROP TABLE accounts');
      
      // 重命名臨時表
      await txn.execute('ALTER TABLE accounts_temp RENAME TO accounts');
    });
  }
} 