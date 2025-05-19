import 'package:flutter/material.dart';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/data/services/api_server.dart';
import 'package:graduation_project/view/edit_profile.dart';
import 'package:graduation_project/widgets/app_bar.dart';
import 'package:graduation_project/data/model/profile_model.dart';
import 'package:graduation_project/data/model/post_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Profile? profile; // تغيرنا من late Profile إلى Profile?

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchProfileData(); // جلب بيانات الـ Profile
  }

  // دالة لجلب بيانات الـ Profile
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

  // دالة لجلب منشورات المستخدم
  Future<void> fetchUserPosts() async {
    setState(() => isLoadingPosts = true);

    try {
      final response = await crud
          .getrequest("${linkServerName}api/v1/posts/${profile?.userId}");

      if (response != null && response is List) {
        setState(() {
          posts = response.map((postData) => Post.fromJson(postData)).toList();
        });
      }
    } catch (e) {
      print("خطأ في جلب المنشورات: $e");
    } finally {
      setState(() => isLoadingPosts = false);
    }
  }

  // دالة لجلب المتابعين
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

  // دالة لجلب المتابعين لديك
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
                      // تم تعديل الملف، حدث البيانات من جديد
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
                    // عرض عدد المتابعين
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
                    // عرض عدد المتابعين لديك
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
                      Tab(text: "المحفوظه"),
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
                // عرض المنشورات الخاصة بالمستخدم
                isLoadingPosts
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              title: Text(posts[index].title ?? 'لا عنوان'),
                              subtitle: Text(posts[index].body ?? 'لا محتوى'),
                              trailing: IconButton(
                                icon: Icon(posts[index].isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border),
                                onPressed: () {
                                  // إجراء الإعجاب
                                },
                              ),
                            ),
                          );
                        },
                      ),
                Center(child: Text("محتوى المحفوظة")),
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
