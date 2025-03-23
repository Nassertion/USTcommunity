import 'package:flutter/material.dart';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/data/model/post_model.dart';
import 'package:graduation_project/data/services/api_server.dart';
import 'package:graduation_project/view/comments_screen.dart';
import 'package:graduation_project/widgets/readmore.dart';
import 'package:graduation_project/widgets/save_widget.dart';
import 'package:graduation_project/widgets/share_widget.dart';
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

  @override
  void initState() {
    super.initState();
    fetchPosts();
    _scrollController.addListener(_onScroll);

    // جلب حالة الحفظ المحفوظة
    getSavedPosts().then((savedSavedPosts) {
      setState(() {
        savedPosts = savedSavedPosts;
      });
    });
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

          // تحديث حالة الإعجاب بناءً على البيانات من الخادم
          for (var post in newPosts) {
            likedPosts[post.id] = post.isLiked ?? false;
          }
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

                  return Card(
                    color: kBackgroundColor,
                    margin: EdgeInsets.all(8), // هوامش حول الكارت
                    elevation: 4, // ظل للكارت
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // زوايا مدورة
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12), // هوامش داخل الكارت
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // رأس البوست (صورة المستخدم واسمه)
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
                          // نص البوست
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ExpandableContent(
                                text: post.body ?? "بدون محتوى"),
                          ),
                          SizedBox(height: 10), // مسافة بين النص والأزرار
                          // أزرار التفاعل (إعجاب، تعليق، مشاركة، حفظ)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  setState(() {
                                    likedPosts[post.id] =
                                        !isLiked; // تحديث الحالة المحلية
                                    post.likes +=
                                        isLiked ? -1 : 1; // تحديث عدد الإعجابات
                                  });

                                  // إرسال الطلب إلى الخادم
                                  final success = await crud.toggleLike(post.id,
                                      isLiked); // استدعاء الدالة من Crud
                                  if (!success) {
                                    // إذا فشل الطلب، قم بإعادة الحالة إلى ما كانت عليه
                                    setState(() {
                                      likedPosts[post.id] = isLiked;
                                      post.likes += isLiked ? 1 : -1;
                                    });
                                  }
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
                                          CommentsScreen(post: post),
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
                                  onPressed: () {}, icon: Icon(Icons.repeat)),
                              IconButton(
                                  onPressed: () {
                                    String postUrl = "${linkPost}${post.id}";
                                    sharePost(post.id);
                                  },
                                  icon: Icon(Icons.share)),
                              IconButton(
                                onPressed: () async {
                                  setState(() {
                                    savedPosts[post.id] =
                                        !isSaved; // تحديث حالة الحفظ
                                  });

                                  // حفظ حالة الحفظ الجديدة
                                  await saveSavedPosts(savedPosts);

                                  print(
                                      "✅ تم ${isSaved ? "إلغاء الحفظ" : "الحفظ"} بنجاح على المنشور: ${post.id}");
                                },
                                icon: Icon(
                                  isSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: isSaved ? Colors.blue : null,
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
