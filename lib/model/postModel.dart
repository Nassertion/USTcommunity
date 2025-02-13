// ignore_for_file: public_member_api_docs, sort_constructors_first
// class post {
//   String username;
//   String avatarurl;
//   String contentText;
//   String? imgurl;
//   String? vid;
//   String? audio;
//   String? document;
//   DateTime time;
//   post({
//     required this.username,
//     required this.avatarurl,
//     required this.contentText,
//     required this.imgurl,
//     required this.vid,
//     required this.audio,
//     required this.document,
//     required this.time,
//   });
// }
class Post {
  final int id;
  final int userId;
  final String? title; // استخدم String? لأن القيم قد تكون null
  final String? body; // استخدم String? لأن القيم قد تكون null
  final String createdAt;

  Post({
    required this.id,
    required this.userId,
    this.title, // الحقل اختياري
    this.body, // الحقل اختياري
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'], // يمكن أن يكون null
      body: json['body'], // يمكن أن يكون null
      createdAt: json['created_at'],
    );
  }
}
