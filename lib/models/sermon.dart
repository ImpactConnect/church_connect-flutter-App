class Sermon {
  final String id;
  final String title;
  final String? description;
  final String preacher;
  final String? audioUrl;
  final String? imageUrl;
  final DateTime sermonDate;
  final String? seriesName;
  final String? scriptureReference;
  final int? durationMinutes;
  final List<String> tags;
  final String category;
  final bool isDownloaded;
  final String? localAudioPath;
  final bool isFavorite;
  final double? progress;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sermon({
    required this.id,
    required this.title,
    this.description,
    required this.preacher,
    this.audioUrl,
    this.imageUrl,
    required this.sermonDate,
    this.seriesName,
    this.scriptureReference,
    this.durationMinutes,
    required this.tags,
    required this.category,
    required this.isDownloaded,
    this.localAudioPath,
    required this.isFavorite,
    this.progress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Sermon.fromSupabase(Map<String, dynamic> data) {
    return Sermon(
      id: data['id'],
      title: data['title'] ?? '',
      description: data['description'],
      preacher: data['preacher'] ?? '',
      audioUrl: data['audio_url'],
      imageUrl: data['image_url'],
      sermonDate: DateTime.parse(
          data['sermon_date'] ?? DateTime.now().toIso8601String()),
      seriesName: data['series_name'],
      scriptureReference: data['scripture_reference'],
      durationMinutes: data['duration_minutes']?.toInt(),
      tags: List<String>.from(data['tags'] ?? []),
      category: data['category'] ?? 'Others',
      isDownloaded: data['is_downloaded'] ?? false,
      localAudioPath: data['local_audio_path'],
      isFavorite: data['is_favorite'] ?? false,
      progress: data['progress']?.toDouble(),
      createdAt: DateTime.parse(
          data['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          data['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'preacher': preacher,
      'audio_url': audioUrl,
      'image_url': imageUrl,
      'sermon_date': sermonDate.toIso8601String(),
      'series_name': seriesName,
      'scripture_reference': scriptureReference,
      'duration_minutes': durationMinutes,
      'tags': tags,
      'category': category,
      'is_downloaded': isDownloaded,
      'local_audio_path': localAudioPath,
      'is_favorite': isFavorite,
      'progress': progress,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Sermon copyWith({
    String? id,
    String? title,
    String? description,
    String? preacher,
    String? audioUrl,
    String? imageUrl,
    DateTime? sermonDate,
    String? seriesName,
    String? scriptureReference,
    int? durationMinutes,
    List<String>? tags,
    String? category,
    bool? isDownloaded,
    String? localAudioPath,
    bool? isFavorite,
    double? progress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sermon(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      preacher: preacher ?? this.preacher,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      sermonDate: sermonDate ?? this.sermonDate,
      seriesName: seriesName ?? this.seriesName,
      scriptureReference: scriptureReference ?? this.scriptureReference,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      isFavorite: isFavorite ?? this.isFavorite,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum SermonCategory {
  relationshipAndMarriage('Relationship and Marriage'),
  family('Family'),
  business('Business'),
  spiritualDevelopment('Spiritual Development'),
  personalDevelopment('Personal Development'),
  leadership('Leadership'),
  finance('Finance'),
  businessDevelopment('Business Development'),
  others('Others');

  final String label;
  const SermonCategory(this.label);

  static SermonCategory fromString(String value) {
    return SermonCategory.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => SermonCategory.others,
    );
  }
}
