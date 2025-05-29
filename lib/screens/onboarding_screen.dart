import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// Impor atau definisikan konstanta rute yang diperlukan
const String loginRoute = '/login'; // Pastikan ini konsisten dengan main.dart

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    // TODO: 1. Simpan status bahwa onboarding telah selesai menggunakan SharedPreferences
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('onboardingCompleted', true);
    // print("Status onboarding disimpan!");

    // 2. Navigasi ke halaman Login
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, loginRoute); // Mengarah ke LoginScreen
    }
    // print("Onboarding selesai. Navigasi ke Login akan diimplementasikan nanti."); // Komentari atau hapus ini
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF838383),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 60),
              const Text(
                'Selamat Datang di TravelEase!',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Temukan destinasi impianmu dan rencanakan perjalanan tak terlupakan.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 372, // Sesuai permintaan
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _completeOnboarding(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF446DFF),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12, // Disesuaikan agar teks tidak terlalu mepet
                        horizontal: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}