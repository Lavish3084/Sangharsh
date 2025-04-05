import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:majdoor/screens/auth/signupscreen.dart';
import 'package:majdoor/services/auth_service.dart';
import 'otp.dart';
import '../dashboard.dart';
import 'package:majdoor/helpers/dialogs.dart';
import 'package:majdoor/apis/apis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:majdoor/screens/profiles/account.dart';
import 'package:latlong2/latlong.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl =
    'https://sangharsh-backend.onrender.com';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  _handleGoogleBtnClick() async {
    try {
      setState(() => _isLoading = true);
      print('Starting Google Sign In process...'); // Debug log

      final UserCredential? userCredential = await _signInWithGoogle();

      if (userCredential?.user != null) {
        print('Successfully signed in: ${userCredential?.user?.email}');

        // Send Google user info to backend for registration/login
        final response = await http.post(
          Uri.parse('$baseUrl/api/labors/auth/google'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'googleId': userCredential!.user!.uid,
            'email': userCredential.user!.email,
            'fullName': userCredential.user!.displayName,
            'profilePicture': userCredential.user!.photoURL,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          // Store user info in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userEmail', data['user']['email']);
          await prefs.setString('userName', data['user']['fullName']);
          await prefs.setString('token', data['token']); // Store JWT token if needed

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
            );
          }
        } else {
          print('Backend error: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign in failed. Please try again')),
          );
        }
      } else {
        print('Sign in failed: No user credential returned');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign in failed. Please try again')),
          );
        }
      }
    } catch (e) {
      print('Error during Google Sign In: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      print('Checking internet connection...'); // Debug log
      await InternetAddress.lookup('google.com');

      print('Initializing Google Sign In...'); // Debug log
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );

      print('Requesting Google account selection...'); // Debug log
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('User canceled Google Sign In');
        return null;
      }

      print('Getting Google auth details...'); // Debug log
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('Creating Firebase credential...'); // Debug log
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in to Firebase...'); // Debug log
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Detailed error in _signInWithGoogle: $e');
      rethrow; // Rethrow to handle in _handleGoogleBtnClick
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

  void _requestOTP() async {
    String phoneNumber = _phoneController.text.trim();
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (phoneNumber.isEmpty || phoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final formattedPhone = '+91$phoneNumber';
      print('Requesting OTP for: $formattedPhone');

      final response = await http.post(
        Uri.parse(
            'https://sangharsh-backend.onrender.com/api/labors/auth/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phoneNumber': formattedPhone,
        }),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent successfully')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              phoneNumber: formattedPhone,
            ),
          ),
        );
      } else {
        throw Exception(data['error'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      print('Error sending OTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Add this method to verify Firebase initialization
  void _checkFirebaseInitialization() {
    try {
      final auth = FirebaseAuth.instance;
      print('Firebase Auth is initialized: ${auth != null}');
    } catch (e) {
      print('Firebase Auth initialization error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkFirebaseInitialization(); // Add this to check Firebase setup
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
              child: Image.asset(
                'assets/images/logo_white.png',
                width: 550,
                height: 300,
                fit: BoxFit.contain,
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
                        hintText: "Enter your 10-digit phone number",
                        prefixText: "+91 ",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
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
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Get OTP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                        onPressed: _isLoading ? null : _requestOTP,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: SignInButton(
                          Buttons.google,
                          text: "Sign in with Google",
                          onPressed: _handleGoogleBtnClick,
                        )),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text(
                        "Don't have an account? Sign up",
                        style: TextStyle(color: Colors.black),
                      ),
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
