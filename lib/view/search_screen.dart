import 'package:flutter/material.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/widgets/app_bar.dart';
import 'package:graduation_project/widgets/bottom_nav.dart';

class Searchscreen extends StatelessWidget {
  const Searchscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("البحث"),
      body: Container(
        height: 200,
        width: 350,
        margin: EdgeInsets.only(top: 20, left: 30),
        child: TextField(
          maxLines: 1,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kPrimaryolor, width: 2)),
              labelStyle: TextStyle(color: kbluegrey),
              border: OutlineInputBorder(),
              focusColor: kgrey,
              prefixIcon: Icon(Icons.search)),
        ),
      ),
    );
  }
}
