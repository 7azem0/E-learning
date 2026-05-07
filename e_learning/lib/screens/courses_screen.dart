// ignore_for_file: deprecated_member_use

import 'package:e_learning/screens/course_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/enrollment_service.dart';
import '../widgets/menu.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Courses",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      drawer: const Menu(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('courses')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No courses available yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            final courses = snapshot.data!.docs;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final courseDoc = courses[index];
                final course = CourseModel.fromFirestore(courseDoc);
                return ModernCourseCard(
                  course: course,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(
                          courseId: course.id,
                          courseName: course.name,
                          courseColor: course.color,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CourseModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final DateTime? createdAt;

  const CourseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.createdAt,
  });

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Map icon names to IconData
    final iconName = data['icon'] as String?;
    final icon = _getIconFromName(iconName);

    // Map color hex to Color
    final colorHex = data['color'] as int? ?? 0xFF334155;

    return CourseModel(
      id: doc.id,
      name: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: icon,
      color: Color(colorHex),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  static IconData _getIconFromName(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'code':
        return Icons.code;
      case 'data_usage':
        return Icons.data_usage;
      case 'analytics':
        return Icons.analytics;
      case 'storage':
        return Icons.storage;
      case 'computer':
        return Icons.computer;
      case 'cloud':
        return Icons.cloud;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'smart_toy':
        return Icons.smart_toy;
      case 'security':
        return Icons.security;
      default:
        return Icons.school;
    }
  }
}

class ModernCourseCard extends StatefulWidget {
  final CourseModel course;
  final VoidCallback onTap;

  const ModernCourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  State<ModernCourseCard> createState() => _ModernCourseCardState();
}

class _ModernCourseCardState extends State<ModernCourseCard> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: EnrollmentService().isEnrolled(widget.course.id),
      builder: (context, snapshot) {
        final enrolled = snapshot.data ?? false;
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFF1F1EF),
                    child: Icon(widget.course.icon, color: Colors.black87),
                  ),
                  const Spacer(),
                  Text(
                    widget.course.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    enrolled ? 'Enrolled' : 'Not enrolled',
                    style: TextStyle(
                      color: enrolled ? Colors.black : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
