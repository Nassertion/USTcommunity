import 'dart:convert';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

Crud crud = Crud();

class Crud {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // دالة لحفظ التوكن
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // استرجاع التوكن من SharedPreferences
  }

  // دالة لحفظ التوكن
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token); // حفظ التوكن في SharedPreferences
  }

  // دالة لحذف التوكن
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token'); // حذف التوكن
  }

  // دالة لتبديل حالة الإعجاب
  Future<bool> toggleLike(int postId, bool isLiked) async {
    try {
      final token = await getToken();
      final Map<String, String> headers = {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final String endpoint =
          isLiked ? "${linkUnlike}$postId" : "${linkLike}$postId";
      final response = isLiked
          ? await http.delete(Uri.parse(endpoint), headers: headers)
          : await http.put(Uri.parse(endpoint), headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.body);
        return true;
        
      } else {
        print('فشل في العملية: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('خطأ في الاتصال: $e');
      return false;
    }
  }

  // دالة لجلب البيانات من الخادم
  Future<dynamic> getrequest(String uri) async {
    try {
      final token = await getToken();

      final Map<String, String> headers = {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Accept': 'application/json',
      };

      final response = await http.get(Uri.parse(uri), headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('خطأ ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print("خطأ أثناء الاتصال: $e");
      return null;
    }
  }

  // دالة للإرسال عبر POST
  Future<dynamic> postrequest(String uri, Map<String, dynamic> data) async {
    try {
      final token = await getToken();
      final Map<String, String> headers = {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final response = await http.post(Uri.parse(uri),
          headers: headers, body: jsonEncode(data));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('خطأ ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print("خطأ أثناء الاتصال: $e");
      return null;
    }
  }
}
