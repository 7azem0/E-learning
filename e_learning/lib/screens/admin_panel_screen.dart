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
        title: const Text('Admin Panel'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
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
              _buildAddButton(
                label: 'Add Course',
                onTap: () => _showCourseDialog(context),
              ),
              const SizedBox(height: 12),
              ...courses.map((course) => _CourseCard(course: course)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddButton(
      {required String label, required VoidCallback onTap}) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add, color: Color(0xFF6366F1)),
      label: Text(label, style: const TextStyle(color: Color(0xFF6366F1))),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF6366F1)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showCourseDialog(BuildContext context, {DocumentSnapshot? course}) {
    final titleController =
        TextEditingController(text: course?['title'] ?? '');
    final descController =
        TextEditingController(text: course?['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(course == null ? 'New Course' : 'Edit Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (course == null) {
                await AdminService().createCourse(
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                );
              } else {
                await AdminService().updateCourse(
                  courseId: course.id,
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                );
              }
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1)),
            child: Text(course == null ? 'Create' : 'Save',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── COURSE CARD ────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  final DocumentSnapshot course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(course['title'],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(course['description'] ?? '',
            maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF6366F1)),
              onPressed: () => _showCourseDialog(context, course: course),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red.shade400),
              onPressed: () => _confirmDelete(
                context,
                label: course['title'],
                onConfirm: () => AdminService().deleteCourse(course.id),
              ),
            ),
          ],
        ),
        children: [_SectionList(courseId: course.id)],
      ),
    );
  }

  void _showCourseDialog(BuildContext context, {DocumentSnapshot? course}) {
    final titleController =
        TextEditingController(text: course?['title'] ?? '');
    final descController =
        TextEditingController(text: course?['description'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(course == null ? 'New Course' : 'Edit Course'),
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
              await AdminService().updateCourse(
                courseId: course!.id,
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

  Future<void> _uploadFile({required bool isPdf}) async {  // 👈 replace FROM here
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
      await AdminService().uploadPdf(
        courseId: widget.courseId,
        sectionId: widget.sectionId,
        lessonId: widget.lesson.id,
        fileBytes: bytes,
        fileName: htmlFile.name,
        onProgress: (p) => setState(() => _pdfProgress = p),
      );
      setState(() => _pdfProgress = null);
    } else {
      setState(() => _videoProgress = 0);
      await AdminService().uploadVideo(
        courseId: widget.courseId,
        sectionId: widget.sectionId,
        lessonId: widget.lesson.id,
        fileBytes: bytes,
        fileName: htmlFile.name,
        onProgress: (p) => setState(() => _videoProgress = p),
      );
      setState(() => _videoProgress = null);
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