/// 日记条目模型
class DiaryEntry {
  final int? id;
  final DateTime date;
  final String content;
  final String? weather;
  final int? mood;
  final String? location;
  final List<String> mediaPaths;
  final List<String> tags;
  final String luckyThing; // 今日小幸运
  final String progress; // 今日小进步
  final String todaySay; // 今天想说
  final int exerciseMinutes; // 运动分钟数
  final DateTime createdAt;
  final DateTime updatedAt;

  DiaryEntry({
    this.id,
    required this.date,
    this.content = '',
    this.weather,
    this.mood,
    this.location,
    this.mediaPaths = const [],
    this.tags = const [],
    this.luckyThing = '',
    this.progress = '',
    this.todaySay = '',
    this.exerciseMinutes = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String().substring(0, 10),
        'content': content,
        'weather': weather,
        'mood': mood,
        'location': location,
        'media_paths': mediaPaths.join(','),
        'tags': tags.join(','),
        'lucky_thing': luckyThing,
        'progress': progress,
        'today_say': todaySay,
        'exercise_minutes': exerciseMinutes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory DiaryEntry.fromMap(Map<String, dynamic> map) => DiaryEntry(
        id: map['id'] as int?,
        date: DateTime.parse(map['date'] as String),
        content: (map['content'] as String?) ?? '',
        weather: map['weather'] as String?,
        mood: map['mood'] as int?,
        location: map['location'] as String?,
        mediaPaths: (map['media_paths'] as String?)?.isNotEmpty == true
            ? (map['media_paths'] as String)
                .split(',')
                .where((s) => s.isNotEmpty)
                .toList()
            : [],
        tags: (map['tags'] as String?)?.isNotEmpty == true
            ? (map['tags'] as String).split(',').where((s) => s.isNotEmpty).toList()
            : [],
        luckyThing: (map['lucky_thing'] as String?) ?? '',
        progress: (map['progress'] as String?) ?? '',
        todaySay: (map['today_say'] as String?) ?? '',
        exerciseMinutes: (map['exercise_minutes'] as int?) ?? 0,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : DateTime.now(),
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'] as String)
            : DateTime.now(),
      );

  DiaryEntry copyWith({
    int? id,
    DateTime? date,
    String? content,
    String? weather,
    int? mood,
    String? location,
    List<String>? mediaPaths,
    List<String>? tags,
    String? luckyThing,
    String? progress,
    String? todaySay,
    int? exerciseMinutes,
  }) =>
      DiaryEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        content: content ?? this.content,
        weather: weather ?? this.weather,
        mood: mood ?? this.mood,
        location: location ?? this.location,
        mediaPaths: mediaPaths ?? this.mediaPaths,
        tags: tags ?? this.tags,
        luckyThing: luckyThing ?? this.luckyThing,
        progress: progress ?? this.progress,
        todaySay: todaySay ?? this.todaySay,
        exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
