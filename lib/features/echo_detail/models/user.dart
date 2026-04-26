class User {
  final int id;
  final String name;
  final String? avatarUrl;
  final String? faculty;

  const User({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.faculty,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      faculty: json['faculty'],
    );
  }
}