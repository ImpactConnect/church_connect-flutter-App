class User {
  final String id;
  final String username;
  final String fullName;
  final String gender;
  final DateTime createdAt;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.gender,
    required this.createdAt,
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      gender: json['gender'],
      createdAt: DateTime.parse(json['created_at']),
      profileImageUrl: json['profile_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'gender': gender,
      'created_at': createdAt.toIso8601String(),
      'profile_image_url': profileImageUrl,
    };
  }
}
