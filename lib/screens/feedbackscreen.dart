import 'package:flutter/material.dart';
import 'package:majdoor/apis/apiservice.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  bool _isLoading = false; // ✅ Loading indicator

  void _submitFeedback() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ All fields are required!")),
      );
      return;
    }

    setState(() => _isLoading = true); // ✅ Show loading

    try {
      bool success = await ApiService.submitFeedback(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _feedbackController.text.trim(),
      );

      setState(() => _isLoading = false); // ✅ Hide loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? "✅ Feedback submitted successfully!"
              : "❌ Failed to submit feedback. Try again."),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        _nameController.clear();
        _emailController.clear();
        _feedbackController.clear();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Feedback")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _feedbackController,
              decoration: InputDecoration(labelText: "Feedback"),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator() // ✅ Show loading
                : ElevatedButton(
                    onPressed: _submitFeedback,
                    child: Text("Submit Feedback"),
                  ),
          ],
        ),
      ),
    );
  }
}
