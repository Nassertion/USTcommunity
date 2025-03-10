import 'package:flutter/material.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/data/services/api_server.dart';
import 'package:graduation_project/widgets/readmore.dart';
import '../widgets/bottom_nav.dart';
import "../data/model/post_model.dart";

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

  @override
  void initState() {
    super.initState();
    fetchPosts(); // تحميل أول 10 منشورات عند فتح الصفحة
    _scrollController.addListener(_onScroll); // مراقبة التمرير لتحميل المزيد
  }

  /// **📌 جلب المنشورات من API**
  Future<void> fetchPosts() async {
    if (isLoading) return; // منع تكرار التحميل

    setState(() => isLoading = true);
    print("📢 جاري تحميل البيانات... الصفحة: $page");

    try {
      var response = await crud.getrequest(
          "http://192.168.100.34:8000/api/v1/posts?page=$page&limit=$limit");

      print("✅ استجابة API: $response");

      if (response != null && response is List) {
        List<Post> newPosts =
            response.map((data) => Post.fromJson(data)).toList();

        if (newPosts.isEmpty) {
          print("⚠️ لا يوجد منشورات جديدة");
          setState(() => isLoading = false);
          return;
        }

        setState(() {
          posts.addAll(newPosts);
          page++; // زيادة رقم الصفحة
        });
      } else {
        print("❌ خطأ: البيانات المستلمة ليست قائمة");
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

                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage("assets/images/test.png"),
                        ),
                        title: Text("المستخدم ${post.userId}"),
                        subtitle: Text(post.createdAt),
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
                              onPressed: () {},
                              icon: Icon(Icons.favorite_border)),
                          IconButton(
                              onPressed: () {}, icon: Icon(Icons.message)),
                          IconButton(
                              onPressed: () {}, icon: Icon(Icons.repeat)),
                          IconButton(onPressed: () {}, icon: Icon(Icons.share)),
                          IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.bookmark_border)),
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
