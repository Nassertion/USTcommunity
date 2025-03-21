import 'package:graduation_project/data/model/user_model.dart';

class Comment {
  int id;
  int userId;
  int postId;
  String? body;
  String? attachmentUrl;
  String createdAt;
  String updatedAt;
  User user;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    this.body,
    this.attachmentUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      postId: json['post_id'],
      body: json['body'],
      attachmentUrl: json['attachment_url'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: User.fromJson(json['user']),
    );
  }
}
