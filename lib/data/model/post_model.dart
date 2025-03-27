// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:graduation_project/data/model/comment_model.dart';
import 'package:graduation_project/data/model/profile_model.dart';
import 'package:graduation_project/data/model/user_model.dart';

class Post {
  int id;
  int userId;
  String? title;
  String? body;
  String? attachmentUrl;
  String createdAt;
  String updatedAt;
  bool isLiked;
  int likes;
  Profile profile;
  List<Comment> comments;

  Post(
      {required this.id,
      required this.userId,
      this.title,
      this.body,
      this.attachmentUrl,
      required this.createdAt,
      required this.updatedAt,
      required this.isLiked,
      required this.likes,
      required this.profile,
      required this.comments});

  factory Post.fromJson(Map<String, dynamic> json) {
    try {
      return Post(
        id: json['id'] ?? 0,
        userId: json['user_id'] ?? 0,
        title: json['title']?.toString() ?? "",
        body: json['body']?.toString() ?? "",
        attachmentUrl: json['attachment_url']?.toString() ?? "",
        createdAt: json['created_at'] ?? "",
        updatedAt: json['updated_at'] ?? "",
        isLiked:
            json['isLiked'] is bool ? json['isLiked'] : (json['isLiked'] == 1),
        likes: json['likes'] ?? 0,
        profile: Profile.fromJson(json['profile'] ?? {}),
        comments: (json['comments'] is List)
            ? (json['comments'] as List).map((comment) {
                // معالجة التعليقات القديمة
                if (comment['user'] == null && comment['user_id'] != null) {
                  comment['user'] = {
                    'profile': {
                      'displayName': 'مستخدم ${comment['user_id']}',
                      'id': comment['user_id'],
                      'user_id': comment['user_id'],
                      'major_id': 0,
                      'level': 0,
                      'branch': 'غير محدد',
                      'bio': null,
                      'imageUrl': null
                    }
                  };
                }
                return Comment.fromJson(comment);
              }).toList()
            : [],
      );
    } catch (e) {
      print("خطأ في تحويل بيانات المنشور: $e");
      return Post(
        id: 0,
        userId: 0,
        title: "",
        body: "",
        attachmentUrl: "",
        createdAt: "",
        updatedAt: "",
        isLiked: false,
        likes: 0,
        profile: Profile.defaultProfile(),
        comments: [],
      );
    }
  }
  Post copyWith({
    int? id,
    int? userId,
    String? body,
    String? createdAt,
    String? updatedAt,
    User? user,
    bool? isLiked,
    int? likes,
    List<Comment>? comments,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profile: profile ?? this.profile,
      isLiked: isLiked ?? this.isLiked,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }
}
