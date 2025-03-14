import 'package:flutter/material.dart';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Idk extends StatefulWidget {
  const Idk({super.key});

  @override
  _IdkState createState() => _IdkState();
}

class _IdkState extends State<Idk> {
  final storage = FlutterSecureStorage();
  List<dynamic> posts = []; // قائمة لتخزين البوستات
  bool isLoading = true; // مؤشر التحميل

  @override
  void initState() {
    super.initState();
    fetchPosts(); // جلب البيانات عند بدء الشاشة
  }

  Future<void> fetchPosts() async {
    final token = await storage.read(key: 'token');
    if (token == null) {
      print("No token found. Please log in first.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No token found. Please log in first.")),
      );
      return;
    }

    final url = Uri.parse(linkPost);
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10)); // مهلة زمنية

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Response Data: $data"); // طباعة الاستجابة لفحص الهيكل

        if (data['posts'] != null && data['posts']['data'] is List) {
          setState(() {
            // جلب أول 5 بوستات فقط
            posts = data['posts']['data'].take(5).toList();
            isLoading = false;
          });
        } else {
          print("Invalid data format.");
        }
      } else {
        print(
            "Failed to fetch posts: ${response.statusCode} - ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Failed to fetch posts: ${response.statusCode}. Please try again."),
          ),
        );
      }
    } catch (e) {
      print("Error fetching posts: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Error fetching posts. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Posts"),
        centerTitle: true,
      ),
    );
  }
}
