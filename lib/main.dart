import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/category_destination_list_screen.dart';

import 'models/category.dart';

// Definisikan konstanta rute
const String splashRoute = '/';
const String onboardingRoute = '/onboarding';
const String loginRoute = '/login';
const String registerRoute = '/register';
const String forgotPasswordRoute = '/forgot-password';
const String homeRoute = '/home';
const String categoryListRoute = '/category-destinations';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelEase',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF446DFF)), // Menggunakan warna biru Anda
        useMaterial3: true,
        // Kustomisasi tambahan untuk tema agar konsisten
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF446DFF), // Warna teks untuk TextButton
                textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)
            )
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF446DFF),
              foregroundColor: Colors.white, // Warna teks pada ElevatedButton
              textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              elevation: 3,
            )
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey.shade300),
              textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            )
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(fontSize: 12.0, color: Color(0xFFC5C5C5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFC5C5C5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFC5C5C5)), // Sesuai permintaan Anda
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        ),
      ),
      initialRoute: splashRoute, // Tetap splashRoute agar alur terjaga
      routes: {
        splashRoute: (context) => const SplashScreen(),
        onboardingRoute: (context) => const OnboardingScreen(),
        loginRoute: (context) => const LoginScreen(),
        registerRoute: (context) => const RegisterScreen(),
        forgotPasswordRoute: (context) => const ForgotPasswordScreen(),
        homeRoute: (context) => const HomeScreen(), // <-- 3. Tambahkan rute home
      },
      onGenerateRoute: (settings) {
        if (settings.name == categoryListRoute) {
          final args = settings.arguments as AppCategory; // Casting ke Category dari model
          return MaterialPageRoute(
            builder: (context) {
              return CategoryDestinationListScreen(category: args);
            },
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}