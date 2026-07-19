import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../app/constants.dart';

/// SQLite 数据库助手。
///
/// v2 结构按“本地优先 + 后续可接后端同步”设计：
/// - 本地自增 id 负责手机端离线使用。
/// - server_id / sync_status / synced_at / revision 预留给后端同步。
/// - 统计页不单独存结果，统一从 ledger_transactions 聚合。
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _db;

  DatabaseHelper._();

  factory DatabaseHelper() => _instance ??= DatabaseHelper._();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createSchema(db);
    await _seedReferenceData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _backupV1Tables(db);
      await _createSchema(db);
      await _seedReferenceData(db);
      await _migrateLegacyDiary(db);
      await _migrateLegacyTransactions(db);
    }
    if (oldVersion < 3) {
      await _createMonthlyBudgetsTable(db);
      await _createIndexes(db);
    }
    if (oldVersion < 4) {
      await _migrateDiaryEntriesToMultiEntry(db);
      await _createIndexes(db);
    }
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS theme_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        theme_key TEXT NOT NULL UNIQUE,
        theme_name TEXT NOT NULL,
        is_active INTEGER DEFAULT 0,
        server_id TEXT UNIQUE,
        sync_status TEXT DEFAULT 'local',
        synced_at TEXT,
        revision INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await _createDiaryEntriesTable(db);

    await _createDiaryAttachmentsTable(db);

    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_date TEXT NOT NULL,
        title TEXT NOT NULL,
        is_done INTEGER DEFAULT 0,
        sort_order INTEGER DEFAULT 0,
        server_id TEXT UNIQUE,
        sync_status TEXT DEFAULT 'local',
        synced_at TEXT,
        revision INTEGER DEFAULT 0,
        deleted_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ledger_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon_code TEXT NOT NULL,
        color_key TEXT,
        sort_order INTEGER DEFAULT 0,
        is_system INTEGER DEFAULT 1,
        is_enabled INTEGER DEFAULT 1,
        server_id TEXT UNIQUE,
        sync_status TEXT DEFAULT 'local',
        synced_at TEXT,
        revision INTEGER DEFAULT 0,
        deleted_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(name, type)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ledger_accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon_code TEXT NOT NULL,
        color_key TEXT,
        balance REAL DEFAULT 0,
        sort_order INTEGER DEFAULT 0,
        is_default INTEGER DEFAULT 0,
        is_enabled INTEGER DEFAULT 1,
        server_id TEXT UNIQUE,
        sync_status TEXT DEFAULT 'local',
        synced_at TEXT,
        revision INTEGER DEFAULT 0,
        deleted_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ledger_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_no TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category_id INTEGER NOT NULL,
        category_name TEXT NOT NULL,
        account_id INTEGER NOT NULL,
        account_name TEXT NOT NULL,
        note TEXT DEFAULT '',
        transaction_time TEXT NOT NULL,
        source TEXT DEFAULT 'manual',
        server_id TEXT UNIQUE,
        sync_status TEXT DEFAULT 'local',
        synced_at TEXT,
        revision INTEGER DEFAULT 0,
        deleted_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES ledger_categories(id),
        FOREIGN KEY (account_id) REFERENCES ledger_accounts(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS transaction_attachments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        file_path TEXT NOT NULL,
        file_name TEXT,
        file_type TEXT DEFAULT 'image',
        file_size INTEGER DEFAULT 0,
        server_id TEXT UNIQUE,
        sync_status TEXT DEFAULT 'local',
        synced_at TEXT,
        revision INTEGER DEFAULT 0,
        deleted_at TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES ledger_transactions(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS auto_detected_bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_app TEXT NOT NULL,
        raw_text TEXT NOT NULL,
        merchant_name TEXT,
        amount REAL,
        predicted_type TEXT DEFAULT 'expense',
        predicted_category_id INTEGER,
        predicted_category_name TEXT,
        detected_time TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        transaction_id INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY (predicted_category_id) REFERENCES ledger_categories(id),
        FOREIGN KEY (transaction_id) REFERENCES ledger_transactions(id)
      )
    ''');

    await _createMonthlyBudgetsTable(db);

    await db.execute('''
      CREATE TABLE IF NOT EXISTS backup_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_size INTEGER DEFAULT 0,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await _createIndexes(db);
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_diary_date ON diary_entries(entry_date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_task_date ON daily_tasks(task_date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaction_time '
      'ON ledger_transactions(transaction_time)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaction_type '
      'ON ledger_transactions(type)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaction_category '
      'ON ledger_transactions(category_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaction_account '
      'ON ledger_transactions(account_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_transaction_note '
      'ON ledger_transactions(note)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_auto_detected_status '
      'ON auto_detected_bills(status)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_monthly_budget_month '
      'ON monthly_budgets(budget_month)',
    );
  }

  Future<void> _createDiaryEntriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS diary_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_date TEXT NOT NULL,
        title TEXT DEFAULT '',
        content TEXT DEFAULT '',
        markdown_content TEXT DEFAULT '',
        mood_key TEXT,
        mood_label TEXT,
        mood_icon TEXT,
        weather_key TEXT,
        weather_label TEXT,
        weather_icon TEXT,
        lunar_date TEXT,
        location_name TEXT,
        is_favorite INTEGER DEFAULT 0,
        server_id TEXT UNIQUE,
        sync_status TEXT DEFAULT 'local',
        synced_at TEXT,
        revision INTEGER DEFAULT 0,
        deleted_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createDiaryAttachmentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS diary_attachments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        diary_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_name TEXT,
        file_size INTEGER DEFAULT 0,
        sort_order INTEGER DEFAULT 0,
        server_id TEXT UNIQUE,
        sync_status TEXT DEFAULT 'local',
        synced_at TEXT,
        revision INTEGER DEFAULT 0,
        deleted_at TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (diary_id) REFERENCES diary_entries(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _migrateDiaryEntriesToMultiEntry(Database db) async {
    if (!await _tableExists(db, 'diary_entries')) {
      await _createDiaryEntriesTable(db);
      return;
    }

    final info = await db.rawQuery("PRAGMA index_list('diary_entries')");
    final hasUniqueEntryDate = info.any((row) => row['unique'] == 1);
    if (!hasUniqueEntryDate) return;

    final now = DateTime.now().toIso8601String();
    await db.execute(
      'ALTER TABLE diary_entries RENAME TO diary_entries_v3_backup',
    );
    await _createDiaryEntriesTable(db);
    final rows = await db.query('diary_entries_v3_backup');
    final idMap = <int, int>{};
    for (final row in rows) {
      final oldId = row['id'] as int;
      final newId = await db.insert('diary_entries', {
        'entry_date': row['entry_date'],
        'title': row['title'] ?? '',
        'content': row['content'] ?? '',
        'markdown_content': row['markdown_content'] ?? row['content'] ?? '',
        'mood_key': row['mood_key'],
        'mood_label': row['mood_label'],
        'mood_icon': row['mood_icon'],
        'weather_key': row['weather_key'],
        'weather_label': row['weather_label'],
        'weather_icon': row['weather_icon'],
        'lunar_date': row['lunar_date'],
        'location_name': row['location_name'],
        'is_favorite': row['is_favorite'] ?? 0,
        'server_id': row['server_id'],
        'sync_status': row['sync_status'] ?? 'local',
        'synced_at': row['synced_at'],
        'revision': row['revision'] ?? 0,
        'deleted_at': row['deleted_at'],
        'created_at': row['created_at'] ?? now,
        'updated_at': row['updated_at'] ?? now,
      });
      idMap[oldId] = newId;
    }

    if (await _tableExists(db, 'diary_attachments')) {
      await db.execute(
        'ALTER TABLE diary_attachments RENAME TO diary_attachments_v3_backup',
      );
      await _createDiaryAttachmentsTable(db);
      final attachments = await db.query('diary_attachments_v3_backup');
      for (final attachment in attachments) {
        final oldDiaryId = attachment['diary_id'] as int;
        final newDiaryId = idMap[oldDiaryId];
        if (newDiaryId == null) continue;
        await db.insert('diary_attachments', {
          'diary_id': newDiaryId,
          'type': attachment['type'],
          'file_path': attachment['file_path'],
          'file_name': attachment['file_name'],
          'file_size': attachment['file_size'] ?? 0,
          'sort_order': attachment['sort_order'] ?? 0,
          'server_id': attachment['server_id'],
          'sync_status': attachment['sync_status'] ?? 'local',
          'synced_at': attachment['synced_at'],
          'revision': attachment['revision'] ?? 0,
          'deleted_at': attachment['deleted_at'],
          'created_at': attachment['created_at'] ?? now,
        });
      }
    }
  }

  Future<void> _createMonthlyBudgetsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS monthly_budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        budget_month TEXT NOT NULL UNIQUE,
        amount REAL NOT NULL,
        currency TEXT DEFAULT 'CNY',
        server_id TEXT UNIQUE,
        sync_status TEXT DEFAULT 'local',
        synced_at TEXT,
        revision INTEGER DEFAULT 0,
        deleted_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedReferenceData(Database db) async {
    final now = DateTime.now().toIso8601String();

    if (!await _hasRows(db, 'theme_settings')) {
      final themes = [
        ['cream_paper', '奶油纸感/温润豆沙/日常记录', 1],
        ['ru_celadon', '风雅青色/汝窑天青/玉石灰绿/清雅轻奢', 0],
        ['classic_bw', '经典黑白/暖白灰阶/墨色线条/极简高级', 0],
      ];
      for (final theme in themes) {
        await db.insert('theme_settings', {
          'theme_key': theme[0],
          'theme_name': theme[1],
          'is_active': theme[2],
          'created_at': now,
          'updated_at': now,
        });
      }
    }

    if (!await _hasRows(db, 'ledger_categories')) {
      await _seedCategories(db, now);
    }

    if (!await _hasRows(db, 'ledger_accounts')) {
      await _seedAccounts(db, now);
    }

    await _upsertSetting(db, 'current_theme', 'cream_paper', now);
    await _upsertSetting(db, 'currency', 'CNY', now);
    await _upsertSetting(db, 'first_day_of_week', 'sunday', now);
    await _upsertSetting(db, 'backup_file_name', 'TallyJie_backup.zip', now);
  }

  Future<void> _seedCategories(Database db, String now) async {
    const expenseCategories = [
      ['餐饮', 'expense', 'restaurant_outlined', 'expense_food'],
      ['交通', 'expense', 'directions_car_outlined', 'expense_transit'],
      ['购物', 'expense', 'shopping_bag_outlined', 'expense_shopping'],
      ['住房', 'expense', 'home_outlined', 'expense_home'],
      ['水电', 'expense', 'lightbulb_outline', 'expense_utility'],
      ['通讯', 'expense', 'phone_iphone_outlined', 'expense_digital'],
      ['娱乐', 'expense', 'sports_esports_outlined', 'expense_fun'],
      ['学习', 'expense', 'menu_book_outlined', 'expense_study'],
      ['医疗', 'expense', 'medical_services_outlined', 'expense_medical'],
      ['旅行', 'expense', 'flight_takeoff_outlined', 'expense_transit'],
      ['宠物', 'expense', 'cruelty_free_outlined', 'expense_home'],
      ['礼物', 'expense', 'card_giftcard_outlined', 'expense_gift'],
      ['日用品', 'expense', 'spa_outlined', 'expense_daily'],
      ['服饰', 'expense', 'checkroom_outlined', 'expense_shopping'],
      ['美妆', 'expense', 'brush_outlined', 'expense_fun'],
      ['运动', 'expense', 'directions_run_outlined', 'expense_study'],
      ['数码', 'expense', 'devices_outlined', 'expense_digital'],
      ['其他', 'expense', 'more_horiz', 'neutral'],
    ];

    const incomeCategories = [
      ['工资', 'income', 'payments_outlined', 'income_salary'],
      ['奖金', 'income', 'redeem_outlined', 'income_bonus'],
      ['分红', 'income', 'trending_up_outlined', 'income_invest'],
      ['兼职', 'income', 'work_outline', 'income_part_time'],
      ['收款', 'income', 'credit_card_outlined', 'income_collect'],
      ['退款', 'income', 'keyboard_return_outlined', 'neutral'],
      ['红包', 'income', 'card_giftcard_outlined', 'income_bonus'],
      ['利息', 'income', 'account_balance_outlined', 'income_invest'],
      ['投资', 'income', 'insert_chart_outlined', 'income_invest'],
      ['其他', 'income', 'more_horiz', 'neutral'],
    ];

    for (var i = 0; i < expenseCategories.length; i++) {
      final item = expenseCategories[i];
      await db.insert('ledger_categories', {
        'name': item[0],
        'type': item[1],
        'icon_code': item[2],
        'color_key': item[3],
        'sort_order': i,
        'is_system': 1,
        'is_enabled': 1,
        'created_at': now,
        'updated_at': now,
      });
    }

    for (var i = 0; i < incomeCategories.length; i++) {
      final item = incomeCategories[i];
      await db.insert('ledger_categories', {
        'name': item[0],
        'type': item[1],
        'icon_code': item[2],
        'color_key': item[3],
        'sort_order': i,
        'is_system': 1,
        'is_enabled': 1,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  Future<void> _seedAccounts(Database db, String now) async {
    const accounts = [
      ['微信', 'chat_bubble_outline', 'account_wechat'],
      ['支付宝', 'account_balance_wallet_outlined', 'account_alipay'],
      ['银行卡', 'account_balance_outlined', 'account_bank'],
      ['现金', 'money_outlined', 'account_cash'],
      ['信用卡', 'credit_card_outlined', 'account_credit'],
      ['数字钱包', 'phone_iphone_outlined', 'account_wallet'],
    ];

    for (var i = 0; i < accounts.length; i++) {
      final item = accounts[i];
      await db.insert('ledger_accounts', {
        'name': item[0],
        'icon_code': item[1],
        'color_key': item[2],
        'balance': 0,
        'sort_order': i,
        'is_default': i == 0 ? 1 : 0,
        'is_enabled': 1,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  Future<void> _upsertSetting(
    Database db,
    String key,
    String value,
    String updatedAt,
  ) {
    return db.insert('app_settings', {
      'key': key,
      'value': value,
      'updated_at': updatedAt,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<bool> _hasRows(Database db, String table) async {
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM $table');
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  Future<void> _backupV1Tables(Database db) async {
    for (final table in [
      'categories',
      'accounts',
      'transactions',
      'app_settings',
    ]) {
      await _renameTableIfExists(db, table, '${table}_v1_backup');
    }
    await _renameTableIfExists(db, 'diary_entries', 'diary_entries_v1_backup');
  }

  Future<void> _renameTableIfExists(Database db, String from, String to) async {
    final exists = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [from],
    );
    if (exists.isEmpty) return;

    final backupExists = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [to],
    );
    if (backupExists.isNotEmpty) {
      await db.execute('DROP TABLE IF EXISTS $to');
    }
    await db.execute('ALTER TABLE $from RENAME TO $to');
  }

  Future<void> _migrateLegacyDiary(Database db) async {
    if (!await _tableExists(db, 'diary_entries_v1_backup')) return;
    final now = DateTime.now().toIso8601String();
    final rows = await db.query('diary_entries_v1_backup');
    for (final row in rows) {
      final date = (row['date'] ?? row['entry_date']) as String?;
      if (date == null || date.isEmpty) continue;

      await db.insert('diary_entries', {
        'entry_date': date.length >= 10 ? date.substring(0, 10) : date,
        'content': (row['content'] as String?) ?? '',
        'markdown_content': (row['content'] as String?) ?? '',
        'mood_key': row['mood']?.toString(),
        'mood_label': row['mood_label'] as String?,
        'mood_icon': row['mood']?.toString(),
        'weather_key': row['weather'] as String?,
        'weather_label': row['weather_label'] as String?,
        'location_name': row['location'] as String?,
        'sync_status': 'local',
        'created_at': (row['created_at'] as String?) ?? now,
        'updated_at': (row['updated_at'] as String?) ?? now,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _migrateLegacyTransactions(Database db) async {
    if (!await _tableExists(db, 'transactions_v1_backup')) return;
    final rows = await db.query('transactions_v1_backup');
    final now = DateTime.now().toIso8601String();
    for (final row in rows) {
      final type = (row['type'] as String?) ?? 'expense';
      final categoryName =
          (row['category_name'] ?? row['category'] ?? '其他') as String;
      final accountName = (row['account_name'] ?? '微信') as String;
      final categoryId = await _findCategoryId(db, categoryName, type);
      final accountId = await _findAccountId(db, accountName);
      final time = (row['timestamp'] ?? row['transaction_time'] ?? now)
          .toString();

      await db.insert('ledger_transactions', {
        'transaction_no': 'legacy_${row['id'] ?? time.hashCode}',
        'type': type,
        'amount': (row['amount'] as num).toDouble(),
        'category_id': categoryId,
        'category_name': categoryName,
        'account_id': accountId,
        'account_name': accountName,
        'note': row['note'] as String? ?? '',
        'transaction_time': time,
        'source': row['source'] as String? ?? 'manual',
        'sync_status': 'local',
        'created_at': row['created_at'] as String? ?? now,
        'updated_at': row['created_at'] as String? ?? now,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<int> _findCategoryId(Database db, String name, String type) async {
    final rows = await db.query(
      'ledger_categories',
      columns: ['id'],
      where: 'name = ? AND type = ?',
      whereArgs: [name, type],
      limit: 1,
    );
    if (rows.isNotEmpty) return rows.first['id'] as int;
    return _findCategoryId(db, '其他', type);
  }

  Future<int> _findAccountId(Database db, String name) async {
    final rows = await db.query(
      'ledger_accounts',
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (rows.isNotEmpty) return rows.first['id'] as int;
    return _findAccountId(db, '微信');
  }

  Future<bool> _tableExists(Database db, String table) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [table],
    );
    return result.isNotEmpty;
  }
}
