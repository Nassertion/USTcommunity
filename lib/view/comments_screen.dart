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
  bool isLoadingComments = false;

  Future<void> fetchComments() async {
    setState(() => isLoadingComments = true);

    try {
      final response = await Crud().getrequest(
        "${linkPost}${widget.post.id}/comments",
      );

      if (response != null && response is List) {
        List<Comment> newComments = response.map((data) {
          if (data['user'] == null && data['user_id'] != null) {
            data['user'] = {
              'profile': {
                'displayName': 'مستخدم ${data['user_id']}',
                'id': data['user_id'],
                'major_id': 0,
                'level': 0,
                'branch': '',
                'bio': null,
                'imageUrl': null,
              }
            };
          }
          return Comment.fromJson(data);
        }).toList();

        setState(() {
          widget.post.comments = newComments;
        });
      }
    } catch (e) {
      print("خطأ في جلب التعليقات: $e");
    } finally {
      setState(() => isLoadingComments = false);
    }
  }

  Future<void> addComment() async {
    final String commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final response = await Crud().postrequest(
        "${linkPost}${widget.post.id}/comments",
        {'body': commentText},
      );

      if (response != null && response['id'] != null) {
        if (response['user'] == null) {
          response['user'] = {
            'profile': {
              'displayName': 'أنت',
              'imageUrl': null,
            }
          };
        }

        setState(() {
          widget.post.comments.insert(0, Comment.fromJson(response));
        });
        _commentController.clear();
      }
    } catch (e) {
      print("خطأ في إضافة التعليق: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchComments();
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
            child: isLoadingComments
                ? Center(child: CircularProgressIndicator())
                : widget.post.comments.isEmpty
                    ? Center(
                        child: Text(
                          "لا يوجد تعليقات",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
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
                  icon: isLoading
                      ? CircularProgressIndicator()
                      : Icon(Icons.send),
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
