import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../app/constants.dart';

/// SQLite 数据库助手
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
    return openDatabase(path, version: AppConstants.dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int v) async {
    // 分类表（收支共用）
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL DEFAULT '📌',
        type TEXT NOT NULL,
        color TEXT DEFAULT '#5E7A6B',
        sort_order INTEGER DEFAULT 0
      )
    ''');

    // 账户表
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL DEFAULT '💳',
        sort_order INTEGER DEFAULT 0,
        is_default INTEGER DEFAULT 0
      )
    ''');

    // 日记表
    await db.execute('''
      CREATE TABLE diary_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        content TEXT DEFAULT '',
        mood TEXT DEFAULT '😊',
        mood_label TEXT DEFAULT '开心',
        weather TEXT DEFAULT 'sunny',
        weather_label TEXT DEFAULT '晴',
        images TEXT DEFAULT '',
        updated_at TEXT NOT NULL
      )
    ''');

    // 账单表
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        category_name TEXT NOT NULL,
        category_icon TEXT NOT NULL,
        account_id INTEGER NOT NULL,
        account_name TEXT NOT NULL,
        account_icon TEXT NOT NULL,
        note TEXT DEFAULT '',
        images TEXT DEFAULT '',
        timestamp TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (account_id) REFERENCES accounts(id)
      )
    ''');

    // 应用设置表
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute(
      "INSERT INTO app_settings (key, value) VALUES ('theme_mode', 'light')",
    );

    // 种子数据
    await _seed(db);
  }

  Future<void> _seed(Database db) async {

    // 支出分类
    final expenseCategories = [
      ['🍜', '餐饮'], ['🚗', '交通'], ['🛒', '购物'],
      ['🏠', '住房'], ['💡', '水电'], ['📱', '通讯'],
      ['🎮', '娱乐'], ['📚', '学习'], ['💊', '医疗'],
      ['✈️', '旅行'], ['🐱', '宠物'], ['🎁', '礼物'],
      ['🧴', '日用品'], ['👗', '服饰'], ['💄', '美妆'],
      ['🏃', '运动'], ['💻', '数码'], ['📌', '其他'],
    ];
    for (var i = 0; i < expenseCategories.length; i++) {
      final c = expenseCategories[i];
      await db.insert('categories', {
        'name': c[1], 'icon': c[0], 'type': 'expense',
        'sort_order': i, 'color': '#D4786E',
      });
    }

    // 收入分类
    final incomeCategories = [
      ['💰', '工资'], ['🧧', '奖金'], ['📈', '分红'],
      ['💼', '兼职'], ['💳', '收款'], ['↩️', '退款'],
      ['🎁', '红包'], ['🏦', '利息'], ['📊', '投资'],
      ['📌', '其他'],
    ];
    for (var i = 0; i < incomeCategories.length; i++) {
      final c = incomeCategories[i];
      await db.insert('categories', {
        'name': c[1], 'icon': c[0], 'type': 'income',
        'sort_order': i, 'color': '#5E7A6B',
      });
    }

    // 默认账户
    final accounts = [
      ['💚', '微信'], ['💙', '支付宝'], ['🏦', '银行卡'],
      ['💵', '现金'], ['💳', '信用卡'], ['📱', '数字钱包'],
    ];
    for (var i = 0; i < accounts.length; i++) {
      final a = accounts[i];
      await db.insert('accounts', {
        'name': a[1], 'icon': a[0], 'sort_order': i,
        'is_default': i == 0 ? 1 : 0,
      });
    }

    // 心情标签
    final moods = [
      ['😊', '开心'], ['😌', '平静'], ['😢', '难过'],
      ['😡', '生气'], ['😫', '疲惫'], ['😲', '惊喜'],
      ['😰', '焦虑'], ['🥰', '满足'],
    ];
    await db.insert('app_settings', {
      'key': 'moods', 'value': moods.map((m) => '${m[0]},${m[1]}').join('|'),
    });

    // 天气选项
    final weathers = [
      ['sunny', '☀️', '晴'], ['cloudy', '⛅', '多云'],
      ['overcast', '☁️', '阴天'], ['light_rain', '🌧️', '小雨'],
      ['heavy_rain', '⛈️', '大雨'], ['snow', '❄️', '雪天'],
      ['fog', '🌫️', '雾天'],
    ];
    await db.insert('app_settings', {
      'key': 'weathers', 'value': weathers.map((w) => '${w[0]},${w[1]},${w[2]}').join('|'),
    });
  }
}
