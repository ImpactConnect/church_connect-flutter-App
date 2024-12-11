class Sermon {
  final int? id;
  final String title;
  final String preacher;
  final String category;
  final String? description;
  final String audioUrl;
  final bool isLocal;
  final DateTime date;
  final Duration duration;

  Sermon({
    this.id,
    required this.title,
    required this.preacher,
    required this.category,
    this.description,
    required this.audioUrl,
    required this.isLocal,
    required this.date,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'preacher': preacher,
      'category': category,
      'description': description,
      'audio_url': audioUrl,
      'is_local': isLocal ? 1 : 0,
      'date': date.toIso8601String(),
      'duration': duration.inSeconds,
    };
  }

  factory Sermon.fromMap(Map<String, dynamic> map) {
    return Sermon(
      id: map['id'] as int,
      title: map['title'] as String,
      preacher: map['preacher'] as String,
      category: map['category'] as String,
      description: map['description'] as String?,
      audioUrl: map['audio_url'] as String,
      isLocal: map['is_local'] == 1,
      date: DateTime.parse(map['date'] as String),
      duration: Duration(seconds: map['duration'] as int),
    );
  }
}
