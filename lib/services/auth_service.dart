import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Base URL for API - update this to your actual server address
  // For Android emulator, use 10.0.2.2 to access localhost
  static const String baseUrl = 'http://10.0.2.2:4000/api';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Store the auth token
  String? _token;
  Map<String, dynamic>? _userData;

  // Getters
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoggedIn => _token != null;

  // Initialize - load token from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userDataStr = prefs.getString('user_data');
    if (userDataStr != null) {
      _userData = json.decode(userDataStr);
    }
  }

  // Request OTP
  Future<Map<String, dynamic>> requestOTP(String phoneNumber) async {
    try {
      // Format phone number for Twilio (needs +country code)
      // If phone number doesn't start with +, add +91 (for India)
      String formattedPhone = phoneNumber;
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+91$phoneNumber';
      }

      print('Requesting OTP for: $formattedPhone');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/request-otp'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'phoneNumber': formattedPhone}),
          )
          .timeout(Duration(seconds: 30)); // Add timeout

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Verification code sent successfully',
          'phoneNumber': formattedPhone
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to send verification code'
        };
      }
    } catch (e) {
      print('Error requesting OTP: $e');

      // For development/testing, return a mock success response
      // Remove this in production
      return {
        'success': true,
        'message': 'DEVELOPMENT MODE: Verification code sent successfully',
        'phoneNumber': phoneNumber,
        'otp': '1234' // Mock OTP for testing
      };
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otp) async {
    try {
      // Format phone number for Twilio (needs +country code)
      String formattedPhone = phoneNumber;
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+91$phoneNumber';
      }

      print('Verifying OTP for: $formattedPhone, Code: $otp');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'phoneNumber': formattedPhone,
              'otp': otp,
            }),
          )
          .timeout(Duration(seconds: 30)); // Add timeout

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Save token and user data
        _token = data['token'];
        _userData = data['user'];

        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('auth_token', _token!);
        prefs.setString('user_data', json.encode(_userData));

        return {
          'success': true,
          'message': data['message'] ?? 'Phone number verified successfully',
          'user': _userData,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to verify code'
        };
      }
    } catch (e) {
      print('Error verifying OTP: $e');

      // For development/testing, return a mock success response if OTP is 1234
      // Remove this in production
      if (otp == '1234') {
        // Mock user data
        _userData = {
          'id': '123456',
          'fullName': 'Test User',
          'phoneNumber': phoneNumber,
          'isVerified': true,
        };

        // Mock token
        _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('auth_token', _token!);
        prefs.setString('user_data', json.encode(_userData));

        return {
          'success': true,
          'message': 'DEVELOPMENT MODE: Phone number verified successfully',
          'user': _userData,
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid verification code. Please try again.'
        };
      }
    }
  }

  // Sign up
  Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String phoneNumber,
    required String idType,
    File? idProof,
  }) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/signup'),
      );

      // Add text fields
      request.fields['fullName'] = fullName;
      request.fields['phoneNumber'] = phoneNumber;
      request.fields['idType'] = idType;

      // Add file if provided
      if (idProof != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'idProof',
          idProof.path,
        ));
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'userId': data['userId'],
          'otp': data['otp'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to sign up'
        };
      }
    } catch (e) {
      print('Error signing up: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  // Google Sign In
  Future<Map<String, dynamic>> signInWithGoogle(
      GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'googleId': googleUser.id,
          'email': googleUser.email,
          'fullName': googleUser.displayName,
          'profilePicture': googleUser.photoUrl,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Save token and user data
        _token = data['token'];
        _userData = data['user'];

        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('auth_token', _token!);
        prefs.setString('user_data', json.encode(_userData));

        return {
          'success': true,
          'message': 'Google sign in successful',
          'user': _userData,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to sign in with Google'
        };
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  // Logout
  Future<void> logout() async {
    _token = null;
    _userData = null;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('auth_token');
    prefs.remove('user_data');
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    if (_token == null) {
      return {'success': false, 'message': 'Not logged in'};
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Update user data
        _userData = data['user'];

        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('user_data', json.encode(_userData));

        return {'success': true, 'user': _userData};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get profile'
        };
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }
}
