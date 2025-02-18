import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:majdoor/screens/account.dart';
import 'package:majdoor/screens/dashboard.dart';
import 'package:majdoor/screens/history.dart';
import 'package:majdoor/screens/otp.dart';
import 'package:majdoor/screens/services.dart';
import 'package:majdoor/screens/splashscreen.dart';
import 'package:majdoor/screens/loginscreen.dart';
import 'package:majdoor/screens/signupscreen.dart';
import 'package:majdoor/screens/splashscreen2.dart';
import 'package:majdoor/screens/settings.dart';
import 'package:provider/provider.dart';
import 'package:majdoor/services/theme_provider.dart';
import 'package:majdoor/services/theme.dart';
import 'package:majdoor/screens/wallet.dart';
import 'package:majdoor/services/wallet_provider.dart';
import 'package:majdoor/screens/bookings.dart';
import 'package:majdoor/services/booking_provider.dart';
import 'package:majdoor/services/language_provider.dart';
import 'package:majdoor/screens/selectlanguage.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/splash',
          routes: {
            '/login': (context) => LoginPage(),
            '/signup': (context) => SignUpScreen(),
            '/splash': (context) => SplashScreen(),
            '/otp': (context) => OTPScreen(),
            '/verification': (context) => VerificationSuccessfulScreen(),
            '/dashboard': (context) => DashboardScreen(),
            '/account': (context) => AccountScreen(),
            '/services': (context) => ServicesScreen(),
            '/settings': (context) => SettingsScreen(),
            '/wallet': (context) => WalletScreen(),
            '/bookings': (context) => BookingsScreen(),
            '/selectLanguage': (context) => const SelectLanguageScreen(),
          },
          title: 'Sangharsh',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,
          // Set locale from the provider
          locale: languageProvider.locale,
          supportedLocales: const [
            Locale('hi', 'IN'),
            Locale('bn', 'IN'),
            Locale('ta', 'IN'),
            Locale('te', 'IN'),
            Locale('mr', 'IN'),
            Locale('gu', 'IN'),
            Locale('pa', 'IN'),
            Locale('kn', 'IN'),
            Locale('ml', 'IN'),
            Locale('or', 'IN'),
            Locale('as', 'IN'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
        );
      },
    );
  }
}