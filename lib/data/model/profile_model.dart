class Profile {
  int id;
  int userId;
  String displayName;
  int majorId;
  int level;
  String branch;
  String? bio;
  String? imageUrl;
  String? major; // تمت إضافته بناءً على البيانات

  Profile({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.majorId,
    required this.level,
    required this.branch,
    this.bio,
    this.imageUrl,
    this.major,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      displayName: json['displayName'] ?? "مستخدم مجهول",
      majorId: json['major_id'] ?? 0,
      level: json['level'] ?? 0,
      branch: json['branch'] ?? "غير محدد",
      bio: json['bio']?.toString() ?? "",
      imageUrl: json['imageUrl']?.toString() ?? "",
      major: json['major']?.toString(),
    );
  }

  static Profile defaultProfile() {
    return Profile(
      id: 0,
      userId: 0,
      displayName: "مستخدم افتراضي",
      majorId: 0,
      level: 0,
      branch: "غير محدد",
      bio: "",
      imageUrl: "",
      major: "",
    );
  }
}
