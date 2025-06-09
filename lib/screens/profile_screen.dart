// File: lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk kDebugMode
import '../models/user.dart'; // Pastikan path ini benar
import '../services/auth_service.dart'; // Untuk logout
import '../main.dart'; // Untuk konstanta rute loginRoute
import '../utils/toast_utils.dart'; // Untuk pesan toast

class ProfileScreen extends StatefulWidget {
  final User user; // Menerima data pengguna

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;

  Future<void> _performLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    final result = await _authService.logout();

    if (mounted) {
      setState(() {
        _isLoggingOut = false;
      });

      if (result['success'] == true) {
        ToastUtils.showSuccessToast(result['message'] ?? 'Logged out successfully.');
        // Navigasi ke LoginScreen dan hapus semua rute sebelumnya
        Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (Route<dynamic> route) => false);
      } else {
        ToastUtils.showErrorToast(result['message'] ?? 'Logout failed. Please try again.');
        // Tetap di halaman profil jika logout server gagal, namun token lokal sudah dihapus oleh AuthService.
        // Atau bisa juga paksa ke login screen. Untuk UX lebih baik, mungkin paksa ke login.
        Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (Route<dynamic> route) => false);
      }
    }
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: _isLoggingOut ? null : () {
                Navigator.of(context).pop(); // Tutup dialog
                _performLogout();
              },
              child: _isLoggingOut
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2,))
                  : const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor, size: 26),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Latar belakang sedikit berbeda
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        // Tombol kembali akan otomatis ada karena kita push screen ini
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: <Widget>[
            // Bagian Header Profil
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Text(
                widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : 'U',
                style: TextStyle(fontSize: 40, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.user.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              widget.user.email,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Daftar Opsi Profil
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ]
              ),
              child: Column(
                children: [
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: 'Edit Profil',
                    onTap: () {
                      if (kDebugMode) print('Edit Profile tapped');
                      // TODO: Navigasi ke halaman edit profil
                    },
                  ),
                  const Divider(height: 0, indent: 16, endIndent: 16),
                  _buildProfileOption(
                    icon: Icons.lock_outline,
                    title: 'Ganti Password',
                    onTap: () {
                      if (kDebugMode) print('Change Password tapped');
                      // TODO: Navigasi ke halaman ganti password
                    },
                  ),
                  const Divider(height: 0, indent: 16, endIndent: 16),
                  _buildProfileOption(
                    icon: Icons.history_outlined,
                    title: 'Histori Booking',
                    onTap: () {
                      if (kDebugMode) print('Booking History tapped');
                      // TODO: Navigasi ke halaman histori booking
                    },
                  ),
                  const Divider(height: 0, indent: 16, endIndent: 16),
                  _buildProfileOption(
                    icon: Icons.notifications_none_outlined,
                    title: 'Pengaturan Notifikasi',
                    onTap: () {
                      if (kDebugMode) print('Notification Settings tapped');
                      // TODO: Navigasi ke halaman pengaturan notifikasi
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isLoggingOut
                      ? Container() // Tidak ada ikon saat loading
                      : const Icon(Icons.logout, color: Colors.redAccent),
                  label: _isLoggingOut
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.redAccent,))
                      : const Text('Logout', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                  onPressed: _isLoggingOut ? null : _showLogoutConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.redAccent, // Warna ripple
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.redAccent.withOpacity(0.5))
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'TravelEase App v1.0.0', // Contoh versi aplikasi
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}