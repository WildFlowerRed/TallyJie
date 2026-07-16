/// 周计划模型
class WeeklyPlan {
  final int? id;
  final DateTime weekStart; // 周一
  final List<String> goals;
  final List<DailyPlan> days;
  final DateTime createdAt;

  WeeklyPlan({
    this.id,
    required this.weekStart,
    this.goals = const [],
    this.days = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'week_start': weekStart.toIso8601String().substring(0, 10),
        'goals': goals.join('||'),
        'created_at': createdAt.toIso8601String(),
      };

  factory WeeklyPlan.fromMap(
    Map<String, dynamic> map, {
    List<DailyPlan> days = const [],
  }) =>
      WeeklyPlan(
        id: map['id'] as int?,
        weekStart: DateTime.parse(map['week_start'] as String),
        goals: (map['goals'] as String?)?.isNotEmpty == true
            ? (map['goals'] as String).split('||').where((s) => s.isNotEmpty).toList()
            : [],
        days: days,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : DateTime.now(),
      );
}

/// 某天的计划
class DailyPlan {
  final int dayIndex; // 0=周一, ..., 6=周日
  final String notes;
  final List<PlanEvent> events;

  DailyPlan({
    required this.dayIndex,
    this.notes = '',
    this.events = const [],
  });

  Map<String, dynamic> toMap() => {
        'day_index': dayIndex,
        'notes': notes,
      };

  factory DailyPlan.fromMap(
    Map<String, dynamic> map, {
    List<PlanEvent> events = const [],
  }) =>
      DailyPlan(
        dayIndex: map['day_index'] as int,
        notes: (map['notes'] as String?) ?? '',
        events: events,
      );
}

/// 日程事件
class PlanEvent {
  final int? id;
  final int dayIndex;
  final String title;
  final String? time;
  final String color;
  final int sortOrder;

  PlanEvent({
    this.id,
    required this.dayIndex,
    required this.title,
    this.time,
    this.color = '#8E7C66',
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'day_index': dayIndex,
        'title': title,
        'time': time,
        'color': color,
        'sort_order': sortOrder,
      };

  factory PlanEvent.fromMap(Map<String, dynamic> map) => PlanEvent(
        id: map['id'] as int?,
        dayIndex: map['day_index'] as int,
        title: map['title'] as String,
        time: map['time'] as String?,
        color: (map['color'] as String?) ?? '#8E7C66',
        sortOrder: (map['sort_order'] as int?) ?? 0,
      );
}
