import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "https://sangharsh-backend.onrender.com/feedback"; 

  static Future<bool> submitFeedback(String name, String email, String feedback) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "feedback": feedback,
        }),
      );

      print("🔹 Response Code: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      return response.statusCode == 201; // ✅ Returns `true` if success
    } catch (e) {
      print("❌ Exception: $e");
      return false;
    }
  }
}
