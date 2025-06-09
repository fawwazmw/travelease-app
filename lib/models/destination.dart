class Destination {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? locationAddress;
  final double latitude;
  final double longitude;
  final double ticketPrice;
  final String? operationalHours;
  final String? contactPhone;
  final String? contactEmail;
  final double averageRating;
  final int totalReviews;
  final bool isActive;
  final String mainImageUrl;
  final List<String> imageUrls;
  bool isFavorite;

  // Definisikan IP server Anda di sini sebagai fallback
  static const String _serverIp = 'http://192.168.0.136:8000';

  Destination({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.locationAddress,
    required this.latitude,
    required this.longitude,
    required this.ticketPrice,
    this.operationalHours,
    this.contactPhone,
    this.contactEmail,
    required this.averageRating,
    required this.totalReviews,
    required this.isActive,
    required this.mainImageUrl,
    required this.imageUrls,
    this.isFavorite = false,
  });

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Helper untuk memperbaiki URL yang mungkin menggunakan 'localhost'.
  static String _fixUrl(String url) {
    // Jika URL dari API menggunakan 'localhost', ganti dengan IP server yang benar.
    if (url.startsWith('http://localhost')) {
      return url.replaceFirst('http://localhost', _serverIp);
    }
    // Jika sudah benar, langsung kembalikan.
    return url;
  }

  factory Destination.fromJson(Map<String, dynamic> json) {
    String mainImageUrlRaw = json['main_image_url'] as String? ?? '';
    List<String> imageUrlsRaw = List<String>.from(json['image_urls'] as List? ?? []);

    return Destination(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown Name',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      locationAddress: json['location_address'] as String?,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      ticketPrice: _parseDouble(json['ticket_price']),
      operationalHours: json['operational_hours'] as String?,
      contactPhone: json['contact_phone'] as String?,
      contactEmail: json['contact_email'] as String?,
      averageRating: _parseDouble(json['average_rating']),
      totalReviews: _parseInt(json['total_reviews']),
      isActive: json['is_active'] as bool? ?? false,

      // Gunakan helper untuk memperbaiki URL sebelum disimpan ke model
      mainImageUrl: mainImageUrlRaw.isNotEmpty ? _fixUrl(mainImageUrlRaw) : 'https://placehold.co/600x400?text=No+Image',
      imageUrls: imageUrlsRaw.map((url) => _fixUrl(url)).toList(),
    );
  }
}
