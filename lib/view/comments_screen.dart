import 'package:flutter/material.dart';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/data/model/comment_model.dart';
import 'package:graduation_project/data/model/post_model.dart';
import 'package:graduation_project/data/services/api_server.dart';
import 'package:graduation_project/widgets/comment_item.dart';

class CommentsScreen extends StatefulWidget {
  final Post post;

  const CommentsScreen({Key? key, required this.post}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool isLoading = false;

  Future<void> addComment() async {
    final String commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final response = await Crud().postrequest(
        "${linkPost}${widget.post.id}/comments",
        {
          'body': commentText,
        },
      );

      print(" استجابة الخادم: $response");

      if (response != null) {
        if (response['success'] == true || response['id'] != null) {
          setState(() {
            widget.post.comments.add(Comment.fromJson(response));
          });
          _commentController.clear();
        } else {
          print(
              " فشل في إضافة التعليق: ${response['message'] ?? 'لا توجد رسالة'}");
        }
      } else {
        print(" فشل في الحصول على استجابة من الخادم");
      }
    } catch (e) {
      print(" خطأ أثناء إضافة التعليق: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("التعليقات"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.post.comments.length,
              itemBuilder: (context, index) {
                final comment = widget.post.comments[index];
                return CommentItem(comment: comment);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "اكتب تعليقًا...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: isLoading ? null : addComment,
                  icon: Icon(Icons.send),
                  color: kPrimaryolor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
