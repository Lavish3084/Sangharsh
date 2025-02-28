import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:majdoor/providers/language_provider.dart';

class SelectLanguageScreen extends StatelessWidget {
  const SelectLanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We get the provider instance; note: listen is false because we don’t need to rebuild here.
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLocale = languageProvider.locale;

    // List of Indian languages with their corresponding locales.
    final List<Map<String, dynamic>> languages = [
      {
        'name': 'हिंदी',
        'locale': const Locale('hi', 'IN'),
      },
      {
        'name': 'বাংলা',
        'locale': const Locale('bn', 'IN'),
      },
      {
        'name': 'தமிழ்',
        'locale': const Locale('ta', 'IN'),
      },
      {
        'name': 'తెలుగు',
        'locale': const Locale('te', 'IN'),
      },
      {
        'name': 'मराठी',
        'locale': const Locale('mr', 'IN'),
      },
      {
        'name': 'ગુજરાતી',
        'locale': const Locale('gu', 'IN'),
      },
      {
        'name': 'ਪੰਜਾਬੀ',
        'locale': const Locale('pa', 'IN'),
      },
      {
        'name': 'ಕನ್ನಡ',
        'locale': const Locale('kn', 'IN'),
      },
      {
        'name': 'മലയാളം',
        'locale': const Locale('ml', 'IN'),
      },
      {
        'name': 'ଓଡ଼ିଆ',
        'locale': const Locale('or', 'IN'),
      },
      {
        'name': 'অসমীয়া',
        'locale': const Locale('as', 'IN'),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Language',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          final Locale langLocale = lang['locale'];
          final bool isSelected = currentLocale.languageCode == langLocale.languageCode &&
              currentLocale.countryCode == langLocale.countryCode;
          return ListTile(
            title: Text(
              lang['name'],
              style: GoogleFonts.montserrat(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                : null,
            onTap: () {
              // Update the locale via provider
              languageProvider.setLocale(langLocale);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Language set to ${lang['name']}'),
                  duration: const Duration(seconds: 1),
                ),
              );
              // Optionally, pop the screen after selection.
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}