import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'dart:async';

// Impor model dan service
import '../models/destination.dart';
import '../models/category.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../main.dart'; // Untuk konstanta rute
import '../utils/toast_utils.dart';
import 'destination_detail_screen.dart';
import 'profile_screen.dart';

class SkeletonWidget extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonWidget> createState() => _SkeletonWidgetState();
}

class _SkeletonWidgetState extends State<SkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final User? user;

  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- State UI ---
  int _selectedIndex = 0;
  bool _isPageInitialized = false;

  // --- State Lokasi ---
  String _currentCity = '';
  String _currentAdminArea = '';
  bool _isLocationLoading = true;
  String? _locationError;
  final loc.Location _locationPlugin = loc.Location();

  // --- State Pengguna ---
  User? _currentUser;

  // --- Instance Service ---
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  // --- State Data dari API ---
  List<AppCategory> _fetchedCategories = [];
  bool _areCategoriesLoading = true;
  String? _categoriesError;

  List<Destination> _fetchedFeaturedDestinations = [];
  List<Destination> _fetchedPopularDestinations = [];
  bool _areDestinationsLoading = true;
  String? _destinationsError;

  final NumberFormat idrFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  // List widget untuk IndexedStack
  // List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _initializePageData();
  }

  /// Main method to orchestrate the page initialization.
  Future<void> _initializePageData() async {
    // Langkah 1: Pastikan data pengguna dimuat terlebih dahulu. Ini adalah prasyarat.
    await _ensureUserIsLoaded();
    if (!mounted) return;

    // Jika pengguna gagal dimuat, hentikan proses.
    if (_currentUser == null) {
      // _ensureUserIsLoaded sudah menangani logout, jadi kita cukup keluar dari fungsi.
      return;
    }

    // Langkah 2: Setelah user ada, tandai halaman sudah siap & mulai fetch data lain.
    // Ini akan menghilangkan skeleton screen utama dan menampilkan UI Home.
    if (mounted) {
      setState(() {
        _isPageInitialized = true;
      });
    }

    // Langkah 3: Ambil semua data lain secara paralel untuk efisiensi.
    _fetchCategories();
    _fetchDestinations();
    _getCurrentLocationAndAddress();
  }

  /// Checks for user data from widget arguments, fetches if null.
  Future<void> _ensureUserIsLoaded() async {
    if (widget.user != null) {
      _currentUser = widget.user;
      return;
    }

    try {
      final profileResult = await _authService.getUserProfile();
      if (mounted) {
        if (profileResult['success'] == true && profileResult['user'] != null) {
          setState(() {
            _currentUser = profileResult['user'] as User;
          });
        } else {
          throw Exception(profileResult['message'] ?? 'Failed to fetch profile');
        }
      }
    } catch (e) {
      if (kDebugMode) print("HomeScreen: Failed to fetch profile, logging out. Error: $e");
      if (mounted) {
        await _authService.logout();
        Navigator.pushReplacementNamed(context, loginRoute);
      }
    }
  }

  /// Sets up the widgets for the IndexedStack and marks the page as initialized.
  // void _initializeWidgetOptions(User userForProfile) {
  //   _widgetOptions = <Widget>[
  //     _buildHomeContent(),
  //     const Center(child: Text('Wishlist Screen (TODO)')),
  //     const Center(child: Text('Bookings Screen (TODO)')),
  //     const Center(child: Text('Chat Screen (TODO)')),
  //     ProfileScreen(user: userForProfile),
  //   ];
  //   if (mounted) setState(() => _isPageInitialized = true);
  // }

  /// Fetches categories from the API using the updated ApiService.
  Future<void> _fetchCategories() async {
    if (!mounted) return;
    setState(() { _areCategoriesLoading = true; _categoriesError = null; });
    try {
      final categories = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _fetchedCategories = categories;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categoriesError = e.toString();
        });
      }
    } finally {
      // Tandai loading selesai setelah proses berakhir.
      if(mounted) setState(() => _areCategoriesLoading = false);
    }
  }

  /// Fetches destinations from the API using the updated ApiService.
  Future<void> _fetchDestinations() async {
    if (!mounted) return;
    setState(() { _areDestinationsLoading = true; _destinationsError = null; });
    try {
      final allDestinations = await _apiService.getDestinations();
      if (mounted) {
        setState(() {
          _fetchedFeaturedDestinations = allDestinations.take(5).toList();
          _fetchedPopularDestinations = allDestinations.skip(5).take(5).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _destinationsError = e.toString();
        });
      }
    } finally {
      if(mounted) setState(() => _areDestinationsLoading = false);
    }
  }

  Future<void> _getCurrentLocationAndAddress() async {
    if (!mounted) return;
    if (kDebugMode) print("DEBUG _getCurrentLocation: START");

    if (mounted) {
      setState(() {
        _isLocationLoading = true;
        _locationError = null;
        _currentCity = 'Getting Location...';
        _currentAdminArea = '';
      });
    }

    const Duration locationTimeoutDuration = Duration(seconds: 20);

    try {
      bool serviceEnabled = await _locationPlugin.serviceEnabled().timeout(
          locationTimeoutDuration, onTimeout: () => throw TimeoutException('Checking service timed out.'));
      if (!serviceEnabled) {
        serviceEnabled = await _locationPlugin.requestService().timeout(
            locationTimeoutDuration, onTimeout: () => throw TimeoutException('Requesting service timed out.'));
        if (!serviceEnabled) {
          if (mounted) setState(() { _locationError = 'Location services are disabled.'; _currentCity = 'Location Off'; _isLocationLoading = false; });
          return;
        }
      }

      loc.PermissionStatus permissionGranted = await _locationPlugin.hasPermission().timeout(
          locationTimeoutDuration, onTimeout: () => throw TimeoutException('Checking permission timed out.'));
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _locationPlugin.requestPermission().timeout(
            locationTimeoutDuration, onTimeout: () => throw TimeoutException('Requesting permission timed out.'));
      }

      if (permissionGranted != loc.PermissionStatus.granted && permissionGranted != loc.PermissionStatus.grantedLimited) {
        if (mounted) {
          setState(() {
          _locationError = permissionGranted == loc.PermissionStatus.deniedForever
              ? 'Location permission permanently denied. Enable in settings.'
              : 'Location permission not granted.';
          _currentCity = permissionGranted == loc.PermissionStatus.deniedForever ? 'Permission Blocked' : 'Permission Error';
          _isLocationLoading = false;
        });
        }
        return;
      }

      loc.LocationData locationData = await _locationPlugin.getLocation().timeout(
          locationTimeoutDuration, onTimeout: () => throw TimeoutException('Getting location data timed out.'));

      if (locationData.latitude != null && locationData.longitude != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            locationData.latitude!, locationData.longitude!)
            .timeout(locationTimeoutDuration, onTimeout: () => throw TimeoutException('Geocoding timed out.'));

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          if (mounted) {
            setState(() {
            _currentCity = place.locality ?? place.subAdministrativeArea ?? 'Unknown City';
            _currentAdminArea = place.administrativeArea ?? '';
            _isLocationLoading = false; _locationError = null;
          });
          }
        } else {
          if (mounted) setState(() { _currentCity = 'Name Not Found'; _isLocationLoading = false; _locationError = 'Could not determine location name.'; });
        }
      } else {
        if (mounted) setState(() { _currentCity = 'Coords Not Found'; _isLocationLoading = false; _locationError = 'Could not get precise coordinates.'; });
      }
    } on TimeoutException catch (e) {
      if (kDebugMode) print("DEBUG _getCurrentLocation: Timeout: ${e.message}");
      if (mounted) setState(() { _locationError = e.message ?? 'Operation timed out.'; _currentCity = 'Timeout'; _isLocationLoading = false; });
    } catch (e, s) {
      if (kDebugMode) { print("DEBUG _getCurrentLocation: Error: $e\nStackTrace: $s"); }
      if (mounted) setState(() { _locationError = 'Failed to get location.'; _currentCity = 'Error'; _isLocationLoading = false; });
    }
    if (kDebugMode) print("DEBUG _getCurrentLocation: END. Loading: $_isLocationLoading, City: $_currentCity, Error: $_locationError");
  }



  void _onItemTapped(int index) {
    if (index == 4 && _currentUser == null && _isPageInitialized) {
      if (kDebugMode) print("HomeScreen _onItemTapped: Profile tab tapped but _currentUser is null. Attempting to re-initialize.");
      _initializePageData();
      ToastUtils.showInfoToast("Loading user data...");
      return;
    }
    setState(() { _selectedIndex = index; });
    if (kDebugMode) print("HomeScreen _onItemTapped: Tab $index tapped. User: ${_currentUser?.name}");
  }

  // --- Widget Building Methods (No changes needed below this line) ---

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _initializePageData,
      child: ListView(
        children: <Widget>[
          _buildLocationHeader(),
          const SizedBox(height: 16),
          _buildSearchBar(),
          _buildCategoryIcons(),
          _buildSectionHeader('Featured Deals', () {
            if (kDebugMode) print('See All Featured Deals tapped');
          }),
          _buildFeaturedDestinationsList(),
          _buildSectionHeader('Popular', () {
            if (kDebugMode) print('See All Popular Destination tapped');
          }),
          _buildPopularDestinationsList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    String welcomeText = 'Location';
    if (_currentUser != null) {
      String firstName = _currentUser!.name.split(' ').first;
      welcomeText = 'Hello, $firstName!';
    }

    Widget locationDisplayContent;

    if (_isLocationLoading) {
      locationDisplayContent = const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonWidget(
              width: 16,
              height: 16,
              borderRadius: BorderRadius.all(Radius.circular(8))
          ),
          SizedBox(width: 8),
          SkeletonWidget(
              width: 120,
              height: 16,
              borderRadius: BorderRadius.all(Radius.circular(4))
          ),
        ],
      );
    } else if (_locationError != null) {
      locationDisplayContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 4),
          Expanded(child: Text(_locationError!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red.shade700), overflow: TextOverflow.ellipsis, maxLines: 1)),
        ],
      );
    } else {
      String displayLocationText = _currentCity;
      if (_currentAdminArea.isNotEmpty && _currentCity.toLowerCase() != _currentAdminArea.toLowerCase() && !_currentCity.toLowerCase().contains(_currentAdminArea.toLowerCase())) {
        displayLocationText += ', $_currentAdminArea';
      }
      locationDisplayContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, color: Color(0xFF446DFF), size: 20),
          const SizedBox(width: 4),
          Expanded(child: Text(displayLocationText.isEmpty ? "Unknown Location" : displayLocationText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87), overflow: TextOverflow.ellipsis, maxLines: 1)),
          const Icon(Icons.arrow_drop_down, color: Colors.black54, size: 20),
        ],
      );
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
                Text(welcomeText, style: TextStyle(fontSize: _currentUser != null ? 18 : 12, fontWeight: _currentUser != null ? FontWeight.bold : FontWeight.normal, color: _currentUser != null ? Colors.black87 : Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                GestureDetector(onTap: _isLocationLoading ? null : _getCurrentLocationAndAddress, child: Container(padding: const EdgeInsets.symmetric(vertical: 4.0), child: locationDisplayContent)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300, width: 1)),
            child: IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.black54), onPressed: () { if (kDebugMode) print('Notification button tapped'); }),
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
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(30)),
              child: const TextField(decoration: InputDecoration(hintText: 'Search destination...', hintStyle: TextStyle(fontSize: 14, color: Color(0xFFC5C5C5)), prefixIcon: Icon(Icons.search, color: Color(0xFFC5C5C5), size: 30,), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12))),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: const BoxDecoration(color: Color(0xFF446DFF), shape: BoxShape.circle),
            child: IconButton(icon: const Icon(Icons.filter_list, color: Colors.white), onPressed: () { if (kDebugMode) print('Filter button tapped'); }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcons() {
    if (_areCategoriesLoading) {
      return SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: 5, // Tampilkan 5 skeleton
          itemBuilder: (context, index) {
            return Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SkeletonWidget(
                    width: 60,
                    height: 60,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 40,
                    alignment: Alignment.topCenter,
                    child: const Column(
                      children: [
                        SkeletonWidget(
                            width: 50,
                            height: 12,
                            borderRadius: BorderRadius.all(Radius.circular(4))
                        ),
                        SizedBox(height: 4),
                        SkeletonWidget(
                            width: 35,
                            height: 12,
                            borderRadius: BorderRadius.all(Radius.circular(4))
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    if (_categoriesError != null) return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_categoriesError!)));
    if (_fetchedCategories.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('No categories found.')));

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _fetchedCategories.length,
        itemBuilder: (context, index) {
          final category = _fetchedCategories[index];
          Widget iconWidget;
          if (category.publicIconUrl.isNotEmpty && category.publicIconUrl.startsWith('http')) {
            iconWidget = ClipOval(child: Image.network(category.publicIconUrl, width: 28, height: 28, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(category.displayIcon, color: const Color(0xFF446DFF), size: 28)));
          } else {
            iconWidget = Icon(category.displayIcon, color: const Color(0xFF446DFF), size: 28);
          }

          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, categoryListRoute, arguments: category),
            child: Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(color: Color(0xFFF1F7FD), shape: BoxShape.circle),
                    child: iconWidget,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 40,
                    alignment: Alignment.topCenter,
                    child: Text(
                      category.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAllPressed) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 12.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          TextButton(
            onPressed: onSeeAllPressed,
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF446DFF)),
            child: const Text('See all'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedDestinationsList() {
    if (_areDestinationsLoading && _fetchedFeaturedDestinations.isEmpty) {
      return SizedBox(
        height: 280,
        child: ListView.builder(
          padding: const EdgeInsets.only(left: 24.0, top: 8, bottom: 8),
          scrollDirection: Axis.horizontal,
          itemCount: 3, // Tampilkan 3 skeleton cards
          itemBuilder: (context, index) {
            return Container(
              width: 300,
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
                  )
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SkeletonWidget(
                    width: double.infinity,
                    height: 160,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonWidget(
                            width: 180,
                            height: 16,
                            borderRadius: BorderRadius.all(Radius.circular(4))
                        ),
                        SizedBox(height: 8),
                        SkeletonWidget(
                            width: 120,
                            height: 12,
                            borderRadius: BorderRadius.all(Radius.circular(4))
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SkeletonWidget(
                                width: 80,
                                height: 16,
                                borderRadius: BorderRadius.all(Radius.circular(4))
                            ),
                            SkeletonWidget(
                                width: 40,
                                height: 12,
                                borderRadius: BorderRadius.all(Radius.circular(4))
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    if (_destinationsError != null && _fetchedFeaturedDestinations.isEmpty) {
      return SizedBox(height: 280, child: Center(child: Text(_destinationsError!, style: const TextStyle(color: Colors.red))));
    }
    if (_fetchedFeaturedDestinations.isEmpty) {
      return const SizedBox(height: 280, child: Center(child: Text('No featured destinations.')));
    }
    return SizedBox(
      height: 280,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 24.0, top: 8, bottom: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _fetchedFeaturedDestinations.length,
        itemBuilder: (context, index) {
          return _buildDestinationCard(_fetchedFeaturedDestinations[index]);
        },
      ),
    );
  }

  Widget _buildPopularDestinationsList() {
    if (_areDestinationsLoading && _fetchedPopularDestinations.isEmpty) {
      return SizedBox(
        height: 150,
        child: ListView.builder(
          padding: const EdgeInsets.only(left: 24.0, top: 8, bottom: 16),
          scrollDirection: Axis.horizontal,
          itemCount: 3, // Tampilkan 3 skeleton tiles
          itemBuilder: (context, index) {
            return Container(
              width: 300,
              height: 150,
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
                  )
                ],
              ),
              child: const Row(
                children: <Widget>[
                  SkeletonWidget(
                    width: 110,
                    height: 150,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SkeletonWidget(
                              width: 140,
                              height: 14,
                              borderRadius: BorderRadius.all(Radius.circular(4))
                          ),
                          SizedBox(height: 4),
                          SkeletonWidget(
                              width: 100,
                              height: 14,
                              borderRadius: BorderRadius.all(Radius.circular(4))
                          ),
                          SizedBox(height: 8),
                          SkeletonWidget(
                              width: 80,
                              height: 12,
                              borderRadius: BorderRadius.all(Radius.circular(4))
                          ),
                          Spacer(),
                          SkeletonWidget(
                              width: 90,
                              height: 16,
                              borderRadius: BorderRadius.all(Radius.circular(4))
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    if (_destinationsError != null && _fetchedPopularDestinations.isEmpty) {
      return SizedBox(height: 130, child: Center(child: Text(_destinationsError!, style: const TextStyle(color: Colors.red))));
    }
    if (_fetchedPopularDestinations.isEmpty) {
      return const SizedBox(height: 130, child: Center(child: Text('No popular destinations.')));
    }
    return SizedBox(
      height: 150,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 24.0, top: 8, bottom: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _fetchedPopularDestinations.length,
        itemBuilder: (context, index) {
          return _buildPopularDestinationTile(_fetchedPopularDestinations[index]);
        },
      ),
    );
  }

  Widget _buildDestinationCard(Destination destination) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail dengan mengirim objek destinasi
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DestinationDetailScreen(destination: destination),
          ),
        );
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3)) ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: Image.network(
                    destination.mainImageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(height: 160, width: 300, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)),
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
                      onTap: () { setState(() { destination.isFavorite = !destination.isFavorite; }); },
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
                  Text(destination.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF446DFF), size: 14),
                      const SizedBox(width: 4),
                      Expanded(child: Text(destination.locationAddress ?? 'Unknown Location', style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(idrFormatter.format(destination.ticketPrice), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF446DFF))),
                          Padding(padding: const EdgeInsets.only(left: 2.0), child: Text('/night', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey.shade600))),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(destination.averageRating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54)),
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

  Widget _buildPopularDestinationTile(Destination destination) {
    return GestureDetector(
      onTap: () {
        if (kDebugMode) print('Tapped on Popular: ${destination.name}');
      },
      child: Container(
        width: 300,
        height: 150,
        margin: const EdgeInsets.only(right: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2)) ],
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              child: Image.network(
                destination.mainImageUrl,
                width: 110,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(width: 110, height: 150, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(destination.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(destination.averageRating.toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black54)),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on, color: Color(0xFF446DFF), size: 14),
                        const SizedBox(width: 2),
                        Expanded(child: Text(destination.locationAddress ?? 'Unknown', style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(idrFormatter.format(destination.ticketPrice), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF446DFF))),
                        Padding(padding: const EdgeInsets.only(left: 2.0), child: Text('/night', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey.shade600))),
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
    if (!_isPageInitialized || _currentUser == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Skeleton untuk location header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonWidget(
                              width: 120,
                              height: 18,
                              borderRadius: BorderRadius.all(Radius.circular(4))
                          ),
                          SizedBox(height: 8),
                          SkeletonWidget(
                              width: 150,
                              height: 14,
                              borderRadius: BorderRadius.all(Radius.circular(4))
                          ),
                        ],
                      ),
                      SkeletonWidget(
                        width: 48,
                        height: 48,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ],
                  ),
                ),
                // Skeleton untuk search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: SkeletonWidget(
                            height: 48,
                            width: double.infinity,
                            borderRadius: BorderRadius.all(Radius.circular(24))
                        ),
                      ),
                      const SizedBox(width: 16),
                      SkeletonWidget(
                        width: 48,
                        height: 48,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Skeleton untuk categories
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SkeletonWidget(
                              width: 60,
                              height: 60,
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                            SizedBox(height: 8),
                            SkeletonWidget(
                                width: 50,
                                height: 12,
                                borderRadius: BorderRadius.all(Radius.circular(4))
                            ),
                            SizedBox(height: 4),
                            SkeletonWidget(
                                width: 35,
                                height: 12,
                                borderRadius: BorderRadius.all(Radius.circular(4))
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Skeleton untuk section header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonWidget(
                          width: 120,
                          height: 20,
                          borderRadius: BorderRadius.all(Radius.circular(4))
                      ),
                      SkeletonWidget(
                          width: 60,
                          height: 16,
                          borderRadius: BorderRadius.all(Radius.circular(4))
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Skeleton untuk featured destinations
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 24.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 300,
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
                            )
                          ],
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonWidget(
                              width: double.infinity,
                              height: 160,
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SkeletonWidget(
                                      width: 180,
                                      height: 16,
                                      borderRadius: BorderRadius.all(Radius.circular(4))
                                  ),
                                  SizedBox(height: 8),
                                  SkeletonWidget(
                                      width: 120,
                                      height: 12,
                                      borderRadius: BorderRadius.all(Radius.circular(4))
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SkeletonWidget(
                                          width: 80,
                                          height: 16,
                                          borderRadius: BorderRadius.all(Radius.circular(4))
                                      ),
                                      SkeletonWidget(
                                          width: 40,
                                          height: 12,
                                          borderRadius: BorderRadius.all(Radius.circular(4))
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // <-- PERUBAHAN KRUSIAL: Definisikan widget options di dalam build method -->
    // Ini memastikan widget dibuat ulang dengan state terbaru setiap kali setState dipanggil.
    final List<Widget> widgetOptions = <Widget>[
      _buildHomeContent(),
      const Center(child: Text('Wishlist Screen (TODO)')),
      const Center(child: Text('Bookings Screen (TODO)')),
      const Center(child: Text('Chat Screen (TODO)')),
      ProfileScreen(user: _currentUser!), // Pastikan user tidak null
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex == 4
          ? AppBar(
        title: const Text('Profil Saya', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading: false,
      )
          : null,
      body: SafeArea(
        top: _selectedIndex != 4,
        child: IndexedStack(
          index: _selectedIndex,
          children: widgetOptions,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
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