// ignore_for_file: deprecated_member_use

import 'package:e_learning/screens/course_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/menu.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("All Courses", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
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
                    Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade400),
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
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
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
    final colorHex = data['color'] as int? ?? 0xFF6366F1;
    
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
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.course.color.withOpacity(0.8),
                widget.course.color.withOpacity(0.5),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.course.color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Pattern
              Positioned(
                right: -30,
                bottom: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.course.icon,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),

                    // Course Name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.course.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Tap to explore",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}