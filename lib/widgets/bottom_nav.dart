// import 'package:flutter/material.dart';
// import 'package:graduation_project/constant/constantColors.dart';

// class Bottomnav extends StatelessWidget {
//   const Bottomnav({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return (BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       backgroundColor: kPrimaryolor,
//       selectedItemColor: const Color.fromARGB(255, 254, 223, 112),
//       unselectedItemColor: kBackgroundColor,
//       currentIndex: 0,
//       items: [
//         BottomNavigationBarItem(label: "الرئيسية", icon: Icon(Icons.home)),
//         BottomNavigationBarItem(label: "بحث", icon: Icon(Icons.search)),
//         BottomNavigationBarItem(
//             label: "جديد", icon: Icon(Icons.add_box_rounded)),
//         BottomNavigationBarItem(
//             icon: Icon(Icons.notifications), label: "الاشعارات"),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person),
//           label: 'الحساب',
//         ),
//       ],
//     ));
//   }
// }

import 'package:flutter/material.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/view/home_screen.dart';
import 'package:graduation_project/view/notifacation_screen.dart';
import 'package:graduation_project/view/post_creation_screen.dart';
import 'package:graduation_project/view/profile_screen.dart';
import 'package:graduation_project/view/search_screen.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<Bottomnav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Homescreen(),
    Searchscreen(),
    Postcreationscreen(),
    Notifacationscreen(),
    Profilescreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: kPrimaryolor,
        selectedItemColor: const Color.fromARGB(255, 254, 223, 112),
        unselectedItemColor: kBackgroundColor,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
