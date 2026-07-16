/// 交易类型
enum TransactionType { expense, income }

/// 交易/账单模型
class Transaction {
  final int? id;
  final double amount;
  final TransactionType type;
  final String category;
  final String categoryIcon;
  final String? note;
  final DateTime timestamp;
  final String? source; // 'manual', 'alipay', etc.
  final DateTime createdAt;

  Transaction({
    this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.categoryIcon,
    this.note,
    DateTime? timestamp,
    this.source,
    DateTime? createdAt,
  })  : timestamp = timestamp ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  /// 根据时间获取时段: 上午/下午/晚上
  String get timeOfDayLabel {
    final hour = timestamp.hour;
    if (hour >= 6 && hour < 12) return '上午';
    if (hour >= 12 && hour < 18) return '下午';
    return '晚上';
  }

  /// 获取时段分组键
  int get timeOfDayGroup {
    final hour = timestamp.hour;
    if (hour >= 6 && hour < 12) return 0; // 上午
    if (hour >= 12 && hour < 18) return 1; // 下午
    return 2; // 晚上
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'type': type.name,
        'category': category,
        'category_icon': categoryIcon,
        'note': note,
        'timestamp': timestamp.toIso8601String(),
        'source': source,
        'created_at': createdAt.toIso8601String(),
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'] as int?,
        amount: (map['amount'] as num).toDouble(),
        type: TransactionType.values.firstWhere(
          (t) => t.name == map['type'],
          orElse: () => TransactionType.expense,
        ),
        category: map['category'] as String,
        categoryIcon: map['category_icon'] as String,
        note: map['note'] as String?,
        timestamp: map['timestamp'] != null
            ? DateTime.parse(map['timestamp'] as String)
            : DateTime.now(),
        source: map['source'] as String?,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : DateTime.now(),
      );

  Transaction copyWith({
    int? id,
    double? amount,
    TransactionType? type,
    String? category,
    String? categoryIcon,
    String? note,
    DateTime? timestamp,
    String? source,
  }) =>
      Transaction(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        category: category ?? this.category,
        categoryIcon: categoryIcon ?? this.categoryIcon,
        note: note ?? this.note,
        timestamp: timestamp ?? this.timestamp,
        source: source ?? this.source,
        createdAt: createdAt,
      );
}
