import 'package:graduation_project/data/model/profile_model.dart';
import 'package:graduation_project/data/model/user_model.dart';

class Comment {
  int id;
  int userId;
  int postId;
  String body;
  String? attachmentUrl;
  String createdAt;
  String updatedAt;
  Profile profile;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.body,
    this.attachmentUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.profile,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      postId: json['post_id'] ?? 0,
      body: json['body'] ?? '',
      attachmentUrl: json['attachment_url'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      profile: Profile.fromJson(json['profile'] ?? {}),
    );
  }
}
