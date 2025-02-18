import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFF8A4FFF),
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.grey[100],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF8A4FFF)),
      titleTextStyle: GoogleFonts.montserrat(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.roboto(color: Colors.black87),
      bodyMedium: GoogleFonts.roboto(color: Colors.black87),
      titleLarge: GoogleFonts.montserrat(color: Colors.black),
    ),
    iconTheme: IconThemeData(color: Color(0xFF8A4FFF)),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF8A4FFF),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF8A4FFF),
    scaffoldBackgroundColor: Color(0xFF121212),
    cardColor: Color(0xFF1E1E1E),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF8A4FFF)),
      titleTextStyle: GoogleFonts.montserrat(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.roboto(color: Colors.white),
      bodyMedium: GoogleFonts.roboto(color: Colors.white70),
      titleLarge: GoogleFonts.montserrat(color: Colors.white),
    ),
    iconTheme: IconThemeData(color: Color(0xFF8A4FFF)),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Color(0xFF8A4FFF),
    ),
  );
}
