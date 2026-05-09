// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ─── Quizes ───────────────────────────────────────────

  Stream<QuerySnapshot> getQuizzes() {
    return _firestore
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<String> createQuiz({
    required String title,
    String? description,
    String? courseId,
  }) async {
    try {
      final quizRef = await _firestore.collection('quizzes').add({
        'title': title,
        'description': description ?? '',
        'courseId': courseId,
        'questionCount': 10,
        'autoGraded': true,
        'createdAt': Timestamp.now(),
      });

      final questions = _buildDefaultQuizQuestions(title, 10);
      for (final question in questions) {
        await _firestore
            .collection('quizzes/${quizRef.id}/questions')
            .add(question);
      }

      return 'Success';
    } catch (e) {
      return 'Failed to create quiz';
    }
  }

  List<Map<String, dynamic>> _buildDefaultQuizQuestions(
    String title,
    int count,
  ) {
    return List.generate(count, (index) {
      final questionIndex = index + 1;
      return {
        'question': 'Auto-generated MCQ $questionIndex for "$title".',
        'options': [
          'Correct answer',
          'Alternative answer 1',
          'Alternative answer 2',
          'Alternative answer 3',
        ],
        'correctOptionIndex': 0,
        'points': 1,
        'autoGraded': true,
        'createdAt': Timestamp.now(),
      };
    });
  }

  Future<String> deleteQuiz(String quizId) async {
    try {
      final questionSnapshot = await _firestore
          .collection('quizzes/$quizId/questions')
          .get();
      for (final question in questionSnapshot.docs) {
        await _firestore
            .collection('quizzes/$quizId/questions')
            .doc(question.id)
            .delete();
      }
      await _firestore.collection('quizzes').doc(quizId).delete();
      return 'Success';
    } catch (e) {
      return 'Failed to delete quiz';
    }
  }

  // ─── COURSES ───────────────────────────────────────────

  Stream<QuerySnapshot> getCourses() {
    return _firestore
        .collection('courses')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<String> createCourse({
    required String title,
    required String description,
    String? icon,
    int? color,
  }) async {
    try {
      await _firestore.collection('courses').add({
        'title': title,
        'description': description,
        'icon': icon ?? 'school',
        'color': color ?? 0xFF334155,
        'createdAt': Timestamp.now(),
      });
      return 'Success';
    } catch (e) {
      return 'Failed to create course';
    }
  }

  Future<String> updateCourse({
    required String courseId,
    required String title,
    required String description,
    String? icon,
    int? color,
  }) async {
    try {
      final updateData = {'title': title, 'description': description};
      if (icon != null) updateData['icon'] = icon;
      if (color != null) updateData['color'] = color as String;

      await _firestore.collection('courses').doc(courseId).update(updateData);
      return 'Success';
    } catch (e) {
      return 'Failed to update course';
    }
  }

  Future<String> deleteCourse(String courseId) async {
    try {
      // Delete all sections and lessons recursively
      final sections = await _firestore
          .collection('courses/$courseId/sections')
          .get();
      for (final section in sections.docs) {
        await deleteSection(courseId, section.id);
      }
      await _firestore.collection('courses').doc(courseId).delete();
      return 'Success';
    } catch (e) {
      return 'Failed to delete course';
    }
  }

  // ─── SECTIONS ──────────────────────────────────────────

  Stream<QuerySnapshot> getSections(String courseId) {
    return _firestore
        .collection('courses/$courseId/sections')
        .orderBy('order')
        .snapshots();
  }

  Future<String> createSection({
    required String courseId,
    required String title,
    required int order,
  }) async {
    try {
      await _firestore.collection('courses/$courseId/sections').add({
        'title': title,
        'order': order,
      });
      return 'Success';
    } catch (e) {
      return 'Failed to create section';
    }
  }

  Future<String> updateSection({
    required String courseId,
    required String sectionId,
    required String title,
  }) async {
    try {
      await _firestore
          .collection('courses/$courseId/sections')
          .doc(sectionId)
          .update({'title': title});
      return 'Success';
    } catch (e) {
      return 'Failed to update section';
    }
  }

  Future<String> deleteSection(String courseId, String sectionId) async {
    try {
      final lessons = await _firestore
          .collection('courses/$courseId/sections/$sectionId/lessons')
          .get();
      for (final lesson in lessons.docs) {
        await deleteLesson(courseId, sectionId, lesson.id);
      }
      await _firestore
          .collection('courses/$courseId/sections')
          .doc(sectionId)
          .delete();
      return 'Success';
    } catch (e) {
      return 'Failed to delete section';
    }
  }

  // ─── LESSONS ───────────────────────────────────────────

  Stream<QuerySnapshot> getLessons(String courseId, String sectionId) {
    return _firestore
        .collection('courses/$courseId/sections/$sectionId/lessons')
        .orderBy('order')
        .snapshots();
  }

  Future<String> createLesson({
    required String courseId,
    required String sectionId,
    required String title,
    required String description,
    required int order,
  }) async {
    try {
      await _firestore
          .collection('courses/$courseId/sections/$sectionId/lessons')
          .add({
            'title': title,
            'description': description,
            'order': order,
            'pdfUrl': null,
            'videoUrl': null,
          });

      // Update course lesson count
      await _firestore.collection('courses').doc(courseId).update({
        'lessonCount': FieldValue.increment(1),
      });

      return 'Success';
    } catch (e) {
      return 'Failed to create lesson';
    }
  }

  Future<String> updateLesson({
    required String courseId,
    required String sectionId,
    required String lessonId,
    required String title,
    required String description,
  }) async {
    try {
      await _firestore
          .collection('courses/$courseId/sections/$sectionId/lessons')
          .doc(lessonId)
          .update({'title': title, 'description': description});
      return 'Success';
    } catch (e) {
      return 'Failed to update lesson';
    }
  }

  Future<String> deleteLesson(
    String courseId,
    String sectionId,
    String lessonId,
  ) async {
    try {
      // Delete files from storage too
      try {
        await _storage
            .ref('courses/$courseId/$sectionId/$lessonId/pdf')
            .delete();
      } catch (_) {}
      try {
        await _storage
            .ref('courses/$courseId/$sectionId/$lessonId/video')
            .delete();
      } catch (_) {}
      await _firestore
          .collection('courses/$courseId/sections/$sectionId/lessons')
          .doc(lessonId)
          .delete();

      // Update course lesson count
      await _firestore.collection('courses').doc(courseId).update({
        'lessonCount': FieldValue.increment(-1),
      });

      return 'Success';
    } catch (e) {
      return 'Failed to delete lesson';
    }
  }

  /// Manually sync the lessonCount for a course based on its actual lessons
  Future<void> syncLessonCount(String courseId) async {
    try {
      final sections = await _firestore.collection('courses/$courseId/sections').get();
      int total = 0;
      for (var section in sections.docs) {
        final lessons = await _firestore
            .collection('courses/$courseId/sections/${section.id}/lessons')
            .get();
        total += lessons.docs.length;
      }
      await _firestore.collection('courses').doc(courseId).update({'lessonCount': total});
    } catch (e) {
      debugPrint('Error syncing lesson count: $e');
    }
  }

  // ─── FILE UPLOADS ───────────────────────────────────────

  Future<String> uploadPdf({
    required String courseId,
    required String sectionId,
    required String lessonId,
    Uint8List? fileBytes,
    String? filePath,
    required String fileName,
    required int fileSize,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // 100MB Limit Check for PDFs
      const limit = 100 * 1024 * 1024;
      if (fileSize > limit) {
        return 'PDF is too large. Maximum limit is 100MB.';
      }

      final ref = _storage.ref(
        'courses/$courseId/sections/$sectionId/$lessonId/pdf/$fileName',
      );

      UploadTask uploadTask;
      if (!kIsWeb && filePath != null) {
        uploadTask = ref.putFile(
          File(filePath),
          SettableMetadata(contentType: 'application/pdf'),
        );
      } else if (fileBytes != null) {
        uploadTask = ref.putData(
          fileBytes,
          SettableMetadata(contentType: 'application/pdf'),
        );
      } else {
        return 'No file data provided';
      }

      // Listen to progress updates
      uploadTask.snapshotEvents.listen((snapshot) {
        if (onProgress != null) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      final url = await ref.getDownloadURL();

      // Update Firestore with the PDF URL
      await _firestore
          .collection('courses/$courseId/sections/$sectionId/lessons')
          .doc(lessonId)
          .update({'pdfUrl': url});

      return 'Success';
    } catch (e) {
      print('PDF Upload Error: $e');
      return 'Failed to upload PDF: ${e.toString()}';
    }
  }

  Future<String> uploadVideo({
    required String courseId,
    required String sectionId,
    required String lessonId,
    Uint8List? fileBytes,
    String? filePath,
    required String fileName,
    required int fileSize,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // 1GB Limit Check (1024 * 1024 * 1024 bytes)
      const oneGB = 1024 * 1024 * 1024;
      if (fileSize > oneGB) {
        return 'File is too large. Maximum limit is 1GB.';
      }

      final ref = _storage.ref(
        'courses/$courseId/sections/$sectionId/$lessonId/video/$fileName',
      );

      UploadTask uploadTask;
      if (!kIsWeb && filePath != null) {
        uploadTask = ref.putFile(
          File(filePath),
          SettableMetadata(contentType: 'video/mp4'),
        );
      } else if (fileBytes != null) {
        uploadTask = ref.putData(
          fileBytes,
          SettableMetadata(contentType: 'video/mp4'),
        );
      } else {
        return 'No file data provided';
      }

      // Listen to progress updates
      uploadTask.snapshotEvents.listen((snapshot) {
        if (onProgress != null) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      final url = await ref.getDownloadURL();

      // Update Firestore with the video URL
      await _firestore
          .collection('courses/$courseId/sections/$sectionId/lessons')
          .doc(lessonId)
          .update({'videoUrl': url});

      return 'Success';
    } catch (e) {
      print('Video Upload Error: $e');
      return 'Failed to upload video: ${e.toString()}';
    }
  }
}
