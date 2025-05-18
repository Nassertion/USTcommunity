import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:graduation_project/data/model/post_model.dart';
import 'package:graduation_project/data/services/api_server.dart';
import 'package:graduation_project/widgets/app_bar.dart';
import 'package:http/http.dart' as http;

class Searchscreen extends StatefulWidget {
  const Searchscreen({super.key});

  @override
  State<Searchscreen> createState() => _SearchscreenState();
}

class _SearchscreenState extends State<Searchscreen> {
  Crud _crud = Crud();
  TextEditingController searchController = TextEditingController();
  List<Post> searchResults = [];
  List<dynamic> userResults = [];
  bool isLoading = false;
  bool hasSearched = false;

  Future<void> performSearch(String keyword) async {
    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    final token = await _crud.getToken();
    if (token == null) {
      print("توكن غير موجود");
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse('${linkServerName}api/v1/search?text=$keyword');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<Post> posts = (data['posts'] is List)
          ? data['posts'].map<Post>((item) => Post.fromJson(item)).toList()
          : [];

      List<dynamic> users = data['users'] ?? [];

      setState(() {
        searchResults = posts;
        userResults = users;
      });
    } else {
      print("فشل البحث: ${response.statusCode} | ${response.body}");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("البحث", null),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "اكتب كلمة البحث...",
                border: OutlineInputBorder(),
                prefixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    performSearch(searchController.text);
                  },
                ),
              ),
            ),
          ),
          if (isLoading)
            CircularProgressIndicator(color: kPrimaryolor)
          else if (hasSearched &&
              searchResults.isEmpty &&
              userResults.isEmpty &&
              searchController.text.isEmpty)
            Text("لا توجد نتائج", style: TextStyle(fontSize: 16))
          else if (searchResults.isNotEmpty || userResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length + userResults.length,
                itemBuilder: (context, index) {
                  if (index < searchResults.length) {
                    final post = searchResults[index];
                    return Card(
                      color: kBackgroundColor,
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
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
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(post.body ?? "بدون محتوى",
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    );
                  } else {
                    final user = userResults[index - searchResults.length];
                    final profile = user['profile'] ?? {};
                    final isStaff = user['user_type_id'] == 2;

                    return Card(
                      color: Color.fromARGB(255, 223, 243, 255),
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundImage: profile['imageUrl'] != null &&
                                        profile['imageUrl']
                                            .toString()
                                            .isNotEmpty
                                    ? NetworkImage(profile['imageUrl'])
                                    : AssetImage("assets/images/user.png")
                                        as ImageProvider,
                              ),
                              title: Text(
                                user['displayName'] ?? "مستخدم",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(
                                isStaff
                                    ? (profile['role'] ?? "موظف")
                                    : (profile['major'] ?? "طالب"),
                                style: TextStyle(fontSize: 13, color: kgrey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
