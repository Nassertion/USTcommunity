class Profile {
  int id;
  int userId;
  String displayName;
  int majorId;
  int level;
  String branch;
  String? bio;
  String? imageUrl;
  String? major;

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
      displayName: json['displayName']?.toString() ??
          'مستخدم ${json['user_id'] ?? json['id'] ?? 'مجهول'}',
      majorId: json['major_id'] ?? 0,
      level: json['level'] ?? 0,
      branch: json['branch']?.toString() ?? 'غير محدد',
      bio: json['bio']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      major: json['major']?.toString(),
    );
  }

  static Profile defaultProfile() {
    return Profile(
      id: 0,
      userId: 0,
      displayName: 'مستخدم مجهول',
      majorId: 0,
      level: 0,
      branch: 'غير محدد',
      bio: null,
      imageUrl: null,
      major: null,
    );
  }
}
