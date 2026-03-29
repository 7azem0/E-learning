import 'package:flutter/material.dart';
import '../../models/mock_data.dart';
import 'create_course.dart';

class ManageCoursesScreen extends StatelessWidget {
  const ManageCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myCourses = MockData.courses.where((c) => c.instructorName == 'Jane Smith').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: myCourses.isEmpty
          ? const Center(child: Text('You have not created any courses yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myCourses.length,
              itemBuilder: (context, index) {
                final course = myCourses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        course.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, err, stack) => Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.video_file)),
                      ),
                    ),
                    title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('\$${course.price} | ${course.studentsEnrolled} Students'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                              label: const Text('Edit', style: TextStyle(color: Colors.blue)),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                              label: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateCourseScreen()));
        },
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Course', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
