import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/view/home_screen.dart';
import 'package:graduation_project/view/login_screen.dart';
import 'package:graduation_project/view/activity_screen.dart';
import 'package:graduation_project/view/post_creation_screen.dart';
import 'package:graduation_project/view/search_screen.dart';
import 'package:graduation_project/view/splash_screen.dart';
import 'package:graduation_project/view/profile_screen.dart';
import 'package:graduation_project/widgets/bottom_nav.dart';

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
        initialRoute: "/",
        routes: {
          "/": (context) => SplashScreen(),
          "/splash": (context) => SplashScreen(),
          "/login": (context) => LogingScreen(),
          "/home": (context) => Homescreen(),
          "notification": (context) => NotificationsScreen(),
          "/postcreate": (context) => Postcreationscreen(),
          "/profile": (context) => Profilescreen(),
          "/search": (context) => Searchscreen(),
          "/tabs": (context) => HomeScreenWithNav(),
        });
  }
}
