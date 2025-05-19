import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/data/model/post_model.dart';
import 'package:graduation_project/data/services/api_server.dart';
import 'package:graduation_project/view/comments_screen.dart';
import 'package:graduation_project/widgets/readmore.dart';
import 'package:graduation_project/widgets/share_widget.dart';
import 'package:graduation_project/widgets/time_widget.dart';
import 'dart:convert';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Crud crud = Crud();
  List<Post> posts = [];
  bool isLoading = false;
  int page = 1;
  final int limit = 10;
  final ScrollController _scrollController = ScrollController();

  Map<int, bool> likedPosts = {}; // لحفظ حالة الإعجاب في الذاكرة
  Map<int, bool> savedPosts = {}; // لحفظ حالة الحفظ في الذاكرة

  @override
  void initState() {
    super.initState();
    fetchPosts();
    _scrollController.addListener(_onScroll);

    // جلب حالة الإعجاب وحالة الحفظ من SharedPreferences
    _loadLikedPosts();
    _loadSavedPosts();
  }

  // دالة لتحميل حالة الإعجاب من SharedPreferences
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

  // دالة لحفظ حالة الإعجاب في SharedPreferences
  Future<void> _saveLikedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final likedPostsData =
        likedPosts.map((key, value) => MapEntry(key.toString(), value));
    await prefs.setString('likedPosts', jsonEncode(likedPostsData));
    print("حالة الإعجاب تم حفظها بنجاح.");
  }

  // دالة لحفظ حالة الحفظ في SharedPreferences
  Future<void> _saveSavedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPostsData =
        savedPosts.map((key, value) => MapEntry(key.toString(), value));
    await prefs.setString('savedPosts', jsonEncode(savedPostsData));
    print("حالة الحفظ تم حفظها بنجاح.");
  }

  // دالة لتحميل حالة الحفظ من SharedPreferences
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

  Future<void> fetchPosts() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      var response =
          await crud.getrequest("${linkPost}?page=$page&limit=$limit");

      if (response != null && response is Map<String, dynamic>) {
        List<Post> newPosts = (response['data'] as List).map((postData) {
          if (postData['profile'] == null) {
            postData['profile'] = {
              'id': postData['user_id'],
              'user_id': postData['user_id'],
              'displayName': 'مستخدم ${postData['user_id']}',
              'major_id': 0,
              'level': 0,
              'branch': 'غير محدد',
              'bio': null,
              'imageUrl': null
            };
          }
          return Post.fromJson(postData);
        }).toList();

        setState(() {
          posts.addAll(newPosts);
          page++;
        });
      }
    } catch (e) {
      print("خطأ في جلب المنشورات: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      fetchPosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الرئيسية"), centerTitle: true),
      body: SafeArea(
        child: posts.isEmpty
            ? (isLoading
                ? Center(child: CircularProgressIndicator(color: kPrimaryolor))
                : Center(
                    child: Text("لا توجد منشورات ",
                        style: TextStyle(fontSize: 18))))
            : ListView.builder(
                controller: _scrollController,
                itemCount: posts.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == posts.length) {
                    return Center(
                        child: CircularProgressIndicator(color: kPrimaryolor));
                  }

                  Post post = posts[index];
                  bool isLiked = likedPosts[post.id] ?? false;
                  bool isSaved = savedPosts[post.id] ?? false;

                  // الجزء المهم من build method
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
                              backgroundImage: post.profile.imageUrl != null &&
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
                                  color:
                                      const Color.fromARGB(255, 121, 121, 121)),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: post.body != null && post.body!.length > 100
                                ? ExpandableContent(text: post.body!)
                                : Text(post.body ?? "بدون محتوى"),
                          ),
                          if (post.attachmentUrl != null &&
                              post.attachmentUrl!.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Image.network(
                                "${linkServerName}storage/${post.attachmentUrl}",
                                errorBuilder: (context, error, stackTrace) {
                                  return Text("لا يمكن تحميل الصورة");
                                },
                              ),
                            ),
                          if (post.attachmentUrl != null &&
                              post.attachmentUrl!.isNotEmpty)
                            // Padding(
                            //   padding:
                            //       const EdgeInsets.symmetric(vertical: 8.0),
                            //   child: Image.network(
                            //     "${linkServerName}storage/${post.attachmentUrl}",
                            //     fit: BoxFit.cover,
                            //     errorBuilder: (context, error, stackTrace) {
                            //       return Text('لا يمكن تحميل الصورة');
                            //     },
                            //   ),
                            // ),
                            SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  setState(() {
                                    likedPosts[post.id] =
                                        !(likedPosts[post.id] ?? false);
                                    post.likes += likedPosts[post.id]! ? 1 : -1;
                                  });

                                  final success = await crud.toggleLike(
                                      post.id, !(likedPosts[post.id] ?? false));
                                  if (!success) {
                                    setState(() {
                                      likedPosts[post.id] =
                                          !(likedPosts[post.id] ?? true);
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
                                      color: likedPosts[post.id] ?? false
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
                                          CommentsScreen(postId: post.id),
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
      ),
    );
  }
}
