import 'package:flutter/material.dart';
import 'dart:async'; // Untuk Timer, jika diperlukan untuk auto-scroll
import 'package:intl/intl.dart';

// Impor model destinasi Anda
import '../../models/destination.dart';

class DestinationDetailScreen extends StatefulWidget {
  final Destination destination;

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  late final PageController _pageController;
  int _currentPageIndex = 0;

  // Simulasi daftar gambar, karena model hanya punya satu URL
  late final List<String> _imageUrls;

  final NumberFormat idrFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Menggunakan gambar utama beberapa kali untuk simulasi carousel
    _imageUrls = [
      widget.destination.mainImageUrl,
      widget.destination.mainImageUrl, // Gambar simulasi ke-2
      widget.destination.mainImageUrl, // Gambar simulasi ke-3
    ];

    _pageController.addListener(() {
      // Dapatkan halaman terdekat dan update state jika berbeda
      if (_pageController.page?.round() != _currentPageIndex) {
        setState(() {
          _currentPageIndex = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Widget untuk membuat titik indikator di bawah carousel gambar
  Widget _buildIndicatorDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_imageUrls.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: _currentPageIndex == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: _currentPageIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  // Widget untuk menampilkan chip info (seperti rating, dll)
  Widget _buildInfoChip({required IconData icon, required String label, required Color color}) {
    return Chip(
      avatar: Icon(icon, color: color, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Menggunakan CustomScrollView untuk efek scrolling yang lebih dinamis
      body: CustomScrollView(
        slivers: <Widget>[
          // AppBar yang bisa membesar dan mengecil (flexible)
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 1.0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.3)
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  // TODO: Tampilkan menu options
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tombol Opsi Ditekan')),
                  );
                },
                style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3)
                ),
              ),
              const SizedBox(width: 8)
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Carousel Gambar
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _imageUrls.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        _imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                        ),
                      );
                    },
                  ),
                  // Gradient hitam di bawah agar teks dan indikator terlihat jelas
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                  // Posisi untuk indikator dots
                  Positioned(
                    bottom: 16.0,
                    left: 0,
                    right: 0,
                    child: _buildIndicatorDots(),
                  ),
                ],
              ),
            ),
          ),

          // Konten utama di bawah AppBar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Destinasi
                  Text(
                    widget.destination.name,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Lokasi
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.destination.locationAddress ?? 'Lokasi tidak diketahui',
                          style: textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Info dalam bentuk Chip
                  Wrap(
                    spacing: 12.0,
                    runSpacing: 8.0,
                    children: [
                      _buildInfoChip(
                        icon: Icons.star_rounded,
                        label: '${widget.destination.averageRating} Rating',
                        color: Colors.amber.shade700,
                      ),
                      _buildInfoChip(
                        icon: Icons.phone_outlined,
                        label: 'Contact',
                        color: Colors.blue.shade700,
                      ),
                      _buildInfoChip(
                        icon: Icons.map_outlined,
                        label: 'Map',
                        color: Colors.green.shade700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Deskripsi
                  Text(
                    'Description',
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // Menggunakan deskripsi placeholder jika data asli tidak ada
                    widget.destination.description ?? 'Deskripsi untuk ${widget.destination.name} belum tersedia. Kunjungi tempat indah ini untuk merasakan pengalaman yang tak terlupakan dengan pemandangan yang memukau dan suasana yang menenangkan.',
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 10,
                      color: Colors.black87,
                      height: 1.5, // Jarak antar baris
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 80), // Beri ruang agar tidak tertutup bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar Kustom
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12).copyWith(
          bottom: MediaQuery.of(context).padding.bottom + 12, // Padding aman untuk area bawah layar
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          // borderRadius: const BorderRadius.only(
          //   topLeft: Radius.circular(20),
          //   topRight: Radius.circular(20),
          // ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Kolom Harga
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price',
                  style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: idrFormatter.format(widget.destination.ticketPrice),
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      TextSpan(
                        text: ' /person',
                        style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Tombol Book Now
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigasi ke halaman booking
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Mengarahkan ke halaman booking untuk ${widget.destination.name}...')),
                );
              },
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
              label: const Text('Book Now'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}