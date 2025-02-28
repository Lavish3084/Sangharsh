import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:majdoor/screens/auth/signupscreen.dart';
import 'otp.dart';
import '../dashboard.dart';
import 'package:majdoor/helpers/dialogs.dart';
import 'package:majdoor/apis/apis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:majdoor/screens/profiles/account.dart';
import 'package:latlong2/latlong.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();

  _handleGoogleBtnClick() {
    _signInWithGoogle().then((user) {
      Navigator.pop(context);
      if (user != null && user.user != null) {
        var userData = user.user!;

        dev.log('User: ${userData.displayName ?? 'N/A'}, '
            'Email: ${userData.email ?? 'N/A'}, '
            'Phone: ${userData.phoneNumber ?? 'N/A'}, '
            'Photo: ${userData.photoURL ?? 'N/A'}');

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("User Details"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  userData.photoURL != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(userData.photoURL!),
                          radius: 40,
                        )
                      : Icon(Icons.account_circle, size: 80),
                  SizedBox(height: 10),
                  Text("Name: ${userData.displayName ?? 'N/A'}"),
                  Text("Email: ${userData.email ?? 'N/A'}"),
                  Text("Phone: ${userData.phoneNumber ?? 'N/A'}"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountScreen(
                        ),
                      ),
                    );
                  },
                  child: Text("Continue"),
                ),
                TextButton(
                  onPressed: _logout,
                  child: Text("Logout"),
                ),
              ],
            );
          },
        );
      } else {
        dev.log('Error: User or user data is null');
      }
    }).catchError((e) {
      if (mounted) {
        Dialogs.showSnackbar(context, 'Something Went Wrong (Check Internet!)');
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        dev.log('Google Sign-In canceled.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await APIs.auth.signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      dev.log('Error signing in with Google: $e');
      return null;
    }
  }

  void _logout() async {
    await GoogleSignIn().signOut();
    await APIs.auth.signOut();
    dev.log('User logged out');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Logged out successfully"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                "Tasla",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 45,
                      width: 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Get OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OTPScreen()),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 45,
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Sign in with Google',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        onPressed: _handleGoogleBtnClick,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text("Don't have an account? Sign up"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
