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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.camera_alt_rounded, color: Colors.white),
              title: const Text("Take a Photo",
                  style: TextStyle(color: Colors.white)),
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
              leading:
                  const Icon(Icons.photo_library_rounded, color: Colors.white),
              title: const Text("Choose from Gallery",
                  style: TextStyle(color: Colors.white)),
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
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 30.0),
                const Text(
                  "SIGN UP",
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  "Create your account to get started!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0, color: Colors.black54),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6.0, offset: Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          prefixIcon: Icon(icon, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.black, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
        ),
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedId, // Must be null initially to show hint
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: "Select ID Type", // Static label, always visible
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: Icon(Icons.badge, color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      dropdownColor: Colors.white, // Ensures dropdown background is white
      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
      hint:
          Text("Select", style: TextStyle(color: Colors.black)), // Correct hint
      items: [
        DropdownMenuItem(
            value: "PAN",
            child: Text("PAN", style: TextStyle(color: Colors.black))),
        DropdownMenuItem(
            value: "Aadhar",
            child: Text("Aadhar", style: TextStyle(color: Colors.black))),
        DropdownMenuItem(
            value: "Voter ID",
            child: Text("Voter ID", style: TextStyle(color: Colors.black))),
        DropdownMenuItem(
            value: "Driving License",
            child:
                Text("Driving License", style: TextStyle(color: Colors.black))),
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
      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
      onPressed: () {
        if (selectedId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text("Please select an ID type before uploading proof.")),
          );
        } else {
          _showImagePickerOptions();
        }
      },
      child: const Text("UPLOAD PROOF", style: TextStyle(color: Colors.white)),
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
        const Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.black),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage())),
          child: const Text("Login",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
