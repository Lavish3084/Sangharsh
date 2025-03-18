import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthHelper {
  static Future<void> logout(BuildContext context) async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      dev.log('User logged out');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logged out successfully")),
      );

      // Navigate back to login screen or another page
      Navigator.pushReplacementNamed(context, "/login"); // Ensure route exists
    } catch (e) {
      dev.log('Error during logout: $e');
    }
  }
}
