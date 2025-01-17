class RadioStream {
  final String id;
  final String title;
  final String streamUrl;
  final bool isActive;

  RadioStream({
    required this.id,
    required this.title,
    required this.streamUrl,
    this.isActive = true,
  });

  factory RadioStream.fromJson(Map<String, dynamic> json) {
    return RadioStream(
      id: json['id'] as String,
      title: json['title'] as String,
      streamUrl: json['stream_url'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'stream_url': streamUrl,
      'is_active': isActive,
    };
  }
}
