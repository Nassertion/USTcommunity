class Activity {
  final String id;
  final String type; // like, comment, follow
  final String username;
  final int userId;
  final String postId;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.type,
    required this.username,
    required this.userId,
    required this.postId,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return Activity(
      id: json['id'],
      type: data['type'],
      username: data['username'],
      userId: data['user_id'],
      postId: data['post_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
