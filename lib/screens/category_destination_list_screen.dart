import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Impor model dan service
import '../models/destination.dart';
import '../models/category.dart'; // Ini adalah AppCategory
import '../services/api_service.dart';

class CategoryDestinationListScreen extends StatefulWidget {
  final AppCategory category;

  const CategoryDestinationListScreen({super.key, required this.category});

  @override
  State<CategoryDestinationListScreen> createState() =>
      _CategoryDestinationListScreenState();
}

class _CategoryDestinationListScreenState
    extends State<CategoryDestinationListScreen> {
  // --- State ---
  List<Destination> _categoryDestinations = [];
  bool _isLoading = true;
  String? _error;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchDestinationsByCategory();
  }

  /// Fetches destinations based on the category slug using the updated ApiService.
  Future<void> _fetchDestinationsByCategory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (kDebugMode) {
      print("Fetching destinations for category slug: ${widget.category.slug}");
    }

    try {
      // Panggil service yang kini mengembalikan Future<List<Destination>>
      final destinations = await _apiService.getDestinations(categorySlug: widget.category.slug);

      if (mounted) {
        setState(() {
          _categoryDestinations = destinations;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Tangkap exception yang dilempar oleh ApiService
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // --- Widget Builders ---

  Widget _buildDestinationTile(Destination destination) {
    return GestureDetector(
      onTap: () {
        if (kDebugMode) {
          print('Tapped on Category Destination: ${destination.name}');
          // TODO: Navigasi ke detail destinasi
          // Navigator.pushNamed(context, destinationDetailRoute, arguments: destination);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: Image.network(
                    destination.mainImageUrl, // <-- DIPERBARUI: Menggunakan field yang benar
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                        ),
                        child: const Icon(Icons.image_not_supported, color: Colors.grey)
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.white.withOpacity(0.7),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        setState(() {
                          destination.isFavorite = !destination.isFavorite;
                          // TODO: Panggil service untuk update status favorit di backend
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Icon(
                          destination.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: destination.isFavorite ? Colors.red : Colors.grey.shade800,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF446DFF), size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination.locationAddress ?? 'Unknown location',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'Rp${destination.ticketPrice.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF446DFF)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Text(
                              '/ticket',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            destination.averageRating.toString(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF446DFF)),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                onPressed: _fetchDestinationsByCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF446DFF),
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      );
    }

    if (_categoryDestinations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No destinations found for "${widget.category.name}".\nTry exploring other categories!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 16, height: 1.5),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchDestinationsByCategory,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        itemCount: _categoryDestinations.length,
        itemBuilder: (context, index) {
          return _buildDestinationTile(_categoryDestinations[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.category.name,
          style: const TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {
              if (kDebugMode) {
                print('More options for ${widget.category.name} tapped');
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}