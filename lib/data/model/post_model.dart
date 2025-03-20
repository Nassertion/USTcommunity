// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:graduation_project/data/model/comment_model.dart';
import 'package:graduation_project/data/model/user_model.dart';
import 'package:http/http.dart';

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
  User user;
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
      required this.user,
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
        user: json['user'] != null
            ? User.fromJson(json['user'])
            : User.defaultUser(),
        comments: (json['comments'] is List)
            ? (json['comments'] as List)
                .map((comment) => Comment.fromJson(comment))
                .toList()
            : [],
      );
    } catch (e) {
      print("❌ خطأ في `Post.fromJson()`: $e");
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
        user: User.defaultUser(),
        comments: [],
      );
    }
  }
}
