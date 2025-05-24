import 'package:flutter/material.dart';
import 'package:graduation_project/view/report_screen.dart';
import 'package:graduation_project/view/comments_screen.dart';
import 'package:graduation_project/view/edit_post_screen.dart'; // شاشة التعديل
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/data/model/post_model.dart';
import 'package:graduation_project/data/services/api_server.dart';
import 'package:graduation_project/widgets/readmore.dart';
import 'package:graduation_project/widgets/share_widget.dart';
import 'package:graduation_project/widgets/time_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  int? currentUserId;

  Map<int, bool> likedPosts = {}; // لحفظ حالة الإعجاب
  Map<int, bool> savedPosts = {}; // لحفظ حالة الحفظ

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
    fetchPosts();
    _scrollController.addListener(_onScroll);

    _loadLikedPosts();
    _loadSavedPosts();
  }

  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = int.tryParse(prefs.getString('user_id') ?? '');
    });
  }

  // تحميل حالة الإعجاب من SharedPreferences
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

  // حفظ حالة الإعجاب في SharedPreferences
  Future<void> _saveLikedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final likedPostsData =
        likedPosts.map((key, value) => MapEntry(key.toString(), value));
    await prefs.setString('likedPosts', jsonEncode(likedPostsData));
  }

  // تحميل حالة الحفظ من SharedPreferences
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

  // حفظ حالة الحفظ في SharedPreferences
  Future<void> _saveSavedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPostsData =
        savedPosts.map((key, value) => MapEntry(key.toString(), value));
    await prefs.setString('savedPosts', jsonEncode(savedPostsData));
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
        child: RefreshIndicator(
          onRefresh: () async {
            // سطر ~72
            setState(() {
              posts.clear(); // سطر ~73
              page = 1; // سطر ~74
            });
            await fetchPosts(); // سطر ~75
          },
          child: posts.isEmpty
              ? (isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: kPrimaryolor))
                  : Center(
                      child: Text("لا توجد منشورات ",
                          style: TextStyle(fontSize: 18)),
                    ))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: posts.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == posts.length) {
                      return Center(
                        child: CircularProgressIndicator(color: kPrimaryolor),
                      );
                    }

                    Post post = posts[index];
                    bool isLiked = likedPosts[post.id] ?? false;
                    bool isSaved = savedPosts[post.id] ?? false;
                    bool isUserPost =
                        currentUserId != null && currentUserId == post.userId;

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
                                backgroundImage:
                                    post.profile.imageUrl != null &&
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
                                    color: Color.fromARGB(255, 121, 121, 121)),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child:
                                  post.body != null && post.body!.length > 100
                                      ? ExpandableContent(text: post.body!)
                                      : Text(post.body ?? "بدون محتوى"),
                            ),
                            if (post.attachmentUrl != null &&
                                post.attachmentUrl!.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3.0),
                                child: Image.network(
                                  "${linkServerName}storage/${post.attachmentUrl}",
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text("لا يمكن تحميل الصورة");
                                  },
                                ),
                              ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                    // نحدد الحالة الجديدة وهي عكس الحالة الحالية
                                    final newBookmarkState =
                                        await crud.toggleBookmark(post.id,
                                            savedPosts[post.id] ?? false);

                                    if (newBookmarkState == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('فشل في حفظ المفضلة')),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      savedPosts[post.id] = newBookmarkState;
                                    });

                                    await _saveSavedPosts();
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
                                if (!isUserPost)
                                  IconButton(
                                    onPressed: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setInt(
                                          'postIdForReport', post.id);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ReportScreen()),
                                      );
                                    },
                                    icon: Icon(Icons.report),
                                  ),
                                if (isUserPost) ...[
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
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
                                          posts.clear();
                                          page = 1;
                                        });
                                        fetchPosts();
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('تأكيد الحذف'),
                                          content: Text(
                                              'هل أنت متأكد من حذف هذا المنشور؟'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: Text('إلغاء'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
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
                                                content:
                                                    Text('تم حذف المنشور')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text('فشل حذف المنشور')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
