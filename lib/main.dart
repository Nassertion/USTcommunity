import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/view/home_screen.dart';
import 'package:graduation_project/view/login_screen.dart';
import 'package:graduation_project/view/notifacation_screen.dart';
import 'package:graduation_project/view/post_creation_screen.dart';
import 'package:graduation_project/view/search_screen.dart';
import 'package:graduation_project/view/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduation_project/view/profile_screen.dart';
import 'widgets/post_widegt.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UST Community',
        theme: ThemeData(
          fontFamily: "ElMessiri",
          scaffoldBackgroundColor: kBackgroundColor,
          appBarTheme: AppBarTheme(
            backgroundColor: kPrimaryolor,
            foregroundColor: kBackgroundColor,
          ),
        ),
        localizationsDelegates: [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [Locale("ar", "AE")],
        locale: Locale("ar", "AE"),
        initialRoute: '/',
        routes: {
          "/": (context) => Notifacationscreen(),
          "/splash": (context) => SplashScreen(),
          "/login": (context) => LogingScreen(),
          "/home": (context) => Homescreen(),
          "/idk": (context) => Idk(),
          "notifacation": (context) => Notifacationscreen(),
          "/postcreate": (context) => Postcreationscreen(),
          "/profile": (context) => Profilescreen(),
          "/search": (context) => Searchscreen(),
        });
  }
}
