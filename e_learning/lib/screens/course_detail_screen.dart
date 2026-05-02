// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;
  final String courseName;
  final Color courseColor;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.courseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: courseColor,
        foregroundColor: Colors.white,
        title: Text(
          courseName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses/$courseId/sections')
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sections = snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CourseQuizSection(courseId: courseId, courseColor: courseColor),
              const SizedBox(height: 24),
              Text(
                'Course Content',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (sections.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No sections yet',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              else
                ...sections.map((section) {
                  return _SectionTile(
                    courseId: courseId,
                    section: section,
                    courseColor: courseColor,
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

// ─── SECTION TILE ────────────────────────────────────────────────────────────

class _SectionTile extends StatelessWidget {
  final String courseId;
  final DocumentSnapshot section;
  final Color courseColor;

  const _SectionTile({
    required this.courseId,
    required this.section,
    required this.courseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: courseColor.withOpacity(0.15),
            child: Icon(Icons.folder_outlined, color: courseColor),
          ),
          title: Text(
            section['title'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          children: [
            _LessonList(
              courseId: courseId,
              sectionId: section.id,
              courseColor: courseColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── LESSON LIST ─────────────────────────────────────────────────────────────

class _LessonList extends StatelessWidget {
  final String courseId;
  final String sectionId;
  final Color courseColor;

  const _LessonList({
    required this.courseId,
    required this.sectionId,
    required this.courseColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses/$courseId/sections/$sectionId/lessons')
          .orderBy('order')
          .snapshots(),
      builder: (context, snapshot) {
        final lessons = snapshot.data?.docs ?? [];

        if (lessons.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No lessons yet',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }

        return Column(
          children: lessons.map((lesson) {
            final data = lesson.data() as Map<String, dynamic>;
            final hasPdf = data['pdfUrl'] != null;
            final hasVideo = data['videoUrl'] != null;

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: CircleAvatar(
                backgroundColor: courseColor.withOpacity(0.1),
                child: Icon(Icons.play_circle_outline, color: courseColor),
              ),
              title: Text(
                data['title'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle:
                  data['description'] != null &&
                      data['description'].toString().isNotEmpty
                  ? Text(
                      data['description'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              // 👇 Show badges for available content
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasPdf) _Badge(label: 'PDF', color: Colors.red.shade400),
                  if (hasPdf && hasVideo) const SizedBox(width: 4),
                  if (hasVideo)
                    _Badge(label: 'Video', color: Colors.blue.shade400),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LessonScreen(
                      title: data['title'] ?? '',
                      description: data['description'] ?? '',
                      pdfUrl: data['pdfUrl'],
                      videoUrl: data['videoUrl'],
                      courseColor: courseColor,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _CourseQuizSection extends StatelessWidget {
  final String courseId;
  final Color courseColor;

  const _CourseQuizSection({required this.courseId, required this.courseColor});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quizzes')
          .where('courseId', isEqualTo: courseId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final quizzes = snapshot.data?.docs ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quizzes',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (quizzes.isEmpty)
              Text(
                'No quizzes have been created for this course yet.',
                style: TextStyle(color: Colors.grey.shade600),
              )
            else
              ...quizzes.map((quiz) {
                final quizData = quiz.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: courseColor.withOpacity(0.1),
                      child: Icon(Icons.quiz, color: courseColor),
                    ),
                    title: Text(quizData['title'] ?? ''),
                    subtitle: Text(
                      '${quizData['questionCount'] ?? 10} auto MCQs',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            quizId: quiz.id,
                            quizTitle: quizData['title'] ?? 'Quiz',
                            courseColor: courseColor,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
