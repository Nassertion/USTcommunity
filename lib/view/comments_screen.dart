import 'package:flutter/material.dart';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/data/model/comment_model.dart';
import 'package:graduation_project/data/model/post_model.dart';
import 'package:graduation_project/data/services/api_server.dart';
import 'package:graduation_project/widgets/comment_item.dart';

class CommentsScreen extends StatefulWidget {
  final int postId;

  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  Post? post;
  bool isLoadingPost = true;
  bool isLoadingComments = false;
  final TextEditingController _commentController = TextEditingController();
  bool isAddingComment = false;

  @override
  void initState() {
    super.initState();
    fetchPostDetails();
  }

  Future<void> fetchPostDetails() async {
    if (!mounted) return;
    setState(() {
      isLoadingPost = true;
    });

    try {
      final response = await Crud().getrequest("${linkPost}${widget.postId}");
      if (!mounted) return;

      if (response != null && response is Map<String, dynamic>) {
        setState(() {
          post = Post.fromJson(response);
        });
        await fetchComments();
      } else {
        setState(() {
          post = null;
        });
      }
    } catch (e) {
      print("خطأ في جلب بيانات البوست: $e");
      if (!mounted) return;
      setState(() {
        post = null;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoadingPost = false;
      });
    }
  }

  Future<void> fetchComments() async {
    if (post == null) return;

    setState(() => isLoadingComments = true);

    try {
      final response =
          await Crud().getrequest("${linkPost}${post!.id}/comments");

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
          post!.comments = newComments;
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
    if (commentText.isEmpty || post == null) return;

    setState(() => isAddingComment = true);

    try {
      final response = await Crud().postrequest(
        "${linkPost}${post!.id}/comments",
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
          post!.comments.insert(0, Comment.fromJson(response));
        });
        _commentController.clear();
      }
    } catch (e) {
      print("خطأ في إضافة التعليق: $e");
    } finally {
      setState(() => isAddingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("التعليقات"),
        centerTitle: true,
      ),
      body: isLoadingPost
          ? Center(child: CircularProgressIndicator())
          : post == null
              ? Center(child: Text("المنشور غير موجود"))
              : Column(
                  children: [
                    // عرض البوست أولاً
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Card(
                        color: kBackgroundColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post!.title ?? "",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text(post!.body ?? ""),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                    // عرض التعليقات
                    Expanded(
                      child: isLoadingComments
                          ? Center(child: CircularProgressIndicator())
                          : post!.comments.isEmpty
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
                                  itemCount: post!.comments.length,
                                  itemBuilder: (context, index) {
                                    final comment = post!.comments[index];
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
                            onPressed: isAddingComment ? null : addComment,
                            icon: isAddingComment
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
