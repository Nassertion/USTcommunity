import 'package:flutter/material.dart';
import 'package:graduation_project/data/services/api_server.dart';
import 'package:graduation_project/constant/constantColors.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Crud _crud = Crud();
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    String? token = await _crud.getToken();
    if (token != null) {
      Navigator.of(context).pushReplacementNamed('/tabs');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: kPrimaryolor,
        ),
      ),
    );
  }
}
