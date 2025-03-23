import 'package:flutter/material.dart';

AppBar customAppBar(String title, Widget? leading, {List<Widget>? actions}) {
  return AppBar(
    title: Text(title),
    centerTitle: true,
    leading: leading,
    actions: actions,
  );
}
