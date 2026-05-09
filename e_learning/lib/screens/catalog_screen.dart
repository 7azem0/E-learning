import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/enrollment_service.dart';
import 'course_detail_screen.dart';
import 'courses_screen.dart'; // For CourseModel

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Course Catalog"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allCourses = snapshot.data?.docs ?? [];
          if (allCourses.isEmpty) {
            return const Center(child: Text("No courses available in the catalog yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: allCourses.length,
            itemBuilder: (context, index) {
              final doc = allCourses[index];
              final data = doc.data() as Map<String, dynamic>;
              final color = Color(data['color'] ?? 0xFF6366F1);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_getIconFromName(data['icon']), color: color, size: 28),
                  ),
                  title: Text(
                    data['title'] ?? 'Course',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      data['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600, height: 1.3),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(
                          courseId: doc.id,
                          courseName: data['title'] ?? '',
                          courseColor: color,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIconFromName(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'code': return Icons.code;
      case 'data_usage': return Icons.data_usage;
      case 'analytics': return Icons.analytics;
      case 'storage': return Icons.storage;
      case 'computer': return Icons.computer;
      case 'cloud': return Icons.cloud;
      case 'auto_awesome': return Icons.auto_awesome;
      case 'smart_toy': return Icons.smart_toy;
      case 'security': return Icons.security;
      default: return Icons.school;
    }
  }
}
