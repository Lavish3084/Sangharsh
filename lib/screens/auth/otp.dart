import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:majdoor/services/auth_service.dart';
import 'package:majdoor/screens/dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const String baseUrl =
    'https://sangharsh-backend.onrender.com';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String? verificationId;

  const OTPScreen({
    Key? key,
    required this.phoneNumber,
    this.verificationId,
  }) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  String _errorMessage = '';
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (!_focusNodes[i].hasFocus) {
          _validateOTP();
        }
      });
    }
  }

  void _validateOTP() {
    String otp = _controllers.map((controller) => controller.text).join();
    setState(() {
      _errorMessage =
          otp.length == 4 ? '' : 'Please enter a complete 4-digit OTP';
    });
  }

  void _verifyOTP() async {
    String otp = _controllers.map((controller) => controller.text).join();

    if (otp.length != 4) {
      setState(() {
        _errorMessage = 'Please enter a complete 4-digit OTP';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });

    try {
      print(
          'Verifying OTP: $otp for phone: ${widget.phoneNumber}'); // Debug log

      final response = await http.post(
        Uri.parse(
            'https://sangharsh-backend.onrender.com/api/labors/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phoneNumber': widget.phoneNumber,
          'otp': otp,
        }),
      );

      print('Verify Response Status: ${response.statusCode}'); // Debug log
      print('Verify Response Body: ${response.body}'); // Debug log

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        // Save the auth token
        await _saveAuthToken(data['token']);

        // Save user data if available
        if (data['user'] != null) {
          await _saveUserData(data['user']);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification successful')),
        );

        // Navigate to dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
          (route) => false,
        );
      } else {
        setState(() {
          _errorMessage = data['error'] ?? 'Invalid OTP';
        });
      }
    } catch (e) {
      print('Error in OTP verification: $e'); // Debug log
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(userData));
  }

  void _resendOTP() async {
    try {
      setState(() {
        _isVerifying = true;
      });

      final response = await http.post(
        Uri.parse(
            'https://sangharsh-backend.onrender.com/api/labors/auth/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phoneNumber': widget.phoneNumber,
        }),
      );

      print('Resend Response: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP resent successfully')),
        );
      } else {
        throw Exception('Failed to resend OTP');
      }
    } catch (e) {
      print('Error resending OTP: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend OTP')),
      );
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  Widget _otpDigitField(int index) {
    return Container(
      width: 40,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: 1,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 9, 11, 11), width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1 && index < 3) {
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 20, 21, 22),
              Color.fromARGB(255, 22, 21, 22),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'Verification',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Enter the 4-digit code sent to ${widget.phoneNumber}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) => _otpDigitField(index)),
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              const SizedBox(height: 20),
              _isVerifying
                  ? CircularProgressIndicator(color: Colors.white)
                  : ElevatedButton(
                      onPressed: _verifyOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 43, vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Verify',
                        style: TextStyle(
                          color: Color(0xFF4568DC),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _resendOTP,
                child: Text(
                  'Resend OTP',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Powered by Coddunity',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes to avoid memory leaks
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
