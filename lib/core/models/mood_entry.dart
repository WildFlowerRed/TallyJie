/// 心情记录模型（与日记关联，也可独立使用）
class MoodEntry {
  final int? id;
  final DateTime date;
  final String mood; // emoji
  final String? note;
  final DateTime createdAt;

  MoodEntry({
    this.id,
    required this.date,
    required this.mood,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String().substring(0, 10),
        'mood': mood,
        'note': note,
        'created_at': createdAt.toIso8601String(),
      };

  factory MoodEntry.fromMap(Map<String, dynamic> map) => MoodEntry(
        id: map['id'] as int?,
        date: DateTime.parse(map['date'] as String),
        mood: map['mood'] as String,
        note: map['note'] as String?,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : DateTime.now(),
      );
}
