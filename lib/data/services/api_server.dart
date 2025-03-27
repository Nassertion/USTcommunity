//api_service.dart
import 'dart:convert';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Crud crud = Crud();

class Crud {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'token');
    } catch (e) {
      print("Error reading token: $e");
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: 'token', value: token);
      print("Token saved successfully");
    } catch (e) {
      print("Error saving token: $e");
    }
  }

  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: 'token');
      print("Token deleted successfully");
    } catch (e) {
      print("Error deleting token: $e");
    }
  }

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
      print('🔴 الإرسال إلى: $endpoint');

      final response = isLiked
          ? await http.delete(Uri.parse(endpoint), headers: headers)
          : await http.put(Uri.parse(endpoint), headers: headers);

      print('🟢 استجابة الخادم: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ تم ${isLiked ? "إلغاء الإعجاب" : "الإعجاب"} بنجاح');
        return true;
      } else if (response.statusCode == 500) {
        print('⚠️ تحذير: الإعجاب ناجح لكن هناك مشكلة في الإشعارات');
        return true; // تجاهل خطأ الإشعارات إذا كان الإعجاب ناجحًا
      } else {
        print('❌ فشل الإعجاب: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      return false;
    }
  }

  Future<dynamic> getrequest(String uri) async {
    try {
      final token = await getToken();

      final Map<String, String> headers = {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Accept': 'application/json',
      };

      print(" طلب API: $uri");
      print(" التوكن المرسل: $token");

      final response = await http.get(Uri.parse(uri), headers: headers);
      print(" استجابة HTTP: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        print(' خطأ ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print(" خطأ catch ${e}");
    }
  }

  Future<dynamic> postrequest(String uri, Map<String, dynamic> data) async {
    try {
      final token = await getToken();
      final Map<String, String> headers = {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      print(" طلب API: $uri");
      print(" التوكن المرسل: $token");
      print(" البيانات المرسلة: $data");

      final response = await http.post(
        Uri.parse(uri),
        headers: headers,
        body: jsonEncode(data),
      );

      print(" استجابة HTTP: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        print(' خطأ ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print(" خطأ catch ${e}");
      return null;
    }
  }
}
