import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveSavedPosts(Map<int, bool> savedPosts) async {
  final prefs = await SharedPreferences.getInstance();
  final savedPostsJson =
      savedPosts.map((key, value) => MapEntry(key.toString(), value));
  await prefs.setString('savedPosts', jsonEncode(savedPostsJson));
}

Future<Map<int, bool>> getSavedPosts() async {
  final prefs = await SharedPreferences.getInstance();
  final savedPostsJson = prefs.getString('savedPosts');
  if (savedPostsJson != null) {
    final Map<String, dynamic> decoded = jsonDecode(savedPostsJson);
    return decoded.map((key, value) => MapEntry(int.parse(key), value as bool));
  }
  return {};
}
