import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart';

@JsonSerializable()
class ChurchService {
  final int id;
  final String title;
  final DateTime serviceDate;
  final String theme;
  final String? description;
  final bool isSpecialService;
  final String? preacher;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  ChurchService({
    required this.id,
    required this.title,
    required this.serviceDate,
    required this.theme,
    this.description,
    required this.isSpecialService,
    this.preacher,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChurchService.fromJson(Map<String, dynamic> json) =>
      _$ChurchServiceFromJson(json);

  Map<String, dynamic> toJson() => _$ChurchServiceToJson(this);
}
