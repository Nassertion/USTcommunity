import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/widgets/readmore.dart';
import '../data/services/api_server.dart';
import '../widgets/bottom_nav.dart';

//home_screen.dart
class Homescreen extends StatelessWidget {
  Homescreen({super.key});

  Crud crud = Crud();
  void logout(BuildContext context) async {
    bool confirm = false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("تأكيد", style: TextStyle(color: kPrimaryolor)),
          content: Text("هل تريد تسجيل الخروج؟"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("إلغاء", style: TextStyle(color: kPrimaryolor)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
                confirm = true;
              },
              child: Text("تأكيد", style: TextStyle(color: kPrimaryolor)),
            ),
          ],
        );
      },
    );
    if (confirm) {
      await crud.deleteToken();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: Icon(Icons.exit_to_app),
            alignment: Alignment.topLeft,
          )
        ],
        title: Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            "الرئيسية",
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        // child: Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                spacing: 5,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: Image.asset(
                      "assets/images/test.png",
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    "مستخدم 1",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "الوقت ",
                    style: TextStyle(fontSize: 10, color: kgrey),
                  ),
                ],
              ),
              //content
              //change the boldness and size in general
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ExpandableContent(
                  text:
                      "لوريم إيبسوم دولور سيت أميت، كونسكتتور أديبيسيسينغ إليت. سيد دو إيوسمود تيمبور إنسيديدنت يوت ليبوري إيت دولوري ماجنا أليكوا. يوت إينيم آد مينيوم فينيام، كويز نوسترود إكسيرسيتاتيون ألامكو لابوريس نيسي يوت أليكويب إكس إيَا كومودو كونسيكوات. دويس أوتي إيرور دولور إن ريبرهندريت إن وولوتاتي فيليت إيسي كيلوم دولوري إيو فيوجات نولا باريتور. إكسبيتر سينت أوكيبات كويبيدات نون بروفيدنت، سونت إن كولبا كوي أوفيسيا ديسيرونت موليت أنيم إيد إيسيت لابوريوم",
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.favorite_border_rounded)),
                  IconButton(
                      onPressed: () {}, icon: Icon(Icons.message_outlined)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.repeat)),
                  IconButton(
                      onPressed: () {}, icon: Icon(Icons.ios_share_rounded)),
                  IconButton(
                      onPressed: () {}, icon: Icon(Icons.bookmark_add_outlined))
                ],
              ),
              Divider(
                color: kblack,
              ),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/idk');
                  },
                  icon: Icon(Icons.abc))
            ],
          ),
        ),
        // ),
      )),
    );
  }
}
