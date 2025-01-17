import 'package:json_annotation/json_annotation.dart';

part 'live_stream.g.dart';

enum StreamStatus {
  scheduled,
  live,
  ended,
}

@JsonSerializable()
class LiveStream {
  final int id;
  final String title;
  @JsonKey(name: 'stream_url')
  final String streamUrl;
  @JsonKey(name: 'stream_key')
  final String? streamKey;
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  final StreamStatus status;
  @JsonKey(name: 'scheduled_start')
  final DateTime scheduledStart;
  @JsonKey(name: 'scheduled_end')
  final DateTime scheduledEnd;
  @JsonKey(name: 'actual_start')
  final DateTime? actualStart;
  @JsonKey(name: 'actual_end')
  final DateTime? actualEnd;
  final String? preacher;
  final String? description;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'viewer_count')
  final int viewerCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  LiveStream({
    required this.id,
    required this.title,
    required this.streamUrl,
    this.streamKey,
    this.thumbnailUrl,
    required this.status,
    required this.scheduledStart,
    required this.scheduledEnd,
    this.actualStart,
    this.actualEnd,
    this.preacher,
    this.description,
    required this.isFeatured,
    required this.viewerCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LiveStream.fromJson(Map<String, dynamic> json) =>
      _$LiveStreamFromJson(json);

  Map<String, dynamic> toJson() => _$LiveStreamToJson(this);
}
