import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:graduation_project/widgets/app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Postcreationscreen extends StatefulWidget {
  const Postcreationscreen({super.key});

  @override
  State<Postcreationscreen> createState() => _PostcreationscreenState();
}

class _PostcreationscreenState extends State<Postcreationscreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  File? selectedFile;
  bool isLoading = false;

  Future<void> pickFile() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          selectedFile = File(picked.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم رفض الإذن للوصول إلى الصور")),
      );
    }
  }

  Future<void> uploadPost() async {
    if (bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("يرجى تعبئة المحتوى")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("توكن غير موجود، يرجى تسجيل الدخول مجدداً")),
      );
      return;
    }

    final uri = Uri.parse(linkPost);
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['title'] = titleController.text;
    request.fields['body'] = bodyController.text;

    if (selectedFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'attachment',
        selectedFile!.path,
      ));
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم نشر المنشور بنجاح")),
        );
        setState(() {
          titleController.clear();
          bodyController.clear();
          selectedFile = null;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل نشر المنشور: $responseBody")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء الاتصال: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("إنشاء منشور", null),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 30, right: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("عنوان المنشور"),
                SizedBox(height: 5),
                inputField(titleController, 350, 40, 1, 100),
                SizedBox(height: 30),
                Text("محتوى المنشور"),
                SizedBox(height: 5),
                inputField(bodyController, 350, 200, 8, 500),
                SizedBox(height: 30),
                Text("إضافة مرفق"),
                SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      width: 300,
                      height: 40,
                      decoration: BoxDecoration(
                          border: Border.all(color: kgrey),
                          borderRadius: BorderRadius.circular(5)),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        selectedFile != null
                            ? selectedFile!.path.split("/").last
                            : "لم يتم اختيار ملف",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: pickFile,
                      child: Text("📁", style: TextStyle(fontSize: 24)),
                    )
                  ],
                ),
                SizedBox(height: 40),
                Center(
                  child: isLoading
                      ? CircularProgressIndicator(color: kPrimaryolor)
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryolor,
                            foregroundColor: kBackgroundColor,
                            fixedSize: Size(150, 50),
                          ),
                          onPressed: uploadPost,
                          child: Text("نشر",
                              style: TextStyle(
                                  fontSize: 18, fontFamily: "ElMessiri")),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget inputField(TextEditingController controller, double width,
      double height, int lines, int length) {
    return SizedBox(
      height: height,
      width: width,
      child: TextField(
        controller: controller,
        maxLines: lines,
        inputFormatters: [LengthLimitingTextInputFormatter(length)],
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: kPrimaryolor, width: 2)),
          labelStyle: TextStyle(color: kbluegrey),
          border: OutlineInputBorder(),
          focusColor: kgrey,
        ),
      ),
    );
  }
}
