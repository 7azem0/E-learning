import 'package:flutter/material.dart';

class InstructorHome extends StatelessWidget {
  const InstructorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back, Jane!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Here is an overview of your instructor statistics.', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Students', '2,090', Icons.people, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Course Rating', '4.8', Icons.star, Colors.orange)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Revenue', '\$12,450', Icons.attach_money, Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Active Courses', '2', Icons.video_library, Colors.purple)),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person_add, color: Colors.white)),
                  title: Text('Fahd Sal enrolled in Flutter for Beginners'),
                  subtitle: Text('2 hours ago'),
                ),
                ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.star, color: Colors.white)),
                  title: Text('Fahd left a 5-star review'),
                  subtitle: Text('5 hours ago'),
                ),
                ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.monetization_on, color: Colors.white)),
                  title: Text('Course purchase - Advanced UI/UX'),
                  subtitle: Text('1 day ago'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
