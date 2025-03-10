import 'dart:convert';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:http/http.dart' as http;

void test1() async {
  final url = Uri.parse(linkPost);

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print(
          'Formatted JSON: ${json.encode(jsonData)}'); // طباعة البيانات بشكل جميل
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching data: $error');
  }
}
