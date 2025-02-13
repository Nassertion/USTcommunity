import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduation_project/constant/ConstantLinks.dart';
import 'package:graduation_project/model/api_server.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  Future<void> login() async {
    if (username.text.isEmpty || password.text.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("خطأ"),
            content: Text("الرجاء إدخال اسم المستخدم وكلمة المرور."),
            actions: [
              CupertinoDialogAction(
                child: Text("موافق"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      print("pls input the username and password");
      return;
    }
    loading = true;
    setState(() {});
    try {
      var response = await _crud.postrequest(
        linkLogin,
        {"username": username.text, "password": password.text},
      );
      setState(() {
        loading = false;
      });

      if (response == null) {
        print("the inputs are wrong");
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text("خطأ"),
              content: Text("اسم المستخدم أو كلمة المرور غير صحيحة."),
              actions: [
                CupertinoDialogAction(
                  child: Text("موافق"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }
      if (response.containsKey('user') && response.containsKey('token')) {
        await Future.delayed(Duration(seconds: 2));
        String token = response['token'];
        await _crud.saveToken(token);
        Navigator.of(context).pushReplacementNamed('/homet');
      } else {
        print("حدث خطأ غير معروف: $response");
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text("خطأ"),
              content: Text("حدث خطأ غير معروف. الرجاء المحاولة لاحقًا."),
              actions: [
                CupertinoDialogAction(
                  child: Text("موافق"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("Error: $e");
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("خطأ"),
            content: Text("تعذر الاتصال بالخادم. الرجاء المحاولة لاحقًا."),
            actions: [
              CupertinoDialogAction(
                child: Text("موافق"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "صفحة تسجيل الدخول",
          style: TextStyle(
              color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: loading == true
          ? Center(
              child: CircularProgressIndicator(
                color: kPrimaryolor,
              ),
            )
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
                    SizedBox(
                      height: 10,
                    ),
                    inputField(password, 'كلمة السر ', Icons.key, true),
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
                        child: Text(
                          "دخول",
                          style:
                              TextStyle(fontSize: 18, fontFamily: "ElMessiri"),
                        ),
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
