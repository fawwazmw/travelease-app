// File: lib/screens/home_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'dart:async';

// Impor model dari folder models
import '../models/destination.dart'; // Sesuaikan path jika struktur folder Anda berbeda
import '../models/category.dart';   // Sesuaikan path jika struktur folder Anda berbeda

// Definisi class Category dan Destination sudah dipindah ke file model masing-masing

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  String _currentCity = 'Getting Location...';
  String _currentAdminArea = '';
  bool _isLocationLoading = true;
  String? _locationError;

  final loc.Location _locationPlugin = loc.Location();

  final List<Destination> _featuredDestinations = [
    Destination(id: '1', name: 'Kuta Beach', location: 'Bali, Indonesia', imageUrl: 'https://via.placeholder.com/300x200/FFC107/000000?Text=Kuta+Beach', price: 120, rating: 4.8, discount: '30% OFF', isFavorite: false),
    Destination(id: '2', name: 'Mount Bromo', location: 'East Java, Indonesia', imageUrl: 'https://via.placeholder.com/300x200/4CAF50/FFFFFF?Text=Mount+Bromo', price: 250, rating: 4.9, isFavorite: true),
    Destination(id: '3', name: 'Borobudur Temple', location: 'Central Java, Indonesia', imageUrl: 'https://via.placeholder.com/300x200/2196F3/FFFFFF?Text=Borobudur', price: 180, rating: 4.7, discount: '15% OFF'),
  ];

  final List<Destination> _popularDestinations = [
    Destination(id: '4', name: 'Raja Ampat', location: 'West Papua, Indonesia', imageUrl: 'https://via.placeholder.com/150/00BCD4/FFFFFF?Text=Raja+Ampat', price: 500, rating: 4.9, isFavorite: false),
    Destination(id: '5', name: 'Labuan Bajo', location: 'NTT, Indonesia', imageUrl: 'https://via.placeholder.com/150/8BC34A/FFFFFF?Text=Labuan+Bajo', price: 450, rating: 4.8),
    Destination(id: '6', name: 'Ubud Monkey Forest', location: 'Bali, Indonesia', imageUrl: 'https://via.placeholder.com/150/FF9800/000000?Text=Ubud+Forest', price: 90, rating: 4.6, isFavorite: true),
    Destination(id: '7', name: 'Gili Trawangan', location: 'Lombok, Indonesia', imageUrl: 'https://via.placeholder.com/150/03A9F4/FFFFFF?Text=Gili+T', price: 380, rating: 4.7, isFavorite: false),
  ];

  // Menggunakan AppCategory yang sudah diganti namanya
  final List<AppCategory> _categories = [ // <<--- UBAH TIPE LIST DI SINI
    AppCategory(id: 'cat1', name: 'Hotels', icon: Icons.hotel_outlined), // <<--- UBAH KONSTRUKTOR DI SINI
    AppCategory(id: 'cat2', name: 'Flights', icon: Icons.flight_takeoff_outlined), // <<--- UBAH KONSTRUKTOR DI SINI
    AppCategory(id: 'cat3', name: 'Trains', icon: Icons.train_outlined), // <<--- UBAH KONSTRUKTOR DI SINI
    AppCategory(id: 'cat4', name: 'More', icon: Icons.more_horiz_outlined), // <<--- UBAH KONSTRUKTOR DI SINI
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndAddress();
  }

  Future<void> _getCurrentLocationAndAddress() async {
    setState(() {
      _isLocationLoading = true;
      _locationError = null;
      _currentCity = 'Getting Location...';
      _currentAdminArea = '';
    });

    try {
      bool serviceEnabled = await _locationPlugin.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationPlugin.requestService();
        if (!serviceEnabled) {
          setState(() {
            _locationError = 'Location services are disabled. Please enable them manually.';
            _currentCity = 'Location Off';
            _isLocationLoading = false;
          });
          return;
        }
      }

      loc.PermissionStatus permissionGranted = await _locationPlugin.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _locationPlugin.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted && permissionGranted != loc.PermissionStatus.grantedLimited) {
          setState(() {
            _locationError = 'Location permission was denied. Please grant permission.';
            _currentCity = (permissionGranted == loc.PermissionStatus.deniedForever)
                ? 'Permission Blocked'
                : 'Permission Denied';
            if (permissionGranted == loc.PermissionStatus.deniedForever) {
              _locationError = 'Location permission is permanently denied. Please enable it in app settings.';
            }
            _isLocationLoading = false;
          });
          return;
        }
      }

      loc.LocationData locationData = await _locationPlugin.getLocation();

      if (locationData.latitude != null && locationData.longitude != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          locationData.latitude!,
          locationData.longitude!,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            _currentCity = place.locality ?? place.subAdministrativeArea ?? 'Unknown City';
            _currentAdminArea = place.administrativeArea ?? '';
            _isLocationLoading = false;
            _locationError = null;
          });
        } else {
          setState(() {
            _currentCity = 'Location Not Found';
            _isLocationLoading = false;
            _locationError = 'Could not determine location name.';
          });
        }
      } else {
        setState(() {
          _currentCity = 'Failed to get coords';
          _isLocationLoading = false;
          _locationError = 'Could not get precise coordinates.';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting location with 'location' plugin: $e");
      }
      setState(() {
        _locationError = 'Failed to get location. Check connection/settings.';
        _currentCity = 'Error Fetching';
        _isLocationLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildLocationHeader() {
    String displayLocationText;
    bool showErrorColor = _locationError != null;

    if (_isLocationLoading) {
      displayLocationText = 'Getting Location...';
    } else if (_locationError != null) {
      displayLocationText = _currentCity;
    } else {
      displayLocationText = _currentCity;
      if (_currentAdminArea.isNotEmpty &&
          _currentCity.toLowerCase() != _currentAdminArea.toLowerCase() &&
          !_currentCity.toLowerCase().contains(_currentAdminArea.toLowerCase())) {
        displayLocationText += ', $_currentAdminArea';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _isLocationLoading ? null : _getCurrentLocationAndAddress,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: showErrorColor ? Colors.red : const Color(0xFF446DFF), size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          displayLocationText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: showErrorColor ? Colors.red.shade700 : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (!_isLocationLoading && !showErrorColor)
                        const Icon(Icons.arrow_drop_down, color: Colors.black54, size: 20),
                    ],
                  ),
                ),
                if (_locationError != null && !_isLocationLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _locationError!,
                      style: TextStyle(fontSize: 10, color: Colors.red.shade700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black54),
              onPressed: () {
                if (kDebugMode) {
                  print('Notification button tapped');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search destination...',
                  hintStyle: TextStyle(fontSize: 14, color: Color(0xFFC5C5C5)),
                  prefixIcon: Icon(Icons.search, color: Color(0xFFC5C5C5), size: 30,),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF446DFF),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                if (kDebugMode) {
                  print('Filter button tapped');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcons() {
    Widget buildCategoryItem(AppCategory category) { // <<--- UBAH PARAMETER MENJADI AppCategory
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/category-destinations',
            arguments: category, // Argumen sekarang bertipe AppCategory
          );
          if (kDebugMode) {
            print('${category.name} category tapped');
          }
        },
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F7FD),
                shape: BoxShape.circle,
              ),
              child: Icon(category.icon, color: const Color(0xFF446DFF), size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _categories.map((category) => buildCategoryItem(category)).toList(),
      ),
    );
  }

  Widget _buildDestinationCard(Destination destination, {bool isFeatured = true}) {
    return GestureDetector(
      onTap: () {
        if (kDebugMode) {
          print('Tapped on ${destination.name}');
        }
      },
      child: Container(
        width: isFeatured ? 300 : null,
        margin: const EdgeInsets.only(right: 16.0),
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
                    destination.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(height: 160, width: isFeatured ? 300 : double.infinity, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)),
                  ),
                ),
                if (destination.discount != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC900),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        destination.discount!,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                Positioned(
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
                        setState(() {
                          destination.isFavorite = !destination.isFavorite;
                        });
                      },
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
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
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
                            'Rp ${destination.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF446DFF)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2.0),
                            child: Text(
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

  Widget _buildSectionHeader(String title, VoidCallback onSeeAllPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          TextButton(
            onPressed: onSeeAllPressed,
            child: const Text(
              'See all',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularDestinationTile(Destination destination) {
    return GestureDetector(
      onTap: () {
        if (kDebugMode) {
          print('Tapped on Popular: ${destination.name}');
        }
      },
      child: Container(
        width: 300,
        height: 120,
        margin: const EdgeInsets.only(right: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16)
                  ),
                  child: Image.network(
                    destination.imageUrl,
                    width: 110,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        width: 110,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16)
                          ),
                        ),
                        child: const Icon(Icons.image_not_supported)),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: Icon(
                        destination.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: destination.isFavorite ? Colors.red : Colors.grey.shade700,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          destination.isFavorite = !destination.isFavorite;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      destination.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF446DFF), size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.location,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              destination.rating.toString(),
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Rp ${destination.price.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF446DFF)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2.0),
                          child: Text(
                            '/night',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            _buildLocationHeader(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            _buildCategoryIcons(),
            SizedBox(
              height: 280,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 24.0, top: 8, bottom: 8),
                scrollDirection: Axis.horizontal,
                itemCount: _featuredDestinations.length,
                itemBuilder: (context, index) {
                  return _buildDestinationCard(_featuredDestinations[index]);
                },
              ),
            ),
            _buildSectionHeader('Popular', () {
              if (kDebugMode) {
                print('See All Popular Destination tapped');
              }
            }),
            SizedBox(
              height: 130,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 24.0, top: 8, bottom: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _popularDestinations.length,
                itemBuilder: (context, index) {
                  return _buildPopularDestinationTile(_popularDestinations[index]);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF446DFF),
        unselectedItemColor: Colors.grey.shade500,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 5.0,
        backgroundColor: Colors.white,
      ),
    );
  }
}