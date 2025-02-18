import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:majdoor/screens/loginscreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? selectedId;
  XFile? proofImage;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _showImagePickerOptions() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_alt_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                "Take a Photo",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image =
                    await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    proofImage = image;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Proof uploaded successfully!")),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                "Choose from Gallery",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    proofImage = image;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Proof uploaded successfully!")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google Sign-In canceled.")),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signed in as ${googleUser.displayName}")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 30.0),
                Text(
                  "SIGN UP",
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  "Create your account to get started!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 30.0),

                // Form Fields
                Form(
                  child: Column(
                    children: [
                      _buildTextField("Full Name", Icons.person),
                      const SizedBox(height: 20.0),
                      _buildTextField("Phone Number", Icons.phone),
                      const SizedBox(height: 20.0),

                      // Dropdown for ID selection
                      _buildDropdown(),

                      const SizedBox(height: 20.0),

                      // Upload proof button
                      _buildUploadButton(),

                      const SizedBox(height: 20.0),

                      // Display proof image if uploaded
                      if (proofImage != null) _buildProofImage(),

                      const SizedBox(height: 20.0),

                      // Sign Up Button
                      _buildSignUpButton(),

                      const SizedBox(height: 30.0),

                      // Footer
                      _buildFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).cardColor,
          labelText: label,
          labelStyle:
              TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
        ),
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedId,
      dropdownColor: Theme.of(context).cardColor,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardColor,
        labelText: "Select ID Type",
        labelStyle:
            TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        prefixIcon: Icon(Icons.badge, color: Theme.of(context).iconTheme.color),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      items: [
        DropdownMenuItem(
          value: "PAN",
          child: Text(
            "PAN",
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
        DropdownMenuItem(
          value: "Aadhar",
          child: Text(
            "Aadhar",
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
        DropdownMenuItem(
          value: "Voter ID",
          child: Text(
            "Voter ID",
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
        DropdownMenuItem(
          value: "Driving License",
          child: Text(
            "Driving License",
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          selectedId = value;
        });
      },
    );
  }

  Widget _buildUploadButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      onPressed: () {
        if (selectedId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Please select an ID type before uploading proof."),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else {
          _showImagePickerOptions();
        }
      },
      child: Text("UPLOAD PROOF"),
    );
  }

  Widget _buildProofImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Image.file(File(proofImage!.path),
          height: 150.0, width: 150.0, fit: BoxFit.cover),
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
      onPressed: () {},
      child: const Text("SIGN UP", style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          ),
          child: Text(
            "Login",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
