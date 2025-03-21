import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:graduation_project/view/comments_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/data/model/user_model.dart';
import 'package:graduation_project/data/services/api_server.dart';
import 'package:graduation_project/widgets/readmore.dart';
import '../widgets/bottom_nav.dart';
import "../data/model/post_model.dart";
import 'package:share_plus/share_plus.dart'; // لمشاركة الرابط
import 'package:flutter/services.dart'; // لنسخ الرابط إلى الحافظة

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Crud crud = Crud();
  List<Post> posts = []; // قائمة لتخزين البوستات
  bool isLoading = false; // حالة التحميل
  int page = 1; // رقم الصفحة الحالية
  final int limit = 10; // عدد المنشورات لكل طلب
  final ScrollController _scrollController =
      ScrollController(); // متحكم التمرير

  // حالة لتتبع الإعجاب والحفظ لكل منشور
  Map<int, bool> likedPosts = {};
  Map<int, bool> savedPosts = {};
  Future<void> toggleLike(int postId, bool isLiked) async {
    try {
      // إرسال طلب لتحديث حالة الإعجاب
      final response = await crud.toggleLike(postId, isLiked);

      if (response != null && response['success'] == true) {
        // إذا نجح الطلب، نقوم بتحديث الواجهة
        setState(() {
          likedPosts[postId] = !isLiked;
        });
      } else {
        print("❌ فشل في تحديث حالة الإعجاب");
      }
    } catch (e) {
      print("❌ خطأ أثناء تحديث حالة الإعجاب: $e");
    }
  }

  Future<void> sharePost(int postId) async {
    try {
      // إنشاء رابط المنشور
      final String postUrl = "${linkServerName}api/v1/posts/$postId";

      // مشاركة الرابط
      await Share.share(postUrl);

      print("✅ تم مشاركة الرابط: $postUrl");
    } catch (e) {
      print("❌ خطأ أثناء مشاركة الرابط: $e");
    }
  }

  Future<void> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      print("✅ تم نسخ الرابط إلى الحافظة: $text");
    } catch (e) {
      print("❌ خطأ أثناء نسخ الرابط: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPosts(); // تحميل أول 10 منشورات عند فتح الصفحة
    _scrollController.addListener(_onScroll); // مراقبة التمرير لتحميل المزيد
  }

  String formatPostDate(String dateString) {
    DateTime postDate = DateTime.parse(dateString);
    DateTime now = DateTime.now();

    // التحقق مما إذا كان الفرق أكثر من سنة
    if (now.year != postDate.year) {
      return "${postDate.year}";
    }

    // عرض اليوم + الشهر كتابة
    String formattedDate =
        "${postDate.day} ${DateFormat('MMMM', 'ar').format(postDate)}";
    return formattedDate;
  }

  /// **📌 جلب المنشورات من API**
  Future<void> fetchPosts() async {
    if (isLoading) return; // منع تكرار التحميل

    setState(() => isLoading = true);
    print("📢 جاري تحميل البيانات... الصفحة: $page");

    try {
      var response =
          await crud.getrequest("${linkPost}?page=$page&limit=$limit");

      print("✅ استجابة API الأولية: ${response}");

      if (response != null && response is List) {
        List<Post> newPosts =
            response.map((data) => Post.fromJson(data)).toList();

        if (newPosts.isEmpty) {
          print("⚠️ لا يوجد منشورات جديدة");
        }

        setState(() {
          posts.addAll(newPosts);
          page++; // زيادة رقم الصفحة
        });
      } else {
        print("❌ خطأ: البيانات المستلمة ليست قائمة. الاستجابة: $response");
      }
    } catch (e) {
      print("❌ خطأ أثناء جلب المنشورات: $e");
    }

    setState(() => isLoading = false);
  }

  /// **📌 تحميل المزيد عند الاقتراب من نهاية القائمة**
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      fetchPosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // تنظيف المتحكم عند إغلاق الصفحة
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
                    child: Text("لا توجد منشورات 😕",
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

                  // التحقق من حالة الإعجاب والحفظ لهذا المنشور
                  bool isLiked = likedPosts[post.id] ?? false;
                  bool isSaved = savedPosts[post.id] ?? false;

                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: post.user.imageUrl != null &&
                                  post.user.imageUrl!.isNotEmpty
                              ? NetworkImage(post.user.imageUrl!)
                              : AssetImage("assets/images/test.png")
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
                                String postUrl =
                                    "${linkServerName}api/v1/posts/${post.id}";
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
