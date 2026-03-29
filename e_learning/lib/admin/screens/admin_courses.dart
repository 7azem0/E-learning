import 'package:flutter/material.dart';
import '../../models/mock_data.dart';

class AdminCoursesScreen extends StatelessWidget {
  const AdminCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Global Courses', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.courses.length,
        itemBuilder: (context, index) {
          final course = MockData.courses[index];
          bool isPending = index % 2 != 0; 
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  course.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(width: 50, height: 50, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                ),
              ),
              title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('By ${course.instructorName}'),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPending ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isPending ? 'PENDING' : 'APPROVED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isPending ? Colors.orange : Colors.green,
                      ),
                    ),
                  )
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  if (isPending) const PopupMenuItem(value: 'approve', child: Text('Approve Course', style: TextStyle(color: Colors.green))),
                  const PopupMenuItem(value: 'hide', child: Text('Hide Course')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete Course', style: TextStyle(color: Colors.red))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
