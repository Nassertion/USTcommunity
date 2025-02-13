import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:graduation_project/constant/constantColors.dart';
import 'package:graduation_project/view/homeScreen.dart';
import 'package:graduation_project/view/loginScreen.dart';
import 'package:graduation_project/view/SplashScreen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graduation_project/view/profileScreen.dart';
import 'view/postWidegt.dart';

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
            color: kPrimaryolor,
          ),

          // primaryColor: kPrimaryColor,
          // colorScheme:
          //     ColorScheme.fromSwatch().copyWith(secondary: kSecondaryColor)
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
          "/": (context) => Homescreen(),
          "/splash": (context) => SplashScreen(),
          "/login": (context) => LogingScreen(),
          "/home": (context) => Homescreen(),
          "/idk": (context) => Idk(),
        });
  }
}
