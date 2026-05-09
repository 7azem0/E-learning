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
          "My Courses",
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
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: EnrollmentService().streamEnrolledCourses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final courses = snapshot.data ?? [];
            if (courses.isEmpty) {
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
                      'You haven\'t enrolled in any courses yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // We need a way to browse all courses. 
                        // I'll show a simple dialog for now or just print.
                        _showBrowseCourses(context);
                      },
                      child: const Text("Browse Course Catalog"),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final courseData = courses[index];
                // Manually construct CourseModel from map
                final course = CourseModel(
                  id: courseData['id'],
                  name: courseData['title'] ?? '',
                  description: courseData['description'] ?? '',
                  icon: CourseModel._getIconFromName(courseData['icon']),
                  color: Color(courseData['color'] ?? 0xFF334155),
                );
                
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBrowseCourses(context),
        tooltip: 'Enroll in new courses',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBrowseCourses(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Course Catalog",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('courses').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final allCourses = snapshot.data!.docs;
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: allCourses.length,
                    itemBuilder: (context, index) {
                      final doc = allCourses[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final color = Color(data['color'] ?? 0xFF334155);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.1),
                          child: Icon(CourseModel._getIconFromName(data['icon']), color: color),
                        ),
                        title: Text(data['title'] ?? 'Course'),
                        subtitle: Text(data['description'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(context);
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
                      );
                    },
                  );
                }
              ),
            ),
          ],
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
