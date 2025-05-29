// File: lib/models/destination.dart

class Destination {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final double price;
  final double rating;
  final String? discount; // Opsional
  bool isFavorite;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.rating,
    this.discount,
    this.isFavorite = false,
  });
}