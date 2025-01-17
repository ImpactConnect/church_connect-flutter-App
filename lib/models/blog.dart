import 'package:timeago/timeago.dart' as timeago;

class Blog {
  final String id;
  final String title;
  final String content;
  final String? excerpt;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final List<String>? tags;
  final Author author;
  final int likesCount;
  final bool isLikedByCurrentUser;

  Blog({
    required this.id,
    required this.title,
    required this.content,
    this.excerpt,
    this.thumbnailUrl,
    required this.createdAt,
    this.tags,
    required this.author,
    this.likesCount = 0,
    this.isLikedByCurrentUser = false,
  });

  String get timeAgo => timeago.format(createdAt);

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  Blog copyWith({
    bool? isLikedByCurrentUser,
    int? likesCount,
  }) {
    return Blog(
      id: id,
      title: title,
      content: content,
      excerpt: excerpt,
      thumbnailUrl: thumbnailUrl,
      createdAt: createdAt,
      tags: tags,
      author: author,
      likesCount: likesCount ?? this.likesCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      excerpt: json['excerpt'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      createdAt: DateTime.parse(json['created_at']),
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'])
          : null,
      author: Author.fromJson(json['author']),
      likesCount: json['likes_count'] ?? 0,
      isLikedByCurrentUser: json['is_liked_by_current_user'] ?? false,
    );
  }
}

class Author {
  final String id;
  final String fullName;
  final String? profileImageUrl;

  Author({
    required this.id,
    required this.fullName,
    this.profileImageUrl,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      fullName: json['full_name'],
      profileImageUrl: json['profile_image_url'],
    );
  }
}
