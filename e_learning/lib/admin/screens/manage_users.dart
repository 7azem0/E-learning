import 'package:flutter/material.dart';
import '../../models/mock_data.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.users.length,
        itemBuilder: (context, index) {
          final user = MockData.users[index];
          String roleStr = user.role.toString().split('.').last.toUpperCase();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.imageUrl),
                backgroundColor: Colors.grey[300],
                child: user.imageUrl.isEmpty ? const Icon(Icons.person, color: Colors.grey) : null,
              ),
              title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRoleColor(roleStr).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      roleStr,
                      style: TextStyle(fontSize: 12, color: _getRoleColor(roleStr), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit Role')),
                  const PopupMenuItem(value: 'block', child: Text('Block User')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete User', style: TextStyle(color: Colors.red))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    if (role == 'ADMIN') return Colors.red;
    if (role == 'INSTRUCTOR') return Colors.purple;
    return Colors.blue;
  }
}
