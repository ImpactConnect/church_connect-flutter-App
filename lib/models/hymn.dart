class Hymn {
  final int number;
  final String title;
  final String author;
  final List<String> verses;
  final String? chorus;
  final String? tune;

  Hymn({
    required this.number,
    required this.title,
    required this.author,
    required this.verses,
    this.chorus,
    this.tune,
  });

  factory Hymn.fromJson(Map<String, dynamic> json) {
    return Hymn(
      number: json['number'] as int,
      title: json['title'] as String,
      author: json['author'] as String,
      verses: List<String>.from(json['verses'] as List),
      chorus: json['chorus'] as String?,
      tune: json['tune'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'title': title,
      'author': author,
      'verses': verses,
      'chorus': chorus,
      'tune': tune,
    };
  }
}
