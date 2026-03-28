import 'package:flutter/material.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Platform Statistics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard('Total Users', '12,045', Icons.group),
                _buildStatCard('Active Courses', '840', Icons.library_books),
                _buildStatCard('Total Revenue', '\$124,500', Icons.attach_money),
                _buildStatCard('Pending Approvals', '12', Icons.pending_actions),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Recent System Alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildAlertTile('High volume of registrations detected.', Colors.orange, Icons.warning_amber),
            _buildAlertTile('System maintenance scheduled for tonight.', Colors.blue, Icons.info_outline),
            _buildAlertTile('Database backup successful.', Colors.green, Icons.check_circle_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTile(String message, Color color, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(message),
      ),
    );
  }
}
