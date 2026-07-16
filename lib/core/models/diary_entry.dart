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
            ? (map['media_paths'] as String).split(',').where((s) => s.isNotEmpty).toList()
            : [],
        tags: (map['tags'] as String?)?.isNotEmpty == true
            ? (map['tags'] as String).split(',').where((s) => s.isNotEmpty).toList()
            : [],
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
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
