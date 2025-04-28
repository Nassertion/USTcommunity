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
    String displayName = 'مستخدم مجهول';
    dynamic profileData = json['user']?['profile'] ?? json['profile'];

    if (profileData != null) {
      displayName = profileData['displayName']?.toString() ??
          profileData['username']?.toString() ??
          'مستخدم ${json['user_id']}';
    }

    return Comment(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      postId: json['post_id'] ?? 0,
      body: json['body'] ?? '',
      attachmentUrl: json['attachment_url'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      profile: Profile(
        id: profileData?['id'] ?? json['user_id'] ?? 0,
        userId: json['user_id'] ?? 0,
        displayName: displayName,
        majorId: profileData?['major_id'] ?? 0,
        level: profileData?['level'] ?? 0,
        branch: profileData?['branch']?.toString() ?? '',
        bio: profileData?['bio']?.toString(),
        imageUrl: profileData?['imageUrl']?.toString(),
      ),
    );
  }
}
