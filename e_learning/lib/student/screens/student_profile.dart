import 'package:flutter/material.dart';
import '../../models/mock_data.dart';

class StudentProfile extends StatelessWidget {
  const StudentProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.users[0]; // Student mock

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.imageUrl),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(user.email, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 30),
            _buildProfileMenuItem(Icons.person_outline, 'Edit Profile', context),
            _buildProfileMenuItem(Icons.settings, 'Settings', context),
            _buildProfileMenuItem(Icons.payment, 'Payment Methods', context),
            _buildProfileMenuItem(Icons.help_outline, 'Help & Support', context),
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
