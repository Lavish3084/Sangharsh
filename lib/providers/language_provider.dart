import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  // Default locale set to Hindi (you can change this as needed)
  Locale _locale = const Locale('hi', 'IN');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }
}