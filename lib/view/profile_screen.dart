import 'package:flutter/material.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/widgets/app_bar.dart';
import 'package:graduation_project/widgets/bottom_nav.dart';
import 'package:graduation_project/widgets/test.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("الملف الشخصي "),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          "الاسم الظاهر",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "اسم المستخدم",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 120, vertical: 10),
                    child: Text(
                      "تعديل الملف",
                      style: TextStyle(color: kPrimaryolor),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 60,
                  child: TabBar(
                      labelColor: kPrimaryolor,
                      indicatorColor: kPrimaryolor,
                      controller: _tabController,
                      tabs: [
                        Tab(
                          text: "المنشورات",
                        ),
                        Tab(
                          text: "المعاد نشره",
                        ),
                        Tab(
                          text: "المحفوظه",
                        )
                      ]),
                ),
              ],
            ),
          ),
          // إضافة TabBarView لعرض المحتوى المتوافق مع التبويبات
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Center(
                    child:
                        Text("محتوى المنشورات")), // محتوى علامة التبويب الأولى
                Center(
                    child: Text(
                        "محتوى المعاد نشره")), // محتوى علامة التبويب الثانية
                Center(
                    child:
                        Text("محتوى المحفوظة")), // محتوى علامة التبويب الثالثة
              ],
            ),
          ),
          TextButton(
              onPressed: () {
                test1();
              },
              child: Icon(Icons.import_contacts))
        ],
      ),
    );
  }
}
