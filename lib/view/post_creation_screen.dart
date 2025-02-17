import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/widgets/app_bar.dart';
import 'package:graduation_project/widgets/bottom_nav.dart';

class Postcreationscreen extends StatelessWidget {
  const Postcreationscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("انشاء منشور"),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 40, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("عنوان المنشور"),
              Padding(padding: EdgeInsets.only(bottom: 5)),
              InputField(350, 40, 1, 15),
              SizedBox(
                height: 50,
              ),
              Text("محتوى المنشور"),
              Padding(padding: EdgeInsets.only(bottom: 5)),
              InputField(350, 200, 8, 300),
              SizedBox(
                height: 50,
              ),
              Text("اضافة مرفق"),
              Padding(padding: EdgeInsets.only(bottom: 5)),
              Row(
                children: [
                  InputField(300, 40, 1, 300),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "...",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 70,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 100),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryolor,
                    foregroundColor: kBackgroundColor,
                    fixedSize: Size(150, 50),
                  ),
                  onPressed: () {},
                  child: Text(
                    "نشر",
                    style: TextStyle(fontSize: 18, fontFamily: "ElMessiri"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox InputField(double width, double height, int lines, int length) {
    return SizedBox(
      height: height,
      width: width,
      child: TextField(
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
