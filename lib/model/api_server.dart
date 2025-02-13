//api_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "postModel.dart";

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

  Future<dynamic> getrequest(String uri) async {
    try {
      final token = await getToken();

      final Map<String, String> headers =
          token != null ? {'Authorization': 'Bearer $token'} : {};

      final response = await http.get(Uri.parse(uri), headers: headers);
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        print('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print("Error catch ${e}");
    }
  }

  Future<dynamic> postrequest(String uri, Map<String, dynamic> data) async {
    try {
      final token = await getToken();

      final Map<String, String> headers =
          token != null ? {'Authorization': 'Bearer $token'} : {};

      final response =
          await http.post(Uri.parse(uri), headers: headers, body: data);
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        print('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print("Error catch ${e}");
    }
  }

//   // // وظيفة لاختبار التخزين
//   Future<void> testTokenHandling() async {
//     await saveToken("sample_token");
//     final token = await getToken();
//     print("Retrieved token: $token");
//     await deleteToken();
//   }
}
