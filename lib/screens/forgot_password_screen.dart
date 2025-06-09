import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// const String resetPasswordRoute = '/reset-password'; // Akan digunakan nanti setelah kode dikirim

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      if (kDebugMode) {
        print('Send code to email: $email');
      }
      // TODO: Panggil API untuk mengirim kode reset password
      // Setelah berhasil, mungkin navigasi ke halaman input kode verifikasi
      // Navigator.pushNamed(context, resetPasswordRoute, arguments: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification code will be sent to $email if it is registered.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color(0xFFC5C5C5);
    const Color hintTextColor = Color(0xFFC5C5C5);
    const double hintTextSize = 12.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar( // Menambahkan AppBar untuk tombol kembali yang standar
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0), // Penyesuaian padding vertikal
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20), // Jarak dari AppBar
                // 1. Header Texts
                const Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  "Your Email Address", // Sub-header
                  style: TextStyle(
                    fontSize: 30, // Ukuran font lebih kecil untuk sub-header
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Instructional Text
                const Text(
                  'Please enter your email address associated with your account. We will send a code to reset your password.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // 3. Email Form Field
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFC5C5C5), // Warna label
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: const TextStyle(
                      fontSize: hintTextSize,
                      color: hintTextColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 10),
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
                const SizedBox(height: 30),

                // 4. Send Code Button
                SizedBox(
                  width: 372, // Sesuai permintaan
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _sendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF446DFF), // Warna tombol
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Send Code',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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