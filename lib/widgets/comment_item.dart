import 'package:flutter/material.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/data/model/comment_model.dart';
import 'package:graduation_project/widgets/time_widget.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;

  const CommentItem({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kBackgroundColor,
      shadowColor: Colors.black,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              comment.user.imageUrl != null && comment.user.imageUrl!.isNotEmpty
                  ? NetworkImage(comment.user.imageUrl!)
                  : AssetImage("assets/images/user.png") as ImageProvider,
        ),
        title: Text(comment.user.displayName),
        subtitle: Text(comment.body ?? "بدون محتوى"),
        trailing: Text(formatPostDate(comment.createdAt) ?? ""),
      ),
    );
  }
}
