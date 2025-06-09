import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../main.dart';
import '../utils/toast_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _authService.login(
          email: _emailController.text,
          password: _passwordController.text,
          rememberMe: _rememberMe,
        );

        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        if (result['success'] == true && result['user'] != null) { // <-- 2. Pastikan 'user' ada
          ToastUtils.showSuccessToast(result['message'] ?? 'Login successful!');
          User loggedInUser = result['user'] as User; // Ambil objek User
          // Navigasi ke HomeScreen setelah login berhasil DAN KIRIM USER SEBAGAI ARGUMEN
          Navigator.pushReplacementNamed(context, homeRoute, arguments: loggedInUser); // <-- 3. Kirim argumen
        } else {
          String errorMessage = result['message'] ?? 'Login failed.';
          if (result['email_not_verified'] == true) {
            errorMessage = result['message'] ?? 'Please verify your email first.';
          } else if (result['errors'] != null && result['errors'] is Map) {
            Map<String, dynamic> errors = result['errors'] as Map<String, dynamic>;
            if (errors.isNotEmpty) {
              final firstErrorField = errors.keys.first;
              final errorList = errors[firstErrorField];
              if (errorList is List && errorList.isNotEmpty) {
                final firstDetailError = errorList[0]?.toString() ?? "Unknown validation issue.";
                String baseMessage = result['message']?.toString() ?? "Validation error.";
                errorMessage = '$baseMessage ${firstErrorField.capitalize()}: $firstDetailError';
              } else {
                errorMessage = result['message']?.toString() ?? 'Validation errors occurred.';
              }
            }
          }
          ToastUtils.showErrorToast(errorMessage);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          String exceptionMessage = 'An unexpected error occurred: ${e.toString()}';
          if (kDebugMode) {
            print(exceptionMessage);
          }
          ToastUtils.showErrorToast(exceptionMessage);
        }
      }
    }
  }

  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return SizedBox(
      width: double.infinity, // Agar tombol memenuhi lebar yang tersedia
      child: OutlinedButton.icon(
        icon: Icon(icon, color: iconColor),
        label: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color(0xFFC5C5C5);
    const Color hintTextColor = Color(0xFFC5C5C5);
    const double hintTextSize = 12.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 1. Header Texts
                const SizedBox(height: 30),
                const Text(
                  'Hello!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),

                // 2. Email Form Field
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFC5C5C5),
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: _emailController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: const TextStyle(
                      fontSize: hintTextSize,
                      color: hintTextColor
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC5C5C5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC5C5C5)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 3. Password Form Field
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFC5C5C5),
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: _passwordController,
                  enabled: !_isLoading,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(
                        fontSize: hintTextSize,
                        color: hintTextColor
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC5C5C5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC5C5C5)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    // Tambahkan validasi panjang password jika perlu
                    // if (value.length < 6) {
                    //   return 'Password must be at least 6 characters';
                    // }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // 4. Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 24, height: 24,
                              child: Checkbox(
                                value: _rememberMe, // Gunakan state _rememberMe
                                onChanged: _isLoading ? null : (bool? value) {
                                  setState(() {
                                    _rememberMe = value ?? false; // Update state _rememberMe
                                  });
                                },
                                activeColor: const Color(0xFF446DFF),
                                checkColor: Colors.white,
                                side: const BorderSide(color: Color(0xFFC5C5C5)),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Remember me', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pushNamed(context, forgotPasswordRoute),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 5. Login Button
                SizedBox(
                  width: 372, // Sesuai permintaan, namun pertimbangkan responsivitas
                  // Untuk lebar penuh dengan padding:
                  // width: double.infinity,
                  height: 50, // Tinggi tombol yang umum
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF446DFF), // Warna sama seperti Get Started
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), // Padding internal
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 6. Separator "Or"
                Row(
                  children: <Widget>[
                    Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Or',
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 32),

                // 7. Social Login Buttons
                _buildSocialButton(
                  text: 'Continue with Google',
                  // Placeholder icon, ganti dengan logo Google jika ada
                  icon: Icons.g_mobiledata_outlined, // Contoh, cari ikon Google yang lebih baik atau gunakan asset
                  iconColor: Colors.red, // Warna khas Google
                  onPressed: () {
                    // TODO: Implementasi Login dengan Google
                    if (kDebugMode) {
                      print('Continue with Google tapped');
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildSocialButton(
                  text: 'Continue with Apple',
                  // Placeholder icon, ganti dengan logo Apple jika ada
                  icon: Icons.apple,
                  iconColor: Colors.black, // Warna khas Apple
                  onPressed: () {
                    // TODO: Implementasi Login dengan Apple
                    if (kDebugMode) {
                      print('Continue with Apple tapped');
                    }
                  },
                ),
                const SizedBox(height: 40),

                // 8. Register Link
                Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Register',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navigasi ke halaman Registrasi
                              Navigator.pushNamed(context, registerRoute); // Menggunakan registerRoute
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper extension untuk capitalize (opsional)
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}