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

  Future<dynamic> toggleLike(int postId, bool isLiked) async {
    try {
      final token = await getToken();
      final Map<String, String> headers = {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Accept': 'application/json',
        'Content-Type': 'application/json', // إضافة Content-Type
      };

      final String endpoint =
          isLiked ? "${linkUnike}$postId" : "${linkLike}/$postId";

      final response = await http.post(
        // استخدام POST بدلاً من DELETE
        Uri.parse(endpoint),
        headers: headers,
      );

      print("📥 استجابة الخادم: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        print('❌ خطأ ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print("❌ خطأ أثناء الإعجاب/إلغاء الإعجاب: $e");
      return null;
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
