import 'dart:convert';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

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

  Future<bool> toggleBookmark(int postId, bool isBookmarked) async {
    try {
      final token = await getToken();
      final Map<String, String> headers = {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final String endpoint = "${linkServerName}api/v1/bookmark/$postId";
      final response = isBookmarked
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

  Future<void> saveSavedPosts(Map<int, bool> savedPosts) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPostsJson =
        savedPosts.map((key, value) => MapEntry(key.toString(), value));
    await prefs.setString('savedPosts', jsonEncode(savedPostsJson));
  }

  // جلب حالة الحفظ من SharedPreferences
  Future<Map<int, bool>> getSavedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPostsJson = prefs.getString('savedPosts');
    if (savedPostsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(savedPostsJson);
      return decoded
          .map((key, value) => MapEntry(int.parse(key), value as bool));
    }
    return {};
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

  Future<dynamic> uploadUserProfile({
    required String displayName,
    required String bio,
    XFile? imageFile,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return null;

      var uri = Uri.parse("${linkServerName}api/v1/user/profile");

      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['displayName'] = displayName;
      request.fields['bio'] = bio;

      if (imageFile != null) {
        final mimeTypeData = lookupMimeType(imageFile.path)?.split('/');
        var multipartFile = await http.MultipartFile.fromPath(
          'attachment', // تأكد اسم الحقل مع backend
          imageFile.path,
          contentType: mimeTypeData != null
              ? MediaType(mimeTypeData[0], mimeTypeData[1])
              : null,
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print(
            'فشل تحديث الملف الشخصي: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('خطأ في رفع الملف الشخصي: $e');
      return null;
    }
  }
}
