import 'package:flutter/material.dart';
import 'package:graduation_project/data/model/comment_model.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;

  const CommentItem({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              comment.user.imageUrl != null && comment.user.imageUrl!.isNotEmpty
                  ? NetworkImage(comment.user.imageUrl!)
                  : AssetImage("assets/images/test.png") as ImageProvider,
        ),
        title: Text(comment.user.displayName),
        subtitle: Text(
            comment.body ?? "بدون محتوى"), // استخدام 'content' بدلاً من 'body'
        trailing: Text(comment.createdAt ?? ""), // تنسيق التاريخ
      ),
    );
  }
}
