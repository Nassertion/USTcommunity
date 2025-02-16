import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/app_bar.dart';

class Searchscreen extends StatelessWidget {
  const Searchscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("الاشعارات"),
    );
  }
}
