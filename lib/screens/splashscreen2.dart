import 'package:flutter/material.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';

class VerificationSuccessfulScreen extends StatefulWidget {
  const VerificationSuccessfulScreen({Key? key}) : super(key: key);

  @override
  _VerificationSuccessfulScreenState createState() =>
      _VerificationSuccessfulScreenState();
}

class _VerificationSuccessfulScreenState
    extends State<VerificationSuccessfulScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Load the video from assets
    _controller = VideoPlayerController.asset(
        'assets/videos/greentick.mp4') // Use the path of your video here
      ..initialize().then((_) {
        // Ensure the first frame is shown before starting the video
        setState(() {});
        _controller.play(); // Start playing the video automatically
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Timer to navigate to the next screen after 4 seconds
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/dashboard');
    });

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the video if it's initialized
              _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value
                          .aspectRatio, // Maintain the aspect ratio of the video
                      child: VideoPlayer(_controller), // Play the video
                    )
                  : const CircularProgressIndicator(), // Show a loading spinner until the video is ready

              const SizedBox(height: 20),
              const Text(
                'Verification Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'You will be redirected to the Login screen shortly.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
