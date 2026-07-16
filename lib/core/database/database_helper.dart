import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../app/constants.dart';

/// SQLite 数据库助手
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() => _instance ??= DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 日记表
    await db.execute('''
      CREATE TABLE diary_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        content TEXT DEFAULT '',
        weather TEXT,
        mood INTEGER,
        location TEXT,
        media_paths TEXT DEFAULT '',
        tags TEXT DEFAULT '',
        lucky_thing TEXT DEFAULT '',
        progress TEXT DEFAULT '',
        today_say TEXT DEFAULT '',
        exercise_minutes INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 交易/记账表
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        category_icon TEXT NOT NULL,
        note TEXT,
        timestamp TEXT NOT NULL,
        source TEXT DEFAULT 'manual',
        created_at TEXT NOT NULL
      )
    ''');

    // 待办事项表
    await db.execute('''
      CREATE TABLE todo_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        notes TEXT,
        is_completed INTEGER DEFAULT 0,
        due_date TEXT,
        priority INTEGER DEFAULT 0,
        date TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0,
        completed_at TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 周计划表
    await db.execute('''
      CREATE TABLE weekly_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        week_start TEXT NOT NULL UNIQUE,
        goals TEXT DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');

    // 每日计划备注
    await db.execute('''
      CREATE TABLE daily_plan_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        week_start TEXT NOT NULL,
        day_index INTEGER NOT NULL,
        notes TEXT DEFAULT ''
      )
    ''');

    // 日程事件
    await db.execute('''
      CREATE TABLE plan_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        week_start TEXT NOT NULL,
        day_index INTEGER NOT NULL,
        title TEXT NOT NULL,
        time TEXT,
        color TEXT DEFAULT '#8E7C66',
        sort_order INTEGER DEFAULT 0
      )
    ''');

    // 心情记录
    await db.execute('''
      CREATE TABLE mood_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        mood TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 用户设置
    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY,
        name TEXT DEFAULT '',
        avatar_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 插入默认用户
    await db.execute('''
      INSERT INTO user_settings (id, name, created_at, updated_at)
      VALUES (1, '', datetime('now'), datetime('now'))
    ''');

    // 插入默认待办项
    await _seedDefaultTodos(db);
  }

  Future<void> _seedDefaultTodos(Database db) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final defaultTodos = [
      {'title': '学习', 'date': today, 'sort_order': 0},
      {'title': '运动', 'date': today, 'sort_order': 1},
      {'title': '阅读', 'date': today, 'sort_order': 2},
      {'title': '记账', 'date': today, 'sort_order': 3},
      {'title': '冥想', 'date': today, 'sort_order': 4},
    ];

    for (final todo in defaultTodos) {
      await db.insert('todo_items', {
        'title': todo['title'],
        'date': todo['date'],
        'sort_order': todo['sort_order'],
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }
}
