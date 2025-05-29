import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Akan digunakan nanti

// Sebaiknya impor konstanta rute dari file pusat (main.dart atau app_routes.dart)
// Untuk sementara, kita definisikan yang relevan di sini.
const String onboardingRoute = '/onboarding';
// const String loginRoute = '/login'; // Akan digunakan jika onboarding selesai
// const String homeRoute = '/home';   // Akan digunakan jika sudah login

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Durasi minimal splash screen ditampilkan
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return; // Pastikan widget masih ada di tree

    // Untuk saat ini, kita asumsikan onboarding belum selesai
    // dan langsung arahkan ke onboarding screen.
    // bool onboardingCompleted = false; // Placeholder, nanti diambil dari SharedPreferences

    // if (onboardingCompleted) {
    //   // TODO: Cek status login jika onboarding sudah selesai
    //   // bool isLoggedIn = false; // Placeholder, nanti diambil dari SharedPreferences atau token
    //   // if (isLoggedIn) {
    //   //   Navigator.pushReplacementNamed(context, homeRoute);
    //   // } else {
    //   //   Navigator.pushReplacementNamed(context, loginRoute);
    //   // }
    // } else {
    Navigator.pushReplacementNamed(context, onboardingRoute);
    // }
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
              image: AssetImage('assets/images/logotravelease.png'), // Menggunakan AssetImage
              width: 80,
              height: 80,
              // errorBuilder opsional jika Anda yakin path benar & gambar ada
              // Jika ingin tetap ada fallback:
              // errorBuilder: (context, error, stackTrace) {
              //   return const Icon(
              //     Icons.travel_explore,
              //     size: 80,
              //     color: Colors.grey,
              //   );
              // },
            ),
            SizedBox(height: 16),
            Text(
              "TravelEase",
              style: TextStyle(
                // fontFamily: 'Poppins', // Tidak perlu jika sudah default di ThemeData
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}