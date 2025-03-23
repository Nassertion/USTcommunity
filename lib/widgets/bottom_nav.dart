import 'package:flutter/material.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/view/notifacation_screen.dart';
import 'package:graduation_project/view/post_creation_screen.dart';
import 'package:graduation_project/view/profile_screen.dart';
import 'package:graduation_project/view/search_screen.dart';
import 'package:graduation_project/view/home_screen.dart';
//bottom_nav_widget.dart

class HomeScreenWithNav extends StatefulWidget {
  const HomeScreenWithNav({super.key});

  @override
  _HomeScreenWithNavState createState() => _HomeScreenWithNavState();
}

class _HomeScreenWithNavState extends State<HomeScreenWithNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Homescreen(),
    Searchscreen(),
    Postcreationscreen(),
    Notifacationscreen(),
    Profilescreen(),
  ];

  // دالة للتبديل بين الصفحات
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // تحديث الصفحة عند التبديل
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex, // تعيين الصفحة التي يجب أن تكون مرئية
        children: _pages, // صفحات التطبيق
      ),
      bottomNavigationBar: BottomNavigationBar(
        type:
            BottomNavigationBarType.fixed, // لعرض جميع العناصر في الشريط السفلي
        backgroundColor: kPrimaryolor,
        selectedItemColor:
            const Color.fromARGB(255, 254, 223, 112), // لون العنصر المحدد
        unselectedItemColor: kBackgroundColor, // لون العناصر غير المحددة
        currentIndex: _selectedIndex, // الصفحة الحالية
        onTap: _onItemTapped, // دالة التبديل بين الصفحات
        items: const [
          BottomNavigationBarItem(label: "الرئيسية", icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: "بحث", icon: Icon(Icons.search)),
          BottomNavigationBarItem(
              label: "جديد", icon: Icon(Icons.add_box_rounded)),
          BottomNavigationBarItem(
              label: "الإشعارات", icon: Icon(Icons.notifications)),
          BottomNavigationBarItem(label: "الحساب", icon: Icon(Icons.person)),
        ],
      ),
    );
  }
}
