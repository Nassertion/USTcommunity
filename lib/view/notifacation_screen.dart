import 'package:flutter/material.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/widgets/app_bar.dart';
import 'package:graduation_project/widgets/bottom_nav.dart';

class Notifacationscreen extends StatelessWidget {
  const Notifacationscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("الاشعارات"),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: kBackgroundColor,
                  backgroundImage: AssetImage("assets/images/Logo.png")),
              title: Text("Username 1"),
              subtitle: Text(" وضع اعجاب للمنشور هذا"),
            ),
            SizedBox(
              height: 20,
            ),
            ListTile(
              leading: CircleAvatar(
                  backgroundImage: AssetImage("assets/images/test.png")),
              title: Text("Username 1"),
              subtitle: Text(" وضع اعجاب للمنشور هذا"),
            ),
            SizedBox(
              height: 20,
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage("assets/images/test.png"),
              ),
              title: Text("Username 1"),
              subtitle: Text(" وضع اعجاب للمنشور هذا"),
            ),
            SizedBox(
              height: 20,
            ),
            ListTile(
              leading: CircleAvatar(
                  backgroundImage: AssetImage("assets/images/test.png")),
              title: Text("Username 1"),
              subtitle: Text(" وضع اعجاب للمنشور هذا"),
            ),
            SizedBox(
              height: 20,
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage("assets/images/test.png"),
              ),
              title: Text("Username 1"),
              subtitle: Text(" وضع اعجاب للمنشور هذا"),
            ),
          ],
        ),
      ),
    );
  }
}
