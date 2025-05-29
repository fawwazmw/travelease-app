// File: lib/screens/category_destination_list_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Impor model dari folder models
import '../models/destination.dart'; // Sesuaikan path jika struktur folder Anda berbeda
import '../models/category.dart';   // Sesuaikan path jika struktur folder Anda berbeda

// Definisi class Category dan Destination sudah dipindah ke file model masing-masing

class CategoryDestinationListScreen extends StatefulWidget {
  final AppCategory category;

  const CategoryDestinationListScreen({super.key, required this.category});

  @override
  State<CategoryDestinationListScreen> createState() =>
      _CategoryDestinationListScreenState();
}

class _CategoryDestinationListScreenState
    extends State<CategoryDestinationListScreen> {
  List<Destination> _categoryDestinations = [];

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  void _loadDestinations() {
    // Simulasi filter atau fetch data berdasarkan kategori
    final allDestinations = [
      Destination(id: '1', name: 'Kuta Beach Hotel', location: 'Bali, Indonesia', imageUrl: 'https://via.placeholder.com/150/FFC107/000000?Text=Hotel+Kuta', price: 120, rating: 4.8, discount: '30% OFF', isFavorite: false),
      Destination(id: '2', name: 'Bromo Sunrise Lodge', location: 'East Java, Indonesia', imageUrl: 'https://via.placeholder.com/150/4CAF50/FFFFFF?Text=Lodge+Bromo', price: 250, rating: 4.9, isFavorite: true),
      Destination(id: '3', name: 'Borobudur View Resort', location: 'Central Java, Indonesia', imageUrl: 'https://via.placeholder.com/150/2196F3/FFFFFF?Text=Resort+Borobudur', price: 180, rating: 4.7),
      Destination(id: '4', name: 'Raja Ampat Dive Resort', location: 'West Papua, Indonesia', imageUrl: 'https://via.placeholder.com/150/00BCD4/FFFFFF?Text=Dive+Raja+Ampat', price: 500, rating: 4.9, isFavorite: false),
      Destination(id: '5', name: 'Komodo Island Stay', location: 'NTT, Indonesia', imageUrl: 'https://via.placeholder.com/150/8BC34A/FFFFFF?Text=Stay+Komodo', price: 450, rating: 4.8),
    ];

    if (widget.category.name == "Hotels") {
      _categoryDestinations = allDestinations.where((d) => d.name.toLowerCase().contains("hotel") || d.name.toLowerCase().contains("lodge") || d.name.toLowerCase().contains("resort") || d.name.toLowerCase().contains("stay")).toList();
    } else if (widget.category.name == "Flights") {
      _categoryDestinations = [];
    } else {
      _categoryDestinations = allDestinations.take(3).toList();
    }
    if(mounted){
      setState(() {});
    }
  }

  Widget _buildDestinationTile(Destination destination) {
    // Gaya kartu ini sekarang akan mengikuti _buildDestinationCard (Featured Card)
    // dari HomeScreen Anda
    return GestureDetector(
      onTap: () {
        // TODO: Navigasi ke detail destinasi
        // Pastikan menggunakan kDebugMode jika print hanya untuk debug
        if (kDebugMode) {
          print('Tapped on Category Destination: ${destination.name}');
        }
      },
      child: Container(
        // Untuk vertical list, width tidak di-set agar mengambil lebar parent
        margin: const EdgeInsets.only(bottom: 20.0), // Jarak antar kartu, bisa disesuaikan
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Rounded corners untuk card
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column( // Layout utama adalah Column
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                ClipRRect(
                  // Menggunakan BorderRadius.all agar semua sudut gambar melengkung
                  // Sesuai dengan _buildDestinationCard di HomeScreen Anda
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: Image.network(
                    destination.imageUrl,
                    height: 160, // Tinggi gambar seperti featured card di HomeScreen
                    width: double.infinity, // Gambar memenuhi lebar card
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                        ),
                        child: const Icon(Icons.image_not_supported)
                    ),
                  ),
                ),
                if (destination.discount != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC900), // Warna diskon dari HomeScreen
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        destination.discount!,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                Positioned( // Ikon Love Tanpa Lingkaran
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: Icon(
                        destination.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: destination.isFavorite ? Colors.red : Colors.grey.shade700,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() { // setState ini akan bekerja karena _buildDestinationTile adalah method dari _CategoryDestinationListScreenState
                          destination.isFavorite = !destination.isFavorite;
                          // TODO: Update status favorit di backend/database
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0), // Padding untuk konten teks
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    // Style disamakan dengan _buildDestinationCard di HomeScreen
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Style ikon dan teks lokasi disamakan dengan _buildDestinationCard di HomeScreen
                      const Icon(Icons.location_on, color: Color(0xFF446DFF), size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination.location,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Jarak sebelum baris harga/rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end, // Agar /night sejajar dengan bawah harga
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            // Style harga disamakan dengan _buildDestinationCard di HomeScreen
                            'Rp ${destination.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF446DFF)),
                          ),
                          Padding( // Menggunakan Padding agar ada sedikit jarak
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Text(
                              // Style /night disamakan dengan _buildDestinationCard di HomeScreen
                              '/night',
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
                            destination.rating.toString(),
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
              print('More options for ${widget.category.name} tapped');
            },
          ),
        ],
      ),
      body: _categoryDestinations.isEmpty
          ? Center(
        child: Text('No destinations found for ${widget.category.name}.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        itemCount: _categoryDestinations.length,
        itemBuilder: (context, index) {
          return _buildDestinationTile(_categoryDestinations[index]);
        },
      ),
    );
  }
}