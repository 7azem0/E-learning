import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../../models/mock_data.dart';

class AdminProfile extends StatelessWidget {
  const AdminProfile({super.key});

  @override
  Widget build(BuildContext context) {
    // Admin mock
    final User? user = MockData.users.firstWhereOrNull((u) => u.name.contains('Mostafa Kamal'));

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No user found.', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.red[100],
                child: const Icon(Icons.admin_panel_settings, size: 50, color: Colors.redAccent),
              ),
            ),
            const SizedBox(height: 16),
            Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(user.email, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 30),
            _buildProfileMenuItem(Icons.security, 'Platform Settings', context),
            _buildProfileMenuItem(Icons.backup, 'Database Backups', context),
            _buildProfileMenuItem(Icons.payment, 'Payment Gateways', context),
            _buildProfileMenuItem(Icons.email, 'Email Templates', context),
            const Divider(),
            _buildProfileMenuItem(Icons.logout, 'Logout', context, isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(IconData icon, String title, BuildContext context, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.grey[800]),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : Colors.black87, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        if (isLogout) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
    );
  }
}
