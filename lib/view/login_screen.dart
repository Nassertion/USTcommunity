import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:graduation_project/data/services/api_server.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

// loginscreen.dart
class LogingScreen extends StatefulWidget {
  LogingScreen({super.key});

  @override
  State<LogingScreen> createState() => _LogingScreenState();
}

class _LogingScreenState extends State<LogingScreen> {
  Crud _crud = Crud();
  bool loading = false;

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> saveUserData(String userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_id', userId);
    prefs.setString('token', token);
    print('تم تخزين البيانات بنجاح');
  }

  Future<void> login() async {
    if (username.text.isEmpty || password.text.isEmpty) {
      return showErrorDialog("الرجاء إدخال اسم المستخدم وكلمة المرور.");
    }

    setState(() => loading = true);

    try {
      var response = await _crud.postrequest(
        linkLogin,
        {"username": username.text, "password": password.text},
      );

      setState(() => loading = false);

      if (response == null) {
        return showErrorDialog("اسم المستخدم أو كلمة المرور غير صحيحة.");
      }

      if (response.containsKey('user') && response.containsKey('token')) {
        await saveUserData(
            response['user']['id'].toString(), response['token']);
        Navigator.of(context).pushReplacementNamed('/tabs');
        print(response['token']);
      } else {
        return showErrorDialog("حدث خطأ غير معروف. الرجاء المحاولة لاحقًا.");
      }
    } catch (e) {
      setState(() => loading = false);
      return showErrorDialog("تعذر الاتصال بالخادم. الرجاء المحاولة لاحقًا.");
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("خطأ"),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: Text("موافق"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("صفحة تسجيل الدخول"),
        centerTitle: true,
      ),
      body: loading == true
          ? Center(child: CircularProgressIndicator(color: kPrimaryolor))
          : Container(
              margin: EdgeInsets.only(bottom: 150),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/uniLogo.svg',
                      height: 120,
                      width: 90,
                    ),
                    inputField(username, "رقم الدخول", Icons.person, false),
                    SizedBox(height: 10),
                    inputField(password, 'كلمة السر', Icons.key, true),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryolor,
                          foregroundColor: kBackgroundColor,
                          fixedSize: Size(200, 50),
                        ),
                        onPressed: () async {
                          await login();
                        },
                        child: Text("دخول",
                            style: TextStyle(
                                fontSize: 18, fontFamily: "ElMessiri")),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  SizedBox inputField(TextEditingController content, String label,
      IconData icon, bool hideContent) {
    return SizedBox(
      width: 350,
      height: 40,
      child: TextField(
        inputFormatters: [LengthLimitingTextInputFormatter(15)],
        controller: content,
        obscureText: hideContent,
        style: TextStyle(color: kblack),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          prefixIcon: Icon(icon),
          labelText: label,
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
