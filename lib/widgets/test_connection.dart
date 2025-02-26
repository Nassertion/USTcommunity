import 'package:http/http.dart' as http;

void testConnection() async {
  try {
    var response = await http.get(Uri.parse("http://192.168.100.34:8000/api/v1/test"));
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
  } catch (e) {
    print("🚨 خطأ أثناء الاتصال بالسيرفر: $e");
  }
}
