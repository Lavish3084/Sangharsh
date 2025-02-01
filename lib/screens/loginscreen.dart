import 'package:flutter/material.dart';
import 'package:majdoor/screens/signupscreen.dart';
import 'otp.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Top black section extended
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                "Tasla",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  fontFamily:
                      'Roboto', // Replace with a custom font if desired.
                ),
              ),
            ),
          ),
          // Bottom white section
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
                    // Styled phone number text field
                    TextField(
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black), // Black text color when typed
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                        filled:
                            true, // This ensures the background is filled with color
                        fillColor: Colors.white, // White background
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.black, width: 2), // Black border
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.black,
                              width: 1), // Black border when enabled
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.black,
                              width: 2), // Black border when focused
                        ),
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.black, // Black label text
                        ),
                        hintText: 'Enter your phone number',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: const Color.fromARGB(
                              255, 61, 61, 61), // Black hint text
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    // "Get OTP" button styled and resized
                    SizedBox(
                      height: 45,
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
                    SizedBox(height: 15),
                    // Forgot Password link
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SignUpScreen()), // Replace with ForgotPasswordPage if available
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                    ),
                    SizedBox(height: 15),
                    // Create Account Button
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SignUpScreen()), // Replace with ForgotPasswordPage if available
                        );
                      },
                      child: Text(
                        'Create Account',
                        style: TextStyle(fontSize: 14, color: Colors.blue),
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
