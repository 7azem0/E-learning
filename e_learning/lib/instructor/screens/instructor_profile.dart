import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../../models/mock_data.dart';

class InstructorProfile extends StatelessWidget {
  const InstructorProfile({super.key});

  @override
  Widget build(BuildContext context) {

    final User? user = MockData.users.firstWhereOrNull((u) => u.name.contains('Yasmine Ali'));

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No user found.', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple,
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
                    child: user.imageUrl.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.purple,
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
            _buildProfileMenuItem(Icons.payment, 'Payout Settings', context),
            _buildProfileMenuItem(Icons.bar_chart, 'Analytics', context),
            _buildProfileMenuItem(Icons.settings, 'Account Settings', context),
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
