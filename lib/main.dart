import 'package:flutter/material.dart';
import 'package:majdoor/screens/account.dart';
import 'package:majdoor/screens/dashboard.dart';
import 'package:majdoor/screens/history.dart';

import 'package:majdoor/screens/otp.dart';
import 'package:majdoor/services/services.dart';
import 'package:majdoor/screens/splashscreen.dart';
import 'package:majdoor/screens/loginscreen.dart';
import 'package:majdoor/screens/signupscreen.dart';
import 'package:majdoor/screens/splashscreen2.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        /*
          '/merchants': (context) => MerchantsScreen(),
          '/history': (context) => HistoryScreen(),
          '/seeAll': (context) => SeeAllScreen(),
          */
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpScreen(),
        '/splash': (context) => SplashScreen(),
        '/otp': (context) => OTPScreen(),
        '/verification': (content) => VerificationSuccessfulScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/account': (context) => AccountScreen(),
        '/bookings': (context) => BookingHistoryScreen(),
        '/services': (context) => ServicesScreen()
      },
      title: 'Sangharsh',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.amber,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
              fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
          headlineMedium: TextStyle(
              fontSize: 20.0, fontStyle: FontStyle.italic, color: Colors.white),
          bodySmall: TextStyle(fontSize: 18.0, color: Colors.white70),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[800],
        ),
      ),
      home: SplashScreen(),
    );
  }
}
