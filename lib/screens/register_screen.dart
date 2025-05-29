import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// Impor AuthService dan User model jika perlu
import '../services/auth_service.dart'; // Sesuaikan path jika perlu
// import '../models/user.dart'; // Tidak perlu diimpor langsung di sini jika hanya passing data

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isCreatePasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false; // State untuk loading

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _createPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService(); // Instance AuthService

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _createPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async { // Ubah menjadi async
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must agree to the Terms and Conditions.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true; // Mulai loading
      });

      try {
        final result = await _authService.register(
          name: _nameController.text,
          email: _emailController.text,
          password: _createPasswordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );

        setState(() {
          _isLoading = false; // Selesai loading
        });

        if (!mounted) return; // Cek jika widget masih ada di tree

        if (result['success'] == true) {
          // User user = result['user'] as User; // Ambil data user jika perlu
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registration successful! Please check your email.'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigasi ke halaman login setelah beberapa saat atau tampilkan dialog
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              // Ganti '/login' dengan konstanta rute Anda jika ada (misal: loginRoute)
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
        } else {
          // Tampilkan error
          String errorMessage = result['message'] ?? 'Registration failed.';
          if (result['errors'] != null) {
            // Jika ada error validasi spesifik, bisa ditampilkan
            // Contoh: ambil error pertama
            Map<String, dynamic> errors = result['errors'];
            if (errors.isNotEmpty) {
              // Ambil pesan error dari field pertama yang error
              final firstErrorField = errors.keys.first;
              final firstErrorMessage = (errors[firstErrorField] as List).isNotEmpty
                  ? (errors[firstErrorField] as List)[0]
                  : "Validation error.";
              errorMessage = '$errorMessage ${errors.keys.first.capitalize()}: $firstErrorMessage';
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false; // Selesai loading jika ada exception
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const String localLoginRoute = '/login';
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
                const SizedBox(height: 30),
                const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  'New Account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),

                // Form Field Name (BARU DITAMBAHKAN)
                const Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFC5C5C5),
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: _nameController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    hintStyle: const TextStyle(
                      fontSize: hintTextSize,
                      color: hintTextColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC5C5C5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC5C5C5)), // Tetap C5C5C5 saat fokus
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),


                // Form Field Email
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
                      color: hintTextColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC5C5C5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC5C5C5)), // Tetap C5C5C5 saat fokus
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

                // Form Field Create Password
                const Text(
                  'Create Password',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFC5C5C5),
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: _createPasswordController,
                  enabled: !_isLoading,
                  obscureText: !_isCreatePasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(
                      fontSize: hintTextSize,
                      color: hintTextColor,
                    ),
                    suffixIcon: IconButton( // Tambahkan suffixIcon untuk Create Password juga
                      icon: Icon(
                        _isCreatePasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFFC5C5C5), // Warna ikon disamakan
                      ),
                      onPressed: () {
                        setState(() {
                          _isCreatePasswordVisible = !_isCreatePasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC5C5C5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC5C5C5)), // Tetap C5C5C5 saat fokus
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please create a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Form Field Confirm Password
                const Text(
                  'Confirm Password',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFC5C5C5),
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: _confirmPasswordController,
                  enabled: !_isLoading,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Confirm your password',
                    hintStyle: const TextStyle(
                      fontSize: hintTextSize,
                      color: hintTextColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFFC5C5C5), // Warna ikon disamakan
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC5C5C5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC5C5C5)), // Tetap C5C5C5 saat fokus
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _createPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Terms and Conditions Checkbox
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        onChanged: _isLoading ? null : (bool? value) => setState(() => _agreeToTerms = value ?? false),
                        activeColor: const Color(0xFF446DFF), // Warna checkbox disamakan dengan tombol
                        checkColor: Colors.white, // Warna centang
                        side: const BorderSide(color: Color(0xFFC5C5C5)), // Warna border checkbox
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: 'I agree to ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontFamily: 'Poppins',
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: const TextStyle(
                                color: Colors.black, // Warna disamakan dengan "Login" di bawah
                                fontWeight: FontWeight.w500, // Sedikit lebih tebal
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.black, // Garis bawah juga hitam
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  print('Terms and Conditions tapped');
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  width: 372,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF446DFF),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                // Link "Already have an account? Login"
                Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Login',
                          style: const TextStyle(
                            color: Colors.black, // Warna disamakan dengan "Terms and Conditions"
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacementNamed(context, localLoginRoute);
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

// Helper extension untuk capitalize (opsional, jika Anda ingin pesan error lebih rapi)
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}