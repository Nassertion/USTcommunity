import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:graduation_project/constant/constantColors.dart';
import '../data/model/post_model.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;
  const EditPostScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController bodyController;
  File? selectedFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.post.title ?? '');
    bodyController = TextEditingController(text: widget.post.body ?? '');
  }

  Future<void> pickFile() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        selectedFile = File(picked.path);
      });
    }
  }

  Future<void> updatePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("يرجى تسجيل الدخول")));
      return;
    }

    final uri = Uri.parse("${linkServerName}api/v1/posts/${widget.post.id}");
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['title'] = titleController.text.trim();
    request.fields['body'] = bodyController.text.trim();
    request.fields['_method'] = 'PUT'; // ليتعامل Laravel مع التعديل

    if (selectedFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'attachment_url', selectedFile!.path));
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("تم تحديث المنشور بنجاح")));
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("فشل تحديث المنشور: $responseBody")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("خطأ أثناء الاتصال: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("تعديل المنشور"),
          backgroundColor: kPrimaryolor,
          centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: kPrimaryolor))
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("عنوان المنشور"),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: titleController,
                        validator: (val) => val == null || val.trim().isEmpty
                            ? "يرجى إدخال العنوان"
                            : null,
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 20),
                      Text("محتوى المنشور"),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: bodyController,
                        maxLines: 6,
                        validator: (val) => val == null || val.trim().isEmpty
                            ? "يرجى إدخال المحتوى"
                            : null,
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 20),
                      Text("إضافة مرفق"),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 12),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(
                                selectedFile != null
                                    ? selectedFile!.path.split('/').last
                                    : (widget.post.attachmentUrl != null &&
                                            widget
                                                .post.attachmentUrl!.isNotEmpty
                                        ? widget.post.attachmentUrl!
                                            .split('/')
                                            .last
                                        : "لم يتم اختيار ملف"),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                              onPressed: pickFile, child: Text("اختر صورة")),
                        ],
                      ),
                      SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: updatePost,
                          child: Text("تحديث المنشور"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              fixedSize: Size(double.infinity, 50)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
