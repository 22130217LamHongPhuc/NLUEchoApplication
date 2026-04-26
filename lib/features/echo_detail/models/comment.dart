import 'package:echo_nlu/features/echo_detail/models/user.dart';

class Comment {
  final int id;
  final String content;
  final User user;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.content,
    required this.user,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      user: User.fromJson(json['user']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}