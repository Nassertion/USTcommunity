import 'package:graduation_project/data/model/comment_model.dart';
import 'package:graduation_project/data/model/post_model.dart';
import 'package:graduation_project/data/model/profile_model.dart';

class User {
  int id;
  int username;
  bool isAdmin;
  int userTypeId;
  String createdAt;
  String updatedAt;
  int following;
  int followers;
  Profile profile;
  List<Post> posts;
  List<Comment> comments;

  User({
    required this.id,
    required this.username,
    required this.isAdmin,
    required this.userTypeId,
    required this.createdAt,
    required this.updatedAt,
    required this.following,
    required this.followers,
    required this.profile,
    required this.posts,
    required this.comments,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? 0,
      isAdmin: (json['isAdmin'] ?? 0) == 1,
      userTypeId: json['user_type_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      following: json['following'] ?? 0,
      followers: json['followers'] ?? 0,
      profile: Profile.fromJson(json['profile'] ?? {}),
      posts: (json['posts'] as List<dynamic>?)
              ?.map((post) => Post.fromJson(post))
              .toList() ??
          [],
      comments: (json['comments'] as List<dynamic>?)
              ?.map((comment) => Comment.fromJson(comment))
              .toList() ??
          [],
    );
  }

  static User defaultUser() {
    return User(
      id: 0,
      username: 0,
      isAdmin: false,
      userTypeId: 0,
      createdAt: '',
      updatedAt: '',
      following: 0,
      followers: 0,
      profile: Profile.defaultProfile(),
      posts: [],
      comments: [],
    );
  }
}
