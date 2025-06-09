import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/category.dart';
import '../models/destination.dart';
import 'auth_service.dart';

class ApiService {
  // TODO: Ganti dengan alamat IP PC Anda saat testing di perangkat fisik,
  // atau 10.0.2.2 jika menggunakan emulator Android.
  // Jangan gunakan 'localhost' atau '127.0.0.1'.
  final String _baseUrl = 'http://192.168.0.136:8000/api';
  final AuthService _authService = AuthService();

  // Helper untuk membuat header standar
  Future<Map<String, String>> _getHeaders({bool withAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = await _authService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// Fetches a list of categories from the API.
  /// Throws an [Exception] if the request fails.
  Future<List<AppCategory>> getCategories() async {
    final url = Uri.parse('$_baseUrl/categories');
    if (kDebugMode) print("ApiService: Fetching categories from $url");

    try {
      final response = await http.get(url, headers: await _getHeaders())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // API Laravel Resource mengembalikan data dalam wrapper 'data'
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((json) => AppCategory.fromJson(json)).toList();
      } else {
        // Jika response bukan 200, lempar exception dengan pesan dari server
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to load categories: ${errorBody['message'] ?? response.reasonPhrase}');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your connection.');
    } on SocketException {
      throw Exception('Network error. Could not connect to the server.');
    } catch (e) {
      if (kDebugMode) print("ApiService getCategories Exception: $e");
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Fetches a list of destinations from the API.
  /// Can be filtered by [categorySlug] and other parameters.
  /// Throws an [Exception] if the request fails.
  Future<List<Destination>> getDestinations({String? categorySlug}) async {
    // Membangun URL dengan query parameters jika ada
    final uri = Uri.parse('$_baseUrl/destinations').replace(
      queryParameters: {
        if (categorySlug != null) 'category_slug': categorySlug,
        // Tambahkan parameter lain di sini jika perlu, e.g., 'sort_by': 'average_rating'
      },
    );
    if (kDebugMode) print("ApiService: Fetching destinations from $uri");

    try {
      final response = await http.get(uri, headers: await _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        // API paginasi Laravel mengembalikan list item di dalam 'data'
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((json) => Destination.fromJson(json)).toList();
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Failed to load destinations: ${errorBody['message'] ?? response.reasonPhrase}');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your connection.');
    } on SocketException {
      throw Exception('Network error. Could not connect to the server.');
    } catch (e) {
      if (kDebugMode) print("ApiService getDestinations Exception: $e");
      throw Exception('An unexpected error occurred: $e');
    }
  }
}