import 'package:flutter/material.dart';
import 'package:majdoor/screens/auth/loginscreen.dart';
import 'dart:async';

import 'package:majdoor/screens/auth/otp.dart';
import 'package:majdoor/screens/selectlanguage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Sangharsh', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
