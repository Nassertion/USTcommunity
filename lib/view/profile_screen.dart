import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/data/services/api_server.dart';
import 'package:graduation_project/view/comments_screen.dart';
import 'package:graduation_project/view/edit_post_screen.dart';
import 'package:graduation_project/view/edit_profile.dart';
import 'package:graduation_project/widgets/app_bar.dart';
import 'package:graduation_project/data/model/profile_model.dart';
import 'package:graduation_project/data/model/post_model.dart';
import 'package:graduation_project/widgets/readmore.dart';
import 'package:graduation_project/widgets/share_widget.dart';
import 'package:graduation_project/widgets/time_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Post> posts = [];
  List<dynamic> followers = [];
  List<dynamic> followings = [];
  bool isLoadingPosts = false;
  bool isLoadingFollowers = false;
  bool isLoadingFollowings = false;
  Profile? profile;

  // للحفظ مؤقت لحالة الإعجاب والحفظ على المنشورات داخل الصفحة الشخصية (اختياري)
  Map<int, bool> likedPosts = {};
  Map<int, bool> savedPosts = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchProfileData();
    _loadLikedPosts();
    _loadSavedPosts();
  }

  Future<bool> deletePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return false;

    final uri = Uri.parse("${linkServerName}api/v1/posts/$postId");
    final response = await http.delete(uri, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      print('فشل حذف المنشور: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  Future<void> _saveSavedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPostsData =
        savedPosts.map((key, value) => MapEntry(key.toString(), value));
    await prefs.setString('savedPosts', jsonEncode(savedPostsData));
  }

  Future<void> _loadLikedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final likedPostsData = prefs.getString('likedPosts');
    if (likedPostsData != null) {
      final Map<String, dynamic> decoded = jsonDecode(likedPostsData);
      setState(() {
        likedPosts = decoded
            .map((key, value) => MapEntry(int.parse(key), value as bool));
      });
    }
  }

  Future<void> _loadSavedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPostsData = prefs.getString('savedPosts');
    if (savedPostsData != null) {
      final Map<String, dynamic> decoded = jsonDecode(savedPostsData);
      setState(() {
        savedPosts = decoded
            .map((key, value) => MapEntry(int.parse(key), value as bool));
      });
    }
  }

  Future<void> fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    final token = await crud.getToken();
    if (token != null && userId != null) {
      final response =
          await crud.getrequest("${linkServerName}api/v1/user/profile/$userId");

      print("Response profile: $response");

      if (response != null && response['profile'] != null) {
        setState(() {
          profile = Profile.fromJson(response['profile']);
        });
        fetchUserPosts();
        fetchFollowers();
        fetchFollowings();
      } else {
        print("Profile data not found in response");
      }
    }
  }

  // جلب منشورات المستخدم عن طريق جلب المنشورات كلها وتصفيتها محلياً
  Future<void> fetchUserPosts() async {
    setState(() => isLoadingPosts = true);

    try {
      final response = await crud
          .getrequest("${linkServerName}api/v1/posts?page=1&limit=100");
      if (response != null && response is Map<String, dynamic>) {
        final allPosts = response['data'] as List;
        final filteredPosts = allPosts
            .where((post) => post['user_id'] == profile?.userId)
            .toList();

        setState(() {
          posts =
              filteredPosts.map((postData) => Post.fromJson(postData)).toList();
        });
      } else {
        setState(() {
          posts = [];
        });
      }
    } catch (e) {
      print("خطأ في جلب منشورات المستخدم: $e");
    } finally {
      setState(() => isLoadingPosts = false);
    }
  }

  Future<void> _saveLikedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final likedPostsData =
        likedPosts.map((key, value) => MapEntry(key.toString(), value));
    await prefs.setString('likedPosts', jsonEncode(likedPostsData));
  }

  Future<void> fetchFollowers() async {
    setState(() => isLoadingFollowers = true);

    try {
      final response = await crud.getrequest(
          "${linkServerName}api/v1/user/profile/${profile?.id}/followers");

      if (response != null && response is List) {
        setState(() {
          followers = response;
        });
      }
    } catch (e) {
      print("خطأ في جلب المتابعين: $e");
    } finally {
      setState(() => isLoadingFollowers = false);
    }
  }

  Future<void> fetchFollowings() async {
    setState(() => isLoadingFollowings = true);

    try {
      final response = await crud.getrequest(
          "${linkServerName}api/v1/user/profile/${profile?.id}/followings");

      if (response != null && response is List) {
        setState(() {
          followings = response;
        });
      }
    } catch (e) {
      print("خطأ في جلب المتابعين لديك: $e");
    } finally {
      setState(() => isLoadingFollowings = false);
    }
  }

  Future<void> logout(BuildContext context) async {
    final response = await crud.postrequest(linklogout, {});

    if (response != null) {
      await crud.deleteToken();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
          "الملف الشخصي ",
          IconButton(
              onPressed: () {
                logout(context);
              },
              icon: Icon(Icons.logout))),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile?.displayName ?? 'الاسم غير متوفر',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text("المستوى: ${profile?.level ?? 'غير محدد'}",
                            style: TextStyle(fontSize: 16)),
                        Text("التخصص: ${profile?.major ?? 'غير محدد'}",
                            style: TextStyle(fontSize: 16)),
                        Text("الفرع: ${profile?.branch ?? 'غير محدد'}",
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Text(profile?.bio ?? 'لا يوجد بايو',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: CircleAvatar(
                        backgroundImage: profile?.imageUrl != null &&
                                profile?.imageUrl!.isNotEmpty == true
                            ? NetworkImage(profile!.imageUrl!)
                            : AssetImage("assets/images/user.png")
                                as ImageProvider,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 40),
                OutlinedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          currentDisplayName: profile?.displayName,
                          currentBio: profile?.bio,
                          currentImageUrl: profile?.imageUrl,
                        ),
                      ),
                    );

                    if (result == true) {
                      fetchProfileData();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 120, vertical: 10),
                    child: Text("تعديل الملف",
                        style: TextStyle(color: kPrimaryolor)),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FollowersListScreen(followers: followers),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            "${followers.length}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryolor,
                            ),
                          ),
                          Text("المتابعين"),
                        ],
                      ),
                    ),
                    SizedBox(width: 40),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FollowingsListScreen(followings: followings),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            "${followings.length}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryolor,
                            ),
                          ),
                          Text("المتابعون لديك"),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  height: 60,
                  child: TabBar(
                    labelColor: kPrimaryolor,
                    indicatorColor: kPrimaryolor,
                    controller: _tabController,
                    tabs: [
                      Tab(text: "المنشورات"),
                      Tab(text: "المحفوظة"),
                      Tab(text: "التعليقات")
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                isLoadingPosts
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () async {
                          // سطر ~72
                          setState(() {
                            posts.clear(); // سطر ~73
                            // page = 1; // سطر ~74
                          });
                          await fetchUserPosts(); // سطر ~75
                        },
                        child: ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            Post post = posts[index];
                            bool isLiked = likedPosts[post.id] ?? false;
                            bool isSaved = savedPosts[post.id] ?? false;

                            return Card(
                              color: kBackgroundColor,
                              margin: EdgeInsets.all(8),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: post
                                                        .profile.imageUrl !=
                                                    null &&
                                                post.profile.imageUrl!
                                                    .isNotEmpty
                                            ? NetworkImage(
                                                post.profile.imageUrl!)
                                            : AssetImage(
                                                    "assets/images/user.png")
                                                as ImageProvider,
                                      ),
                                      title: Text(
                                        post.profile.displayName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Text(
                                        formatPostDate(post.createdAt),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: const Color.fromARGB(
                                                255, 121, 121, 121)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 10),
                                      child: post.title != null
                                          ? Text(
                                              post.title ?? "",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 17),
                                            )
                                          : Text(post.title ?? "بدون محتوى",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: post.body != null &&
                                              post.body!.length > 100
                                          ? ExpandableContent(text: post.body!)
                                          : Text(post.body ?? "بدون محتوى"),
                                    ),
                                    if (post.attachmentUrl != null &&
                                        post.attachmentUrl!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3.0),
                                        child: Image.network(
                                          "${linkServerName}storage/${post.attachmentUrl}",
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Text("لا يمكن تحميل الصورة");
                                          },
                                        ),
                                      ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            setState(() {
                                              likedPosts[post.id] =
                                                  !(likedPosts[post.id] ??
                                                      false);
                                              post.likes +=
                                                  likedPosts[post.id]! ? 1 : -1;
                                            });

                                            final success =
                                                await crud.toggleLike(
                                                    post.id,
                                                    !(likedPosts[post.id] ??
                                                        false));
                                            if (!success) {
                                              setState(() {
                                                likedPosts[post.id] =
                                                    !(likedPosts[post.id] ??
                                                        true);
                                                post.likes +=
                                                    likedPosts[post.id]!
                                                        ? 1
                                                        : -1;
                                              });
                                            }

                                            await _saveLikedPosts();
                                          },
                                          icon: Row(
                                            children: [
                                              Icon(
                                                likedPosts[post.id] ?? false
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color:
                                                    likedPosts[post.id] ?? false
                                                        ? Colors.red
                                                        : null,
                                              ),
                                              SizedBox(width: 4),
                                              Text("${post.likes}"),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CommentsScreen(
                                                        postId: post.id),
                                              ),
                                            );
                                          },
                                          icon: Row(
                                            children: [
                                              Icon(Icons.message),
                                              SizedBox(width: 4),
                                              Text("${post.comments.length}"),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            sharePost(post.id);
                                          },
                                          icon: Icon(Icons.share),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            setState(() {
                                              savedPosts[post.id] =
                                                  !(savedPosts[post.id] ??
                                                      false);
                                            });
                                            await _saveSavedPosts();
                                            print(
                                                "✅ تم ${savedPosts[post.id]! ? "الحفظ" : "إلغاء الحفظ"} على المنشور: ${post.id}");
                                          },
                                          icon: Icon(
                                            savedPosts[post.id] ?? false
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,
                                            color: savedPosts[post.id] ?? false
                                                ? Colors.blue
                                                : null,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    EditPostScreen(post: post),
                                              ),
                                            );
                                            if (result == true) {
                                              // تحديث المنشورات بعد التعديل
                                              setState(() {
                                                // posts.clear();
                                                // page = 1;
                                              });
                                              fetchUserPosts();
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () async {
                                            final confirm =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('تأكيد الحذف'),
                                                content: Text(
                                                    'هل أنت متأكد من حذف هذا المنشور؟'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, false),
                                                    child: Text('إلغاء'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, true),
                                                    child: Text('حذف'),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm == true) {
                                              bool success =
                                                  await deletePost(post.id);
                                              if (success) {
                                                setState(() {
                                                  posts.removeAt(index);
                                                });
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'تم حذف المنشور')),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'فشل حذف المنشور')),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                // تبويب "المحفوظة" - نستخدم هنا posts المحفوظة (savedPosts)
                isLoadingPosts
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: posts
                            .where((post) => savedPosts[post.id] ?? false)
                            .length,
                        itemBuilder: (context, index) {
                          final savedList = posts
                              .where((post) => savedPosts[post.id] ?? false)
                              .toList();
                          Post post = savedList[index];
                          bool isLiked = likedPosts[post.id] ?? false;
                          bool isSaved = savedPosts[post.id] ?? false;

                          return Card(
                            color: kBackgroundColor,
                            margin: EdgeInsets.all(8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: post.profile.imageUrl !=
                                                  null &&
                                              post.profile.imageUrl!.isNotEmpty
                                          ? NetworkImage(post.profile.imageUrl!)
                                          : AssetImage("assets/images/user.png")
                                              as ImageProvider,
                                    ),
                                    title: Text(
                                      post.profile.displayName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      formatPostDate(post.createdAt),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: const Color.fromARGB(
                                              255, 121, 121, 121)),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 10),
                                    child: post.title != null
                                        ? Text(post.title ?? "",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 17))
                                        : Text(post.title ?? "بدون محتوى",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: post.body != null &&
                                            post.body!.length > 100
                                        ? ExpandableContent(text: post.body!)
                                        : Text(post.body ?? "بدون محتوى"),
                                  ),
                                  if (post.attachmentUrl != null &&
                                      post.attachmentUrl!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 3.0),
                                      child: Image.network(
                                        "${linkServerName}storage/${post.attachmentUrl}",
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Text("لا يمكن تحميل الصورة");
                                        },
                                      ),
                                    ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          setState(() {
                                            likedPosts[post.id] =
                                                !(likedPosts[post.id] ?? false);
                                            post.likes +=
                                                likedPosts[post.id]! ? 1 : -1;
                                          });

                                          final success = await crud.toggleLike(
                                              post.id,
                                              !(likedPosts[post.id] ?? false));
                                          if (!success) {
                                            setState(() {
                                              likedPosts[post.id] =
                                                  !(likedPosts[post.id] ??
                                                      true);
                                              post.likes +=
                                                  likedPosts[post.id]! ? 1 : -1;
                                            });
                                          }

                                          await _saveLikedPosts();
                                        },
                                        icon: Row(
                                          children: [
                                            Icon(
                                              likedPosts[post.id] ?? false
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color:
                                                  likedPosts[post.id] ?? false
                                                      ? Colors.red
                                                      : null,
                                            ),
                                            SizedBox(width: 4),
                                            Text("${post.likes}"),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CommentsScreen(
                                                      postId: post.id),
                                            ),
                                          );
                                        },
                                        icon: Row(
                                          children: [
                                            Icon(Icons.message),
                                            SizedBox(width: 4),
                                            Text("${post.comments.length}"),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          sharePost(post.id);
                                        },
                                        icon: Icon(Icons.share),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          setState(() {
                                            savedPosts[post.id] =
                                                !(savedPosts[post.id] ?? false);
                                          });
                                          await _saveSavedPosts();
                                          print(
                                              "✅ تم ${savedPosts[post.id]! ? "الحفظ" : "إلغاء الحفظ"} على المنشور: ${post.id}");
                                        },
                                        icon: Icon(
                                          savedPosts[post.id] ?? false
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                          color: savedPosts[post.id] ?? false
                                              ? Colors.blue
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                Center(child: Text("محتوى التعليقات")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FollowersListScreen extends StatelessWidget {
  final List<dynamic> followers;

  const FollowersListScreen({Key? key, required this.followers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("المتابعين")),
      body: ListView.builder(
        itemCount: followers.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  followers[index]['profile']['imageUrl'] != null &&
                          followers[index]['profile']['imageUrl'].isNotEmpty
                      ? NetworkImage(followers[index]['profile']['imageUrl'])
                      : AssetImage("assets/images/user.png") as ImageProvider,
            ),
            title: Text(followers[index]['profile']['displayName']),
          );
        },
      ),
    );
  }
}

class FollowingsListScreen extends StatelessWidget {
  final List<dynamic> followings;

  const FollowingsListScreen({Key? key, required this.followings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("المتابعون لديك")),
      body: ListView.builder(
        itemCount: followings.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  followings[index]['profile']['imageUrl'] != null &&
                          followings[index]['profile']['imageUrl'].isNotEmpty
                      ? NetworkImage(followings[index]['profile']['imageUrl'])
                      : AssetImage("assets/images/user.png") as ImageProvider,
            ),
            title: Text(followings[index]['profile']['displayName']),
          );
        },
      ),
    );
  }
}
