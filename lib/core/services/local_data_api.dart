import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

enum LedgerEntryType { expense, income }

class LedgerCategoryDto {
  final int id;
  final String name;
  final LedgerEntryType type;
  final String iconCode;
  final String? colorKey;

  const LedgerCategoryDto({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCode,
    this.colorKey,
  });

  factory LedgerCategoryDto.fromMap(Map<String, Object?> map) {
    return LedgerCategoryDto(
      id: map['id'] as int,
      name: map['name'] as String,
      type: _typeFromName(map['type'] as String?),
      iconCode: map['icon_code'] as String,
      colorKey: map['color_key'] as String?,
    );
  }
}

class LedgerAccountDto {
  final int id;
  final String name;
  final String iconCode;
  final String? colorKey;

  const LedgerAccountDto({
    required this.id,
    required this.name,
    required this.iconCode,
    this.colorKey,
  });

  factory LedgerAccountDto.fromMap(Map<String, Object?> map) {
    return LedgerAccountDto(
      id: map['id'] as int,
      name: map['name'] as String,
      iconCode: map['icon_code'] as String,
      colorKey: map['color_key'] as String?,
    );
  }
}

class LedgerTransactionDto {
  final int id;
  final String transactionNo;
  final LedgerEntryType type;
  final double amount;
  final int categoryId;
  final String categoryName;
  final int accountId;
  final String accountName;
  final String note;
  final DateTime transactionTime;
  final String source;
  final String iconCode;
  final int receiptCount;

  const LedgerTransactionDto({
    required this.id,
    required this.transactionNo,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.accountId,
    required this.accountName,
    required this.note,
    required this.transactionTime,
    required this.source,
    required this.iconCode,
    this.receiptCount = 0,
  });

  double get signedAmount =>
      type == LedgerEntryType.income ? amount : -amount.abs();

  factory LedgerTransactionDto.fromMap(Map<String, Object?> map) {
    final rawTime = map['transaction_time'] as String;
    return LedgerTransactionDto(
      id: map['id'] as int,
      transactionNo: map['transaction_no'] as String,
      type: _typeFromName(map['type'] as String?),
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'] as int,
      categoryName: map['category_name'] as String,
      accountId: map['account_id'] as int,
      accountName: map['account_name'] as String,
      note: (map['note'] as String?) ?? '',
      transactionTime: DateTime.tryParse(rawTime) ?? DateTime.now(),
      source: (map['source'] as String?) ?? 'manual',
      iconCode: (map['icon_code'] as String?) ?? 'more_horiz',
      receiptCount: (map['receipt_count'] as int?) ?? 0,
    );
  }
}

class CreateLedgerTransactionInput {
  final LedgerEntryType type;
  final double amount;
  final int categoryId;
  final int accountId;
  final String note;
  final DateTime transactionTime;
  final String source;

  const CreateLedgerTransactionInput({
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.accountId,
    this.note = '',
    required this.transactionTime,
    this.source = 'manual',
  });
}

class MonthlyBudgetDto {
  final DateTime month;
  final double? budgetAmount;
  final double spentAmount;

  const MonthlyBudgetDto({
    required this.month,
    required this.budgetAmount,
    required this.spentAmount,
  });

  bool get isSet => budgetAmount != null;
  double? get remaining =>
      budgetAmount == null ? null : budgetAmount! - spentAmount;
  bool get isOverBudget =>
      budgetAmount != null && budgetAmount! > 0 && spentAmount > budgetAmount!;
  double get overAmount => isOverBudget ? spentAmount - budgetAmount! : 0;
  double get progress {
    final budget = budgetAmount;
    if (budget == null || budget <= 0) return 0;
    return (spentAmount / budget).clamp(0.0, 1.0);
  }
}

class BudgetCheckResult {
  final bool isOverBudget;
  final double overAmount;
  final MonthlyBudgetDto budget;

  const BudgetCheckResult({
    required this.isOverBudget,
    required this.overAmount,
    required this.budget,
  });
}

class LocalDataApi {
  LocalDataApi._();

  static final LocalDataApi instance = LocalDataApi._();
  final ValueNotifier<int> transactionsVersion = ValueNotifier<int>(0);
  final ValueNotifier<int> budgetVersion = ValueNotifier<int>(0);
  final _memory = _MemoryStore();

  Future<List<LedgerCategoryDto>> listLedgerCategories({
    required LedgerEntryType type,
  }) async {
    if (kIsWeb) return _memory.listCategories(type);

    final db = await DatabaseHelper().database;
    final rows = await db.query(
      'ledger_categories',
      where: 'type = ? AND is_enabled = 1 AND deleted_at IS NULL',
      whereArgs: [type.name],
      orderBy: 'sort_order ASC, id ASC',
    );
    return rows.map(LedgerCategoryDto.fromMap).toList();
  }

  Future<List<LedgerAccountDto>> listLedgerAccounts() async {
    if (kIsWeb) return _memory.listAccounts();

    final db = await DatabaseHelper().database;
    final rows = await db.query(
      'ledger_accounts',
      where: 'is_enabled = 1 AND deleted_at IS NULL',
      orderBy: 'sort_order ASC, id ASC',
    );
    return rows.map(LedgerAccountDto.fromMap).toList();
  }

  Future<int> createLedgerTransaction(
    CreateLedgerTransactionInput input,
  ) async {
    final id = kIsWeb
        ? await _memory.createTransaction(input)
        : await _createSqliteTransaction(input);
    transactionsVersion.value++;
    if (input.type == LedgerEntryType.expense) {
      budgetVersion.value++;
    }
    return id;
  }

  Future<List<LedgerTransactionDto>> listTransactions() async {
    if (kIsWeb) return _memory.listTransactions();

    final db = await DatabaseHelper().database;
    final rows = await db.rawQuery('''
      SELECT
        t.id,
        t.transaction_no,
        t.type,
        t.amount,
        t.category_id,
        t.category_name,
        t.account_id,
        t.account_name,
        t.note,
        t.transaction_time,
        t.source,
        c.icon_code,
        COUNT(a.id) AS receipt_count
      FROM ledger_transactions t
      LEFT JOIN ledger_categories c ON c.id = t.category_id
      LEFT JOIN transaction_attachments a
        ON a.transaction_id = t.id AND a.deleted_at IS NULL
      WHERE t.deleted_at IS NULL
      GROUP BY t.id
      ORDER BY t.transaction_time DESC
    ''');
    return rows.map(LedgerTransactionDto.fromMap).toList();
  }

  /// /api/budget/get
  Future<MonthlyBudgetDto> getBudget({DateTime? month}) async {
    final targetMonth = _monthStart(month ?? DateTime.now());
    if (kIsWeb) return _memory.getBudget(targetMonth);

    final db = await DatabaseHelper().database;
    final monthKey = _monthKey(targetMonth);
    final budgetRows = await db.query(
      'monthly_budgets',
      where: 'budget_month = ? AND deleted_at IS NULL',
      whereArgs: [monthKey],
      limit: 1,
    );
    final expenseRows = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM ledger_transactions
      WHERE deleted_at IS NULL
        AND type = ?
        AND transaction_time >= ?
        AND transaction_time < ?
      ''',
      [
        LedgerEntryType.expense.name,
        targetMonth.toIso8601String(),
        DateTime(targetMonth.year, targetMonth.month + 1).toIso8601String(),
      ],
    );
    return MonthlyBudgetDto(
      month: targetMonth,
      budgetAmount: budgetRows.isEmpty
          ? null
          : (budgetRows.first['amount'] as num).toDouble(),
      spentAmount: ((expenseRows.first['total'] as num?) ?? 0).toDouble(),
    );
  }

  /// /api/budget/set
  Future<MonthlyBudgetDto> setBudget({
    required DateTime month,
    required double amount,
  }) async {
    final targetMonth = _monthStart(month);
    if (kIsWeb) {
      final budget = await _memory.setBudget(targetMonth, amount);
      budgetVersion.value++;
      return budget;
    }

    final db = await DatabaseHelper().database;
    final now = DateTime.now().toIso8601String();
    await db.insert('monthly_budgets', {
      'budget_month': _monthKey(targetMonth),
      'amount': amount.abs(),
      'currency': 'CNY',
      'sync_status': 'local',
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    final budget = await getBudget(month: targetMonth);
    budgetVersion.value++;
    return budget;
  }

  /// /api/budget/check
  Future<BudgetCheckResult> checkBudget({DateTime? month}) async {
    final budget = await getBudget(month: month);
    return BudgetCheckResult(
      isOverBudget: budget.isOverBudget,
      overAmount: budget.overAmount,
      budget: budget,
    );
  }

  Future<int> _createSqliteTransaction(
    CreateLedgerTransactionInput input,
  ) async {
    final db = await DatabaseHelper().database;
    final categoryRows = await db.query(
      'ledger_categories',
      where: 'id = ?',
      whereArgs: [input.categoryId],
      limit: 1,
    );
    final accountRows = await db.query(
      'ledger_accounts',
      where: 'id = ?',
      whereArgs: [input.accountId],
      limit: 1,
    );
    if (categoryRows.isEmpty || accountRows.isEmpty) {
      throw StateError('分类或账户不存在');
    }

    final now = DateTime.now().toIso8601String();
    final category = categoryRows.first;
    final account = accountRows.first;
    return db.insert('ledger_transactions', {
      'transaction_no': _buildTransactionNo(now),
      'type': input.type.name,
      'amount': input.amount.abs(),
      'category_id': input.categoryId,
      'category_name': category['name'],
      'account_id': input.accountId,
      'account_name': account['name'],
      'note': input.note.trim(),
      'transaction_time': input.transactionTime.toIso8601String(),
      'source': input.source,
      'sync_status': 'local',
      'created_at': now,
      'updated_at': now,
    });
  }

  String _buildTransactionNo(String now) {
    return 'tx_${now.replaceAll(RegExp(r'[^0-9]'), '')}_'
        '${DateTime.now().microsecondsSinceEpoch}';
  }
}

DateTime _monthStart(DateTime date) => DateTime(date.year, date.month);

String _monthKey(DateTime date) {
  final month = _monthStart(date);
  return '${month.year}-${month.month.toString().padLeft(2, '0')}';
}

class LedgerIconCatalog {
  LedgerIconCatalog._();

  static IconData icon(String code) {
    return _icons[code] ?? Icons.more_horiz;
  }

  static const _icons = <String, IconData>{
    'restaurant_outlined': Icons.restaurant_outlined,
    'directions_car_outlined': Icons.directions_car_outlined,
    'shopping_bag_outlined': Icons.shopping_bag_outlined,
    'home_outlined': Icons.home_outlined,
    'lightbulb_outline': Icons.lightbulb_outline,
    'phone_iphone_outlined': Icons.phone_iphone_outlined,
    'sports_esports_outlined': Icons.sports_esports_outlined,
    'menu_book_outlined': Icons.menu_book_outlined,
    'medical_services_outlined': Icons.medical_services_outlined,
    'flight_takeoff_outlined': Icons.flight_takeoff_outlined,
    'cruelty_free_outlined': Icons.cruelty_free_outlined,
    'card_giftcard_outlined': Icons.card_giftcard_outlined,
    'spa_outlined': Icons.spa_outlined,
    'checkroom_outlined': Icons.checkroom_outlined,
    'brush_outlined': Icons.brush_outlined,
    'directions_run_outlined': Icons.directions_run_outlined,
    'devices_outlined': Icons.devices_outlined,
    'payments_outlined': Icons.payments_outlined,
    'redeem_outlined': Icons.redeem_outlined,
    'trending_up_outlined': Icons.trending_up_outlined,
    'work_outline': Icons.work_outline,
    'credit_card_outlined': Icons.credit_card_outlined,
    'keyboard_return_outlined': Icons.keyboard_return_outlined,
    'account_balance_outlined': Icons.account_balance_outlined,
    'insert_chart_outlined': Icons.insert_chart_outlined,
    'chat_bubble_outline': Icons.chat_bubble_outline,
    'account_balance_wallet_outlined': Icons.account_balance_wallet_outlined,
    'money_outlined': Icons.money_outlined,
    'more_horiz': Icons.more_horiz,
  };
}

LedgerEntryType _typeFromName(String? value) {
  return value == LedgerEntryType.income.name
      ? LedgerEntryType.income
      : LedgerEntryType.expense;
}

class _MemoryStore {
  final List<LedgerCategoryDto> _categories = _seedCategories();
  final List<LedgerAccountDto> _accounts = _seedAccounts();
  final List<LedgerTransactionDto> _transactions = [];
  final Map<String, double> _budgets = {};
  int _nextTransactionId = 1;

  List<LedgerCategoryDto> listCategories(LedgerEntryType type) {
    return _categories.where((category) => category.type == type).toList();
  }

  List<LedgerAccountDto> listAccounts() => List.of(_accounts);

  Future<int> createTransaction(CreateLedgerTransactionInput input) async {
    final category = _categories.firstWhere((c) => c.id == input.categoryId);
    final account = _accounts.firstWhere((a) => a.id == input.accountId);
    final id = _nextTransactionId++;
    _transactions.add(
      LedgerTransactionDto(
        id: id,
        transactionNo: 'web_$id',
        type: input.type,
        amount: input.amount.abs(),
        categoryId: category.id,
        categoryName: category.name,
        accountId: account.id,
        accountName: account.name,
        note: input.note.trim(),
        transactionTime: input.transactionTime,
        source: input.source,
        iconCode: category.iconCode,
      ),
    );
    return id;
  }

  List<LedgerTransactionDto> listTransactions() {
    return List<LedgerTransactionDto>.of(_transactions)
      ..sort((a, b) => b.transactionTime.compareTo(a.transactionTime));
  }

  Future<MonthlyBudgetDto> getBudget(DateTime month) async {
    final targetMonth = _monthStart(month);
    final spent = _transactions
        .where(
          (item) =>
              item.type == LedgerEntryType.expense &&
              item.transactionTime.year == targetMonth.year &&
              item.transactionTime.month == targetMonth.month,
        )
        .fold(0.0, (sum, item) => sum + item.amount.abs());
    return MonthlyBudgetDto(
      month: targetMonth,
      budgetAmount: _budgets[_monthKey(targetMonth)],
      spentAmount: spent,
    );
  }

  Future<MonthlyBudgetDto> setBudget(DateTime month, double amount) async {
    final targetMonth = _monthStart(month);
    _budgets[_monthKey(targetMonth)] = amount.abs();
    return getBudget(targetMonth);
  }

  static List<LedgerCategoryDto> _seedCategories() {
    const expense = [
      [1, '餐饮', 'restaurant_outlined'],
      [2, '交通', 'directions_car_outlined'],
      [3, '购物', 'shopping_bag_outlined'],
      [4, '住房', 'home_outlined'],
      [5, '水电', 'lightbulb_outline'],
      [6, '通讯', 'phone_iphone_outlined'],
      [7, '娱乐', 'sports_esports_outlined'],
      [8, '学习', 'menu_book_outlined'],
      [9, '医疗', 'medical_services_outlined'],
      [10, '旅行', 'flight_takeoff_outlined'],
      [11, '宠物', 'cruelty_free_outlined'],
      [12, '礼物', 'card_giftcard_outlined'],
      [13, '日用品', 'spa_outlined'],
      [14, '服饰', 'checkroom_outlined'],
      [15, '美妆', 'brush_outlined'],
      [16, '运动', 'directions_run_outlined'],
      [17, '数码', 'devices_outlined'],
      [18, '其他', 'more_horiz'],
    ];
    const income = [
      [101, '工资', 'payments_outlined'],
      [102, '奖金', 'redeem_outlined'],
      [103, '分红', 'trending_up_outlined'],
      [104, '兼职', 'work_outline'],
      [105, '收款', 'credit_card_outlined'],
      [106, '退款', 'keyboard_return_outlined'],
      [107, '红包', 'card_giftcard_outlined'],
      [108, '利息', 'account_balance_outlined'],
      [109, '投资', 'insert_chart_outlined'],
      [110, '其他', 'more_horiz'],
    ];
    return [
      for (final item in expense)
        LedgerCategoryDto(
          id: item[0] as int,
          name: item[1] as String,
          type: LedgerEntryType.expense,
          iconCode: item[2] as String,
        ),
      for (final item in income)
        LedgerCategoryDto(
          id: item[0] as int,
          name: item[1] as String,
          type: LedgerEntryType.income,
          iconCode: item[2] as String,
        ),
    ];
  }

  static List<LedgerAccountDto> _seedAccounts() {
    const accounts = [
      [1, '微信', 'chat_bubble_outline'],
      [2, '支付宝', 'account_balance_wallet_outlined'],
      [3, '银行卡', 'account_balance_outlined'],
      [4, '现金', 'money_outlined'],
      [5, '信用卡', 'credit_card_outlined'],
      [6, '数字钱包', 'phone_iphone_outlined'],
    ];
    return [
      for (final item in accounts)
        LedgerAccountDto(
          id: item[0] as int,
          name: item[1] as String,
          iconCode: item[2] as String,
        ),
    ];
  }
}
