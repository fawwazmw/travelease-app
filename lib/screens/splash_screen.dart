import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk kDebugMode
import 'package:shared_preferences/shared_preferences.dart'; // Untuk status onboarding
import 'package:flutter_spinkit/flutter_spinkit.dart'; // <-- 1. Impor flutter_spinkit

// Impor service, model, dan konstanta rute Anda
import '../services/auth_service.dart'; // Sesuaikan path jika perlu
import '../models/user.dart';         // Sesuaikan path jika perlu
import '../main.dart';               // Untuk konstanta rute

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService(); // Inisialisasi AuthService

  @override
  void initState() {
    super.initState();
    _initializeAppAndNavigate();
  }

  Future<void> _initializeAppAndNavigate() async {
    // Durasi minimal splash screen ditampilkan
    await Future.delayed(const Duration(seconds: 3)); // Anda bisa sesuaikan durasi ini

    if (!mounted) return; // Pastikan widget masih ada di tree

    // 1. Cek status "Remember Me" dan token
    bool rememberMe = await _authService.getRememberMe();
    String? token = await _authService.getToken();

    if (kDebugMode) {
      print("SplashScreen: Remember Me = $rememberMe, Token = ${token != null ? 'Exists' : 'Null'}");
    }

    if (rememberMe && token != null) {
      // 2. Jika "Remember Me" aktif dan token ada, coba validasi token dengan mengambil profil pengguna
      if (kDebugMode) {
        print("SplashScreen: Attempting to fetch user profile with existing token...");
      }
      final profileResult = await _authService.getUserProfile();

      if (!mounted) return;

      if (profileResult['success'] == true && profileResult['user'] != null) {
        User user = profileResult['user'] as User;
        if (kDebugMode) {
          print("SplashScreen: User profile fetched successfully (${user.name}). Navigating to Home.");
        }
        // Langsung ke HomeScreen dengan data pengguna
        Navigator.pushReplacementNamed(context, homeRoute, arguments: user);
      } else {
        // Gagal fetch profile (token mungkin expired atau tidak valid), arahkan ke Login
        if (kDebugMode) {
          print("SplashScreen: Failed to fetch user profile or token invalid. Message: ${profileResult['message']}. Navigating to Login.");
        }
        // Hapus token dan status "Remember Me" karena sesi tidak valid lagi
        await _authService.deleteToken();
        await _authService.clearRememberMe();
        Navigator.pushReplacementNamed(context, loginRoute);
      }
    } else {
      // 3. Jika tidak ada "Remember Me" atau tidak ada token, cek status onboarding
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // Gunakan kunci yang konsisten untuk status onboarding, misalnya 'onboarding_completed'
      bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

      if (kDebugMode) {
        print("SplashScreen: No Remember Me/Token. Onboarding completed = $onboardingCompleted");
      }

      if (!onboardingCompleted) {
        // Jika onboarding belum selesai, arahkan ke OnboardingScreen
        Navigator.pushReplacementNamed(context, onboardingRoute);
      } else {
        // Jika onboarding sudah selesai, arahkan ke LoginScreen
        Navigator.pushReplacementNamed(context, loginRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('assets/images/logotravelease.png'), // Pastikan path logo benar
              width: 80,
              height: 80,
            ),
            SizedBox(height: 16),
            Text(
              "TravelEase",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 32), // Jarak sebelum animasi loading
            // --- 2. Ganti CircularProgressIndicator dengan SpinKit ---
            SpinKitFadingCircle( // Contoh menggunakan FadingCircle
              color: Color(0xFF446DFF), // Warna animasi
              size: 50.0,               // Ukuran animasi
            ),
          ],
        ),
      ),
    );
  }
}