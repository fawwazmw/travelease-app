// File: lib/services/auth_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Untuk SocketException
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Impor shared_preferences
import '../models/user.dart'; // Pastikan path ini benar

class AuthService {
  // PASTIKAN _baseUrl SUDAH BENAR (IP PC Anda jika pakai perangkat fisik)
  final String _baseUrl = 'http://192.168.0.136:8000/api';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _authTokenKey = 'auth_token';
  static const String _rememberMeKey = 'remember_me';

  // --- Token Management ---
  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: _authTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _authTokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _authTokenKey);
  }

  // --- Remember Me Management ---
  Future<void> setRememberMe(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  Future<bool> getRememberMe() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  Future<void> clearRememberMe() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberMeKey);
  }


  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
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
          'message': responseData['message'] ?? 'Registration failed: Server error.'
        };
      }
    } on TimeoutException catch (_) {
      return {'success': false, 'message': 'Request timed out. Please try again.'};
    } on SocketException catch (e) {
      return {'success': false, 'message': 'Network error: Failed to connect. (${e.osError?.message ?? e.message})'};
    } on http.ClientException catch (e) {
      return {'success': false, 'message': 'Client error: Connection problem. (${e.message})'};
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred during registration: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required bool rememberMe, // Tambahkan parameter rememberMe
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
        if (responseData['access_token'] != null) {
          await _saveToken(responseData['access_token']);
          await setRememberMe(rememberMe); // Simpan status rememberMe
        }
        return {
          'success': true,
          'message': responseData['message'],
          'user': User.fromJson(responseData['user']),
          'token': responseData['access_token']
        };
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': responseData['message'] ?? 'Invalid credentials.'};
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Email not verified.',
          'email_not_verified': responseData['email_not_verified'] ?? true,
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Validation error.',
          'errors': responseData['errors']
        };
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Login failed: Server error.'};
      }
    } on TimeoutException catch (_) {
      return {'success': false, 'message': 'The connection to the server timed out. Please try again.'};
    } on SocketException catch (e) {
      return {'success': false, 'message': 'Network error: Failed to connect. (${e.osError?.message ?? e.message})'};
    } on http.ClientException catch (e) {
      return {'success': false, 'message': 'Connection problem: Could not establish connection. (${e.message})'};
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred during login: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    String? token = await getToken();
    if (token == null) {
      return {'success': false, 'message': 'Not authenticated: No token found.'};
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'user': User.fromJson(responseData)};
      } else if (response.statusCode == 401) {
        await deleteToken(); // Token tidak valid, hapus
        await clearRememberMe();
        return {'success': false, 'message': 'Unauthorized. Please login again.'};
      }
      else {
        return {'success': false, 'message': responseData['message'] ?? 'Failed to fetch user profile.'};
      }
    } on TimeoutException catch (_) {
      return {'success': false, 'message': 'Request timed out while fetching user profile.'};
    } on SocketException catch (e) {
      return {'success': false, 'message': 'Network error fetching profile. (${e.osError?.message ?? e.message})'};
    } on http.ClientException catch (e) {
      return {'success': false, 'message': 'Connection problem fetching profile. (${e.message})'};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred fetching profile: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    String? token = await getToken();
    if (token == null) {
      // Jika tidak ada token, anggap sudah logout atau sesi tidak valid
      await clearRememberMe(); // Pastikan remember me juga di-clear
      return {'success': true, 'message': 'Already logged out or no session found.'};
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      // Apapun respons server, kita hapus token dan remember me di sisi klien
      await deleteToken();
      await clearRememberMe();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'message': responseData['message'] ?? 'Logout successful.'};
      } else {
        // Meskipun logout di server gagal, kita tetap logout di klien
        return {'success': true, 'message': 'Logged out locally. Server might have an issue.'};
      }
    } on TimeoutException catch (_) {
      await deleteToken(); await clearRememberMe(); // Tetap logout lokal
      return {'success': true, 'message': 'Logout request timed out. Logged out locally.'};
    } on SocketException catch (e) {
      await deleteToken(); await clearRememberMe(); // Tetap logout lokal
      return {'success': true, 'message': 'Network error during logout. Logged out locally. (${e.osError?.message ?? e.message})'};
    } on http.ClientException catch (e) {
      await deleteToken(); await clearRememberMe(); // Tetap logout lokal
      return {'success': true, 'message': 'Connection problem during logout. Logged out locally. (${e.message})'};
    } catch (e) {
      await deleteToken(); await clearRememberMe(); // Tetap logout lokal
      return {
        'success': true, // Anggap logout lokal berhasil
        'message': 'An unexpected error occurred during logout. Logged out locally: ${e.toString()}'
      };
    }
  }
}