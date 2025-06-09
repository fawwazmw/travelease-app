import 'package:flutter/material.dart';

class AppCategory {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String publicIconUrl; // <-- DIPERBARUI: Sesuai 'icon_url' dari CategoryResource
  final int activeDestinationsCount; // <-- DITAMBAHKAN: Sesuai 'active_destinations_count'

  AppCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.publicIconUrl,
    required this.activeDestinationsCount,
  });

  factory AppCategory.fromJson(Map<String, dynamic> json) {
    return AppCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      // <-- DIPERBARUI: Mengambil langsung dari field yang disediakan API Resource Laravel
      publicIconUrl: json['icon_url'] as String? ?? '',
      activeDestinationsCount: json['active_destinations_count'] as int? ?? 0,
    );
  }

  // Logika displayIcon ini adalah untuk fallback UI jika URL ikon tidak bisa di-load.
  // Anda bisa menggantinya dengan Image.network(publicIconUrl) di UI.
  IconData get displayIcon {
    switch (name.toLowerCase()) {
      case 'pantai': return Icons.beach_access_outlined;
      case 'gunung': return Icons.landscape_outlined;
      case 'taman hiburan': return Icons.attractions_outlined;
      case 'museum': return Icons.museum_outlined;
      default: return Icons.category_outlined;
    }
  }
}