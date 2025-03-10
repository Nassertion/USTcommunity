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
    return Post(
      id: json['id'] ?? 0, // تأكد من أن id ليس null
      userId: json['user_id'] ?? 0, // تأكد من أن userId ليس null
      title: json['title']?.toString() ?? "", // تجنب القيم null في النصوص
      body: json['body'] ?? "",
      attachmentUrl: json['attachment_url']?.toString() ?? "",
      createdAt: json['created_at'] ?? "",
      updatedAt: json['updated_at'] ?? "",
      isLiked: json['isLiked'] ?? false, // تأكد من أن isLiked قيمة صحيحة
      likes: json['likes'] ?? 0, // تأكد من أن likes ليس null
      user: json['user'] != null
          ? User.fromJson(json['user'])
          : User.defaultUser(),
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((comment) => Comment.fromJson(comment))
              .toList()
          : [],
    );
  }
}
