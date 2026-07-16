/// 待办事项模型
class TodoItem {
  final int? id;
  final String title;
  final String? notes;
  final bool isCompleted;
  final DateTime? dueDate;
  final int priority; // 0-3
  final DateTime date;
  final int sortOrder;
  final DateTime? completedAt;
  final DateTime createdAt;

  TodoItem({
    this.id,
    required this.title,
    this.notes,
    this.isCompleted = false,
    this.dueDate,
    this.priority = 0,
    DateTime? date,
    this.sortOrder = 0,
    this.completedAt,
    DateTime? createdAt,
  })  : date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'notes': notes,
        'is_completed': isCompleted ? 1 : 0,
        'due_date': dueDate?.toIso8601String(),
        'priority': priority,
        'date': date.toIso8601String().substring(0, 10),
        'sort_order': sortOrder,
        'completed_at': completedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  factory TodoItem.fromMap(Map<String, dynamic> map) => TodoItem(
        id: map['id'] as int?,
        title: map['title'] as String,
        notes: map['notes'] as String?,
        isCompleted: (map['is_completed'] as int?) == 1,
        dueDate: map['due_date'] != null
            ? DateTime.parse(map['due_date'] as String)
            : null,
        priority: (map['priority'] as int?) ?? 0,
        date: map['date'] != null
            ? DateTime.parse(map['date'] as String)
            : DateTime.now(),
        sortOrder: (map['sort_order'] as int?) ?? 0,
        completedAt: map['completed_at'] != null
            ? DateTime.parse(map['completed_at'] as String)
            : null,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : DateTime.now(),
      );

  TodoItem copyWith({
    int? id,
    String? title,
    String? notes,
    bool? isCompleted,
    DateTime? dueDate,
    int? priority,
    DateTime? date,
    int? sortOrder,
    DateTime? completedAt,
  }) =>
      TodoItem(
        id: id ?? this.id,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        isCompleted: isCompleted ?? this.isCompleted,
        dueDate: dueDate ?? this.dueDate,
        priority: priority ?? this.priority,
        date: date ?? this.date,
        sortOrder: sortOrder ?? this.sortOrder,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt,
      );
}
