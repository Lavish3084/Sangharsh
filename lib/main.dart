import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:majdoor/screens/profiles/account.dart';
import 'package:majdoor/screens/dashboard.dart';
import 'package:majdoor/screens/history.dart';
import 'package:majdoor/screens/auth/otp.dart';
import 'package:majdoor/screens/services.dart';
import 'package:majdoor/screens/splashes/splashscreen.dart';
import 'package:majdoor/screens/auth/loginscreen.dart';
import 'package:majdoor/screens/auth/signupscreen.dart';
import 'package:majdoor/screens/profiles/userprofile.dart';
import 'package:majdoor/screens/splashes/splashscreen2.dart';
import 'package:majdoor/screens/settings.dart';
import 'package:provider/provider.dart';
import 'package:majdoor/providers/theme_provider.dart';
import 'package:majdoor/services/theme.dart';
import 'package:majdoor/screens/wallet.dart';
import 'package:majdoor/providers/wallet_provider.dart';
import 'package:majdoor/screens/bookings.dart';
import 'package:majdoor/providers/booking_provider.dart';
import 'package:majdoor/providers/language_provider.dart';
import 'package:majdoor/screens/selectlanguage.dart';
import 'package:majdoor/screens/feedbackscreen.dart';
import 'screens/chat/chatscreen.dart';
import 'package:majdoor/screens/profiles/labourprofile.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

late Size mq;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Await Firebase initialization before running the app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set immersive sticky mode after Firebase is initialized
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize plugins that need early initialization
  var _ = Razorpay();

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
            '/verification': (context) => VerificationSuccessfulScreen(),
            '/dashboard': (context) => DashboardScreen(),
            '/services': (context) => ServicesScreen(),
            '/settings': (context) => SettingsScreen(),
            '/wallet': (context) => WalletScreen(),
            '/bookings': (context) => BookingsScreen(),
            '/selectLanguage': (context) => const SelectLanguageScreen(),
            '/feedback': (context) => FeedbackScreen(),
            '/testchat': (context) => const ChatScreen(
                  laborerName: "Alex Johnson",
                  laborerJob: "Moving Specialist",
                  laborerImageUrl: "https://picsum.photos/100/100",
                  pricePerDay: 1000,
                ),
          },
          title: 'Sangharsh',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,
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
