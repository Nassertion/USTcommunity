import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/widgets/app_bar.dart';

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
              SizedBox(
                height: 40,
                width: 350,
                child: TextField(
                  inputFormatters: [LengthLimitingTextInputFormatter(20)],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryolor, width: 2)),
                    labelStyle: TextStyle(color: kbluegrey),
                    border: OutlineInputBorder(),
                    focusColor: kgrey,
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Text("محتوى المنشور"),
              Padding(padding: EdgeInsets.only(bottom: 5)),
              SizedBox(
                height: 200,
                width: 350,
                child: TextField(
                  maxLines: 8,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kPrimaryolor, width: 2)),
                    labelStyle: TextStyle(color: kbluegrey),
                    border: OutlineInputBorder(),
                    focusColor: kgrey,
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Text("اضافة مرفق"),
              Padding(padding: EdgeInsets.only(bottom: 5)),
              Row(
                children: [
                  SizedBox(
                    height: 40,
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: kPrimaryolor, width: 2)),
                        labelStyle: TextStyle(color: kbluegrey),
                        border: OutlineInputBorder(),
                        focusColor: kgrey,
                      ),
                    ),
                  ),
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
}
