import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:graduation_project/data/model/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/view/comments_screen.dart'; // شاشة تفاصيل البوست

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;
  String errorMessage = '';

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        errorMessage = 'يرجى تسجيل الدخول أولاً';
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('${linkServerName}api/v1/activity'); // عدل حسب سيرفرك

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          notifications = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'فشل تحميل الإشعارات: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'حدث خطأ: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Widget _buildNotificationItem(dynamic item) {
    final data = item['data'];
    final String type = data['type'];
    final String username = data['username'];
    final String postId = data['post_id'];

    String message = '';
    if (type == 'like') {
      message = 'وضع إعجاب على منشورك';
    } else if (type == 'comment') {
      message = 'علق على منشورك';
    } else if (type == 'follow') {
      message = 'بدأ متابعة حسابك';
    } else {
      message = 'حدث جديد';
    }

    return ListTile(
      title: Text(username),
      subtitle: Text(message),
      trailing: Text(
        item['created_at'] != null
            ? DateTime.tryParse(item['created_at'])
                    ?.toLocal()
                    .toString()
                    .split('.')[0] ??
                ''
            : '',
        style: TextStyle(fontSize: 10, color: Colors.grey),
      ),
      onTap: () {
        if (postId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CommentsScreen(postId: int.tryParse(postId) ?? 0),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor, // خلفية حسب طلبك
      appBar: AppBar(
        title: Text('الإشعارات'),
        centerTitle: true,
        backgroundColor: kPrimaryolor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: kPrimaryolor))
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : notifications.isEmpty
                  ? Center(child: Text('لا توجد إشعارات'))
                  : RefreshIndicator(
                      onRefresh: fetchNotifications,
                      child: ListView.separated(
                        padding: EdgeInsets.all(10),
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          return _buildNotificationItem(notifications[index]);
                        },
                      ),
                    ),
    );
  }
}
