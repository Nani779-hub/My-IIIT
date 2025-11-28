import 'package:flutter/material.dart';

import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // In future, you can initialize services here, e.g.:
  // await FakeDb.init(); or await SharedPreferences.getInstance();
  runApp(const MyIIITApp());
}

class MyIIITApp extends StatelessWidget {
  const MyIIITApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Base theme with professional blue
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1B4ED8), // or 0xFF0052CC from 2nd app
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF3F5FA),
    );

    return MaterialApp(
      title: 'My IIIT',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: base.textTheme.apply(
          bodyColor: const Color(0xFF111827),
          displayColor: const Color(0xFF111827),
        ),
        appBarTheme: base.appBarTheme.copyWith(
          elevation: 2, // from 2nd app (gives subtle shadow)
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111827),
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: base.cardTheme.copyWith(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: base.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: base.colorScheme.primary,
              width: 1.4,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
      },
    );
  }
}

