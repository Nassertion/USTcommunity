import 'package:flutter/material.dart';

AppBar customAppBar(String title) {
  return AppBar(
    title: Text(title),
    leading: BackButton(),
    centerTitle: true,
  );
}
