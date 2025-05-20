import 'package:flutter/material.dart';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/data/services/api_server.dart'; // دالة postrequest

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  Crud crud = Crud();

  Future<void> _sendReport() async {
    final prefs = await SharedPreferences.getInstance();
    int? postId = prefs.getInt('postIdForReport');

    if (postId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لم يتم تحديد المنشور المبلغ عنه')),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى كتابة وصف البلاغ')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // نرسل البلاغ مع الوصف
    final response = await crud.postrequest(
      "${linkServerName}api/v1/report/$postId",
      {'body': _descriptionController.text.trim()},
    );

    setState(() {
      _isLoading = false;
    });

    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إرسال البلاغ، حاول مرة أخرى')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إرسال البلاغ بنجاح')),
      );
      Navigator.of(context).pop(); // نرجع للصفحة السابقة
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("صفحة البلاغات"),
        centerTitle: true,
        backgroundColor: kPrimaryolor, // غيّر حسب ألوانك
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "اكتب وصف البلاغ",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _sendReport,
                    child: Text("إرسال البلاغ"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
