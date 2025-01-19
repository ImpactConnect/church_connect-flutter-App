class Devotional {
  final String id;
  final String title;
  final DateTime date;
  final String bibleReading;
  final String content;
  final String memoryVerse;
  final List<String> prayerPoints;
  final String author;
  final DateTime createdAt;
  final DateTime updatedAt;

  Devotional({
    required this.id,
    required this.title,
    required this.date,
    required this.bibleReading,
    required this.content,
    required this.memoryVerse,
    required this.prayerPoints,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Devotional.fromJson(Map<String, dynamic> json) {
    return Devotional(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      bibleReading: json['bible_reading'] as String,
      content: json['content'] as String,
      memoryVerse: json['memory_verse'] as String,
      prayerPoints: List<String>.from(json['prayer_points'] as List),
      author: json['author'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'bible_reading': bibleReading,
      'content': content,
      'memory_verse': memoryVerse,
      'prayer_points': prayerPoints,
      'author': author,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Devotional && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
