import 'package:graduation_project/data/model/user_model.dart';

class Comment {
  int id;
  String? content;
  String? createdAt;
  User user;

  Comment({
    required this.id,
    this.content,
    this.createdAt,
    required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content']?.toString() ?? "",
      createdAt: json['created_at']?.toString() ?? "",
      user: json['user'] != null
          ? User.fromJson(json['user'])
          : User.defaultUser(),
    );
  }
}
