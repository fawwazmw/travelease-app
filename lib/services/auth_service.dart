// File: lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Impor secure storage
import '../models/user.dart'; // Pastikan path ini benar

class AuthService {
  final String _baseUrl = 'http://192.168.2.240:8000/api'; // GANTI DENGAN IP PC ANDA JIKA PAKAI PERANGKAT FISIK
  // final String _baseUrl = 'http://10.0.2.2:8000/api'; // Untuk emulator Android

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Method untuk menyimpan token
  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  // Method untuk mengambil token (akan berguna nanti)
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Method untuk menghapus token (untuk logout)
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    // ... (kode register Anda yang sudah ada tetap di sini)
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      ).timeout(const Duration(seconds: 20));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'],
          'user': User.fromJson(responseData['user'])
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'message': responseData['message'],
          'errors': responseData['errors']
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed due to an unknown error.'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to connect to the server. Please check your internet connection. ${e.toString()}'
      };
    }
  }

  // --- METHOD LOGIN BARU ---
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 20));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Login berhasil, simpan token
        if (responseData['access_token'] != null) {
          await _saveToken(responseData['access_token']);
        }
        return {
          'success': true,
          'message': responseData['message'],
          'user': User.fromJson(responseData['user']),
          'token': responseData['access_token'] // Kirim token juga jika perlu langsung digunakan
        };
      } else if (response.statusCode == 401) {
        // Email atau password salah
        return {'success': false, 'message': responseData['message'] ?? 'Invalid credentials.'};
      } else if (response.statusCode == 403) {
        // Email belum terverifikasi
        return {
          'success': false,
          'message': responseData['message'] ?? 'Email not verified.',
          'email_not_verified': responseData['email_not_verified'] ?? true,
        };
      } else if (response.statusCode == 422) {
        // Error validasi (misalnya email tidak valid formatnya)
        return {
          'success': false,
          'message': responseData['message'] ?? 'Validation error.',
          'errors': responseData['errors']
        };
      }
      else {
        // Error server atau lainnya
        return {'success': false, 'message': responseData['message'] ?? 'Login failed due to an unknown error.'};
      }
    } catch (e) {
      // Error koneksi atau lainnya
      return {
        'success': false,
        'message': 'Failed to connect to the server. Please check your internet connection. ${e.toString()}'
      };
    }
  }
}