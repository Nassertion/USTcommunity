import 'package:flutter/material.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/data/model/comment_model.dart';
import 'package:graduation_project/widgets/time_widget.dart'; // التأكد من استخدام الوقت بشكل صحيح

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
          backgroundImage: comment.profile.imageUrl != null &&
                  comment.profile.imageUrl!.isNotEmpty
              ? NetworkImage(comment.profile.imageUrl!)
              : AssetImage("assets/images/user.png") as ImageProvider,
        ),
        title: Text(
          comment.profile.displayName.isNotEmpty
              ? comment.profile.displayName
              : 'مستخدم ${comment.userId}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(comment.body ?? "بدون محتوى"),
        trailing: Text(formatPostDate(comment.createdAt) ?? ""),
      ),
    );
  }
}
