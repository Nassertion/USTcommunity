import 'package:flutter/material.dart';

AppBar customAppBar(String title, Widget? leading) {
  return AppBar(
    title: Text(title),
    centerTitle: true,
    leading: leading,
  );
}
