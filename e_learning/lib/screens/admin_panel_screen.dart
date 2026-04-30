// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_service.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Panel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: AdminService().getCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final courses = snapshot.data?.docs ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Add Course Button with modern design
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showCourseDialog(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Add New Course',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showQuizDialog(context, courses: courses),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Create Quiz',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  ),
                ),
                
              ),
               const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showCourseDialog(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Broadcast an Announcement',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  ),
                ),
                
              ),
              const SizedBox(height: 24),

              // Courses Section
              Text(
                'Manage Courses',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (courses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.school_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No courses yet',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...courses.map((course) => _CourseCard(course: course)),
              const SizedBox(height: 24),
              Text(
                'Manage Quizzes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: AdminService().getQuizzes(),
                builder: (context, quizSnapshot) {
                  if (quizSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final quizzes = quizSnapshot.data?.docs ?? [];
                  if (quizzes.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No quizzes yet',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: quizzes.map((quiz) {
                      final quizData = quiz.data() as Map<String, dynamic>;
                      String courseTitle = 'Unassigned';
                      for (final course in courses) {
                        if (course.id == quizData['courseId']) {
                          courseTitle = course['title'] ?? 'Unassigned';
                          break;
                        }
                      }
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(quizData['title'] ?? ''),
                          subtitle: Text(courseTitle),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${quizData['questionCount'] ?? 10} Qs'),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Quiz'),
                                      content: const Text('Are you sure you want to delete this quiz and its questions?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    final result = await AdminService().deleteQuiz(quiz.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(result == 'Success' ? 'Quiz deleted' : 'Failed to delete quiz')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCourseDialog(BuildContext context, {DocumentSnapshot? course}) {
    final titleController = TextEditingController(text: course?['title'] ?? '');
    final descController = TextEditingController(text: course?['description'] ?? '');
    String? selectedIcon = course?['icon'] ?? 'school';
    int? selectedColor = course?['color'] ?? 0xFF6366F1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(course == null ? 'Create New Course' : 'Edit Course',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Course Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Text('Select Icon', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'school', 'code', 'data_usage', 'analytics', 'storage',
                    'computer', 'cloud', 'auto_awesome', 'smart_toy', 'security'
                  ].map((icon) {
                    final isSelected = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = icon),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? const Color(0xFF6366F1) : Colors.grey,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? const Color(0xFF6366F1).withOpacity(0.1) : Colors.transparent,
                        ),
                        child: Icon(_getIconFromName(icon), color: const Color(0xFF6366F1)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Select Color', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    0xFF6366F1, 0xFF8B5CF6, 0xFF06B6D4, 0xFF10B981,
                    0xFFF59E0B, 0xFFEC4899, 0xFF3B82F6, 0xFF14B8A6, 0xFFEF4444, 0xFF059669,
                  ].map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: isSelected ? 3 : 0,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a course title')),
                );
                return;
              }
              if (course == null) {
                await AdminService().createCourse(
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  icon: selectedIcon,
                  color: selectedColor,
                );
              } else {
                await AdminService().updateCourse(
                  courseId: course.id,
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  icon: selectedIcon,
                  color: selectedColor,
                );
              }
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            label: Text(course == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _showQuizDialog(BuildContext context, {List<QueryDocumentSnapshot>? courses}) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String? selectedCourseId = courses != null && courses.isNotEmpty ? courses.first.id : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Create New Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Quiz Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.quiz),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                const Text(
                  'A default set of 10 auto-graded MCQs will be created for this quiz.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                if (courses != null && courses.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Attach to Course', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedCourseId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: courses.map((course) => DropdownMenuItem(
                      value: course.id,
                      child: Text(course['title'] ?? 'Untitled Course'),
                    )).toList(),
                    onChanged: (value) => setState(() => selectedCourseId = value),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a quiz title')),
                );
                return;
              }
              final result = await AdminService().createQuiz(
                title: titleController.text.trim(),
                description: descController.text.trim(),
                courseId: selectedCourseId,
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result == 'Success' ? 'Quiz created successfully' : 'Failed to create quiz')),
                );
              }
            },
            icon: const Icon(Icons.check),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            label: const Text('Create'),
          ),
        ],
      ),
    );
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName.toLowerCase()) {
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

// ─── COURSE CARD ────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  final DocumentSnapshot course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final courseData = course.data() as Map<String, dynamic>;
    final colorHex = courseData['color'] as int? ?? 0xFF6366F1;
    final iconName = courseData['icon'] as String? ?? 'school';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(colorHex).withOpacity(0.8),
              Color(colorHex).withOpacity(0.5),
            ],
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            collapsedIconColor: Colors.white,
            iconColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getIconFromName(iconName), color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseData['title'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        courseData['description'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              color: Colors.white,
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Edit'),
                  onTap: () => Future.delayed(
                    Duration.zero,
                    () => _showCourseDialog(context, course: course),
                  ),
                ),
                PopupMenuItem(
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () => _confirmDelete(context, course),
                ),
              ],
            ),
            children: [_SectionList(courseId: course.id)],
          ),
        ),
      ),
    );
  }

  void _showCourseDialog(BuildContext context, {DocumentSnapshot? course}) {
    final titleController = TextEditingController(text: course?['title'] ?? '');
    final descController = TextEditingController(text: course?['description'] ?? '');
    String? selectedIcon = course?['icon'] ?? 'school';
    int? selectedColor = course?['color'] ?? 0xFF6366F1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(course == null ? 'Create New Course' : 'Edit Course',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Course Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Text('Select Icon', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'school', 'code', 'data_usage', 'analytics', 'storage',
                    'computer', 'cloud', 'auto_awesome', 'smart_toy', 'security'
                  ].map((icon) {
                    final isSelected = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = icon),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? const Color(0xFF6366F1) : Colors.grey,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? const Color(0xFF6366F1).withOpacity(0.1) : Colors.transparent,
                        ),
                        child: Icon(_getIconFromName(icon), color: const Color(0xFF6366F1)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Select Color', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    0xFF6366F1, 0xFF8B5CF6, 0xFF06B6D4, 0xFF10B981,
                    0xFFF59E0B, 0xFFEC4899, 0xFF3B82F6, 0xFF14B8A6, 0xFFEF4444, 0xFF059669,
                  ].map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: isSelected ? 3 : 0,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a course title')),
                );
                return;
              }
              if (course == null) {
                await AdminService().createCourse(
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  icon: selectedIcon,
                  color: selectedColor,
                );
              } else {
                await AdminService().updateCourse(
                  courseId: course.id,
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  icon: selectedIcon,
                  color: selectedColor,
                );
              }
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            label: Text(course == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, DocumentSnapshot course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Course', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${course['title']}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await AdminService().deleteCourse(course.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName.toLowerCase()) {
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

// ─── SECTION LIST ───────────────────────────────────────────────────────────

class _SectionList extends StatelessWidget {
  final String courseId;
  const _SectionList({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: AdminService().getSections(courseId),
      builder: (context, snapshot) {
        final sections = snapshot.data?.docs ?? [];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...sections.map((section) =>
                  _SectionCard(courseId: courseId, section: section)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    _showSectionDialog(context, order: sections.length),
                icon: const Icon(Icons.add, size: 18, color: Color(0xFF6366F1)),
                label: const Text('Add Section',
                    style: TextStyle(color: Color(0xFF6366F1))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6366F1)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSectionDialog(BuildContext context,
      {DocumentSnapshot? section, required int order}) {
    final titleController =
        TextEditingController(text: section?['title'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(section == null ? 'New Section' : 'Edit Section'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Section Title'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (section == null) {
                await AdminService().createSection(
                  courseId: courseId,
                  title: titleController.text.trim(),
                  order: order,
                );
              } else {
                await AdminService().updateSection(
                  courseId: courseId,
                  sectionId: section.id,
                  title: titleController.text.trim(),
                );
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1)),
            child: Text(section == null ? 'Create' : 'Save',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── SECTION CARD ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String courseId;
  final DocumentSnapshot section;
  const _SectionCard({required this.courseId, required this.section});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(section['title'],
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Color(0xFF6366F1)),
              onPressed: () => _showSectionDialog(context),
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 18, color: Colors.red.shade400),
              onPressed: () => _confirmDelete(
                context,
                label: section['title'],
                onConfirm: () =>
                    AdminService().deleteSection(courseId, section.id),
              ),
            ),
          ],
        ),
        children: [_LessonList(courseId: courseId, sectionId: section.id)],
      ),
    );
  }

  void _showSectionDialog(BuildContext context) {
    final titleController = TextEditingController(text: section['title']);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Section'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Section Title'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await AdminService().updateSection(
                courseId: courseId,
                sectionId: section.id,
                title: titleController.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1)),
            child:
                const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── LESSON LIST ────────────────────────────────────────────────────────────

class _LessonList extends StatelessWidget {
  final String courseId;
  final String sectionId;
  const _LessonList({required this.courseId, required this.sectionId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: AdminService().getLessons(courseId, sectionId),
      builder: (context, snapshot) {
        final lessons = snapshot.data?.docs ?? [];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              ...lessons.map((lesson) => _LessonCard(
                    courseId: courseId,
                    sectionId: sectionId,
                    lesson: lesson,
                  )),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    _showLessonDialog(context, order: lessons.length),
                icon: const Icon(Icons.add, size: 16, color: Color(0xFF6366F1)),
                label: const Text('Add Lesson',
                    style: TextStyle(
                        color: Color(0xFF6366F1), fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6366F1)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLessonDialog(BuildContext context, {required int order}) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('New Lesson'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Lesson Title')),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await AdminService().createLesson(
                courseId: courseId,
                sectionId: sectionId,
                title: titleController.text.trim(),
                description: descController.text.trim(),
                order: order,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1)),
            child: const Text('Create',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── LESSON CARD ────────────────────────────────────────────────────────────

class _LessonCard extends StatefulWidget {
  final String courseId;
  final String sectionId;
  final DocumentSnapshot lesson;
  const _LessonCard(
      {required this.courseId,
      required this.sectionId,
      required this.lesson});

  @override
  State<_LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<_LessonCard> {
  double? _pdfProgress;
  double? _videoProgress;

  @override
  Widget build(BuildContext context) {
    final data = widget.lesson.data() as Map<String, dynamic>;
    final hasPdf = data['pdfUrl'] != null;
    final hasVideo = data['videoUrl'] != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                const Icon(Icons.play_lesson_outlined,
                    size: 18, color: Color(0xFF6366F1)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(data['title'],
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                IconButton(
                  icon: const Icon(Icons.edit,
                      size: 16, color: Color(0xFF6366F1)),
                  onPressed: () => _showEditDialog(context),
                ),
                IconButton(
                  icon: Icon(Icons.delete,
                      size: 16, color: Colors.red.shade400),
                  onPressed: () => _confirmDelete(
                    context,
                    label: data['title'],
                    onConfirm: () => AdminService().deleteLesson(
                        widget.courseId, widget.sectionId, widget.lesson.id),
                  ),
                ),
              ],
            ),

            if ((data['description'] ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 26, bottom: 8),
                child: Text(data['description'],
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 13)),
              ),

            // File upload buttons
            const SizedBox(height: 4),
            Row(
              children: [
                _UploadChip(
                  icon: Icons.picture_as_pdf,
                  label: hasPdf ? 'PDF ✓' : 'Upload PDF',
                  color: hasPdf ? Colors.green : const Color(0xFF6366F1),
                  progress: _pdfProgress,
                  onTap: () => _uploadFile(isPdf: true),
                ),
                const SizedBox(width: 8),
                _UploadChip(
                  icon: Icons.video_library_outlined,
                  label: hasVideo ? 'Video ✓' : 'Upload Video',
                  color: hasVideo ? Colors.green : const Color(0xFF6366F1),
                  progress: _videoProgress,
                  onTap: () => _uploadFile(isPdf: false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadFile({required bool isPdf}) async {
  try {
    final completer = Completer<html.File?>();

    final input = html.FileUploadInputElement();
    input.accept = isPdf ? 'application/pdf' : 'video/*';
    input.click();

    input.onChange.listen((e) {
      if (input.files!.isEmpty) {
        completer.complete(null);
      } else {
        completer.complete(input.files!.first);
      }
    });

    final htmlFile = await completer.future;
    if (htmlFile == null) return;

    final reader = html.FileReader();
    reader.readAsArrayBuffer(htmlFile);
    await reader.onLoad.first;

    final bytes = Uint8List.fromList(reader.result as List<int>);

    if (isPdf) {
      setState(() => _pdfProgress = 0);
      final result = await AdminService().uploadPdf(
        courseId: widget.courseId,
        sectionId: widget.sectionId,
        lessonId: widget.lesson.id,
        fileBytes: bytes,
        fileName: htmlFile.name,
        onProgress: (p) => setState(() => _pdfProgress = p),
      );
      setState(() => _pdfProgress = null);

      // 👇 Show result
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result == 'Success' ? '✅ PDF uploaded!' : '❌ $result'),
            backgroundColor: result == 'Success' ? Colors.green : Colors.red,
          ),
        );
      }
    } else {
      setState(() => _videoProgress = 0);
      final result = await AdminService().uploadVideo(
        courseId: widget.courseId,
        sectionId: widget.sectionId,
        lessonId: widget.lesson.id,
        fileBytes: bytes,
        fileName: htmlFile.name,
        onProgress: (p) => setState(() => _videoProgress = p),
      );
      setState(() => _videoProgress = null);

      // 👇 Show result
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result == 'Success' ? '✅ Video uploaded!' : '❌ $result'),
            backgroundColor: result == 'Success' ? Colors.green : Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    setState(() {
      _pdfProgress = null;
      _videoProgress = null;
    });
    // 👇 Show the actual error
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8), // long enough to read
        ),
      );
    }
  }
}

  void _showEditDialog(BuildContext context) {
    final data = widget.lesson.data() as Map<String, dynamic>;
    final titleController = TextEditingController(text: data['title']);
    final descController = TextEditingController(text: data['description']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Lesson'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await AdminService().updateLesson(
                courseId: widget.courseId,
                sectionId: widget.sectionId,
                lessonId: widget.lesson.id,
                title: titleController.text.trim(),
                description: descController.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1)),
            child:
                const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── UPLOAD CHIP ────────────────────────────────────────────────────────────

class _UploadChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double? progress;
  final VoidCallback onTap;

  const _UploadChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: progress != null ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        child: progress != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('${(progress! * 100).toInt()}%',
                      style: TextStyle(fontSize: 12, color: color)),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 4),
                  Text(label,
                      style: TextStyle(fontSize: 12, color: color)),
                ],
              ),
      ),
    );
  }
}

// ─── SHARED HELPERS ─────────────────────────────────────────────────────────

void _confirmDelete(BuildContext context,
    {required String label, required Future<String> Function() onConfirm}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Confirm Delete'),
      content: Text('Delete "$label"? This cannot be undone.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            await onConfirm();
            if (ctx.mounted) Navigator.pop(ctx);
          },
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
          child:
              const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}