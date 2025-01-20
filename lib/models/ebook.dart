class Ebook {
  final String id;
  final String title;
  final String author;
  final String description;
  final String thumbnailUrl;
  final String bookUrl;
  final String category;
  final DateTime publishedDate;
  final bool isBookOfWeek;
  final bool isRecommended;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ebook({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.thumbnailUrl,
    required this.bookUrl,
    required this.category,
    required this.publishedDate,
    required this.isBookOfWeek,
    required this.isRecommended,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ebook.fromSupabase(Map<String, dynamic> data) {
    return Ebook(
      id: data['id'],
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      description: data['description'] ?? '',
      thumbnailUrl: data['thumbnail_url'] ?? '',
      bookUrl: data['book_url'] ?? '',
      category: data['category'] ?? '',
      publishedDate: DateTime.parse(data['published_date'] ?? DateTime.now().toIso8601String()),
      isBookOfWeek: data['is_book_of_week'] ?? false,
      isRecommended: data['is_recommended'] ?? false,
      viewCount: data['view_count'] ?? 0,
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'book_url': bookUrl,
      'category': category,
      'published_date': publishedDate.toIso8601String(),
      'is_book_of_week': isBookOfWeek,
      'is_recommended': isRecommended,
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
