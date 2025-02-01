import 'package:flutter/material.dart';

class UiHelper {
  static Widget customimage({required String imagepath}) {
    return Image.asset(
      "assets/photos/$imagepath",
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.person, size: 40, color: Color(0xFF8A4FFF));
      },
    );
  }
}
