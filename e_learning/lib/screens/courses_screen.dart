// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../widgets/menu.dart';
import './sessions_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  final List<CourseModel> courses = const [
    CourseModel(
      name: "Programming",
      icon: Icons.code,
      color: Color(0xFF6366F1),
    ),
    CourseModel(
      name: "Data Structures",
      icon: Icons.data_usage,
      color: Color(0xFF8B5CF6),
    ),
    CourseModel(
      name: "Algorithms",
      icon: Icons.analytics,
      color: Color(0xFF06B6D4),
    ),
    CourseModel(
      name: "Database Systems",
      icon: Icons.storage,
      color: Color(0xFF10B981),
    ),
    CourseModel(
      name: "Operating Systems",
      icon: Icons.computer,
      color: Color(0xFFF59E0B),
    ),
    CourseModel(
      name: "Computer Networks",
      icon: Icons.cloud,
      color: Color(0xFFEC4899),
    ),
    CourseModel(
      name: "Artificial Intelligence",
      icon: Icons.auto_awesome,
      color: Color(0xFF3B82F6),
    ),
    CourseModel(
      name: "Machine Learning",
      icon: Icons.smart_toy,
      color: Color(0xFF14B8A6),
    ),
    CourseModel(
      name: "Cybersecurity",
      icon: Icons.security,
      color: Color(0xFFEF4444),
    ),
  ];

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
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return ModernCourseCard(
              course: course,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SessionsScreen(courseName: course.name),
                  ),
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
  final String name;
  final IconData icon;
  final Color color;

  const CourseModel({
    required this.name,
    required this.icon,
    required this.color,
  });
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