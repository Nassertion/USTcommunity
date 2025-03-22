import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:graduation_project/view/comments_screen.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/data/services/api_server.dart';
import 'package:graduation_project/widgets/readmore.dart';
import 'package:graduation_project/widgets/share_widget.dart';
import "../data/model/post_model.dart";
import 'package:graduation_project/widgets/time_widget.dart';

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

  Map<int, bool> likedPosts = {};
  Map<int, bool> savedPosts = {};
  Future<void> toggleLike(int postId, bool isLiked) async {
    try {
      print(
          "🔄 جاري ${isLiked ? "إلغاء الإعجاب" : "الإعجاب"} على المنشور: $postId");

      final response = await crud.toggleLike(postId, isLiked);

      if (response != null && response['success'] == true) {
        setState(() {
          likedPosts[postId] = !isLiked; // تحديث حالة الإعجاب
        });
        print(
            "✅ تم ${isLiked ? "إلغاء الإعجاب" : "الإعجاب"} بنجاح على المنشور: $postId");
      } else {
        print(
            "❌ فشل في ${isLiked ? "إلغاء الإعجاب" : "الإعجاب"} على المنشور: $postId");
      }
    } catch (e) {
      print("❌ خطأ أثناء ${isLiked ? "إلغاء الإعجاب" : "الإعجاب"}: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPosts();
    _scrollController.addListener(_onScroll);
  }

  Future<void> fetchPosts() async {
    if (isLoading) return;

    setState(() => isLoading = true);
    print(" جاري تحميل البيانات الصفحة: $page");

    try {
      var response =
          await crud.getrequest("${linkPost}?page=$page&limit=$limit");

      print(" استجابة API الأولية: ${response}");

      if (response != null && response is List) {
        List<Post> newPosts =
            response.map((data) => Post.fromJson(data)).toList();

        if (newPosts.isEmpty) {
          print(" لا يوجد منشورات جديدة");
        }

        setState(() {
          posts.addAll(newPosts);
          page++; // زيادة رقم الصفحة
        });
      } else {
        print(" خطأ: البيانات المستلمة ليست قائمة. الاستجابة: $response");
      }
    } catch (e) {
      print(" خطأ أثناء جلب المنشورات: $e");
    }

    setState(() => isLoading = false);
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

                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: post.user.imageUrl != null &&
                                  post.user.imageUrl!.isNotEmpty
                              ? NetworkImage(post.user.imageUrl!)
                              : AssetImage("assets/images/user.png")
                                  as ImageProvider,
                          backgroundColor: Colors.black,
                        ),
                        title: Text("المستخدم ${post.userId}"),
                        subtitle: Text(formatPostDate(post.createdAt)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child:
                            ExpandableContent(text: post.body ?? "بدون محتوى"),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                likedPosts[post.id] = !isLiked;
                                toggleLike(post.id, isLiked);
                              });
                            },
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : null,
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CommentsScreen(post: post),
                                  ),
                                );
                              },
                              icon: Icon(Icons.message)),
                          IconButton(
                              onPressed: () {}, icon: Icon(Icons.repeat)),
                          IconButton(
                              onPressed: () {
                                String postUrl = "${linkPost}${post.id}";
                                sharePost(post.id);
                              },
                              icon: Icon(Icons.share)),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                savedPosts[post.id] = !isSaved;
                              });
                            },
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved ? Colors.blue : null,
                            ),
                          ),
                        ],
                      ),
                      Divider(color: kblack),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
