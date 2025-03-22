class User {
  int id;
  int userId;
  String displayName;
  int majorId;
  int level;
  String branch;
  String? bio;
  String? imageUrl;

  User({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.majorId,
    required this.level,
    required this.branch,
    this.bio,
    this.imageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      displayName: json['displayName'] ?? "مستخدم مجهول",
      majorId: json['major_id'] ?? 0,
      level: json['level'] ?? 0,
      branch: json['branch'] ?? "غير محدد",
      bio: json['bio']?.toString() ?? "",
      imageUrl: json['imageUrl']?.toString() ?? "",
    );
  }

  static User defaultUser() {
    return User(
      id: 0,
      userId: 0,
      displayName: "مستخدم افتراضي",
      majorId: 0,
      level: 0,
      branch: "غير محدد",
      bio: "",
      imageUrl: "",
    );
  }
}
