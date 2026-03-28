import 'package:flutter/material.dart';
import '../../models/mock_data.dart';
import 'course_details.dart';

class MyLearningScreen extends StatelessWidget {
  const MyLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Filter courses that have progress (simulating enrolled courses)
    final enrolledCourses = MockData.courses.take(2).toList(); // Simulate 2 enrolled courses

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Learning', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are enrolled in ${enrolledCourses.length} courses.', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: enrolledCourses.length,
                itemBuilder: (context, index) {
                  final course = enrolledCourses[index];
                  // Simulated progress
                  final progress = (index == 0) ? 0.45 : 0.80;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          course.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.image)),
                        ),
                      ),
                      title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(course.instructorName),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(height: 4),
                          Text('${(progress * 100).toInt()}% Complete', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CourseDetailsScreen(course: course)),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
