// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StudyPlannerService {
  static final StudyPlannerService _instance = StudyPlannerService._internal();
  factory StudyPlannerService() => _instance;
  StudyPlannerService._internal();

  static const String _apiKey = 'AIzaSyCVxL2tXyqNZXUT5mhl95Alx3Y4fPAlYQc';
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> getSavedStudyPlan() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('study_plans')
          .doc('current')
          .get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['markdownPlan'] as String?;
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveStudyPlan(String markdownPlan) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('study_plans')
        .doc('current')
        .set({'markdownPlan': markdownPlan, 'updatedAt': Timestamp.now()});
  }

  /// Downloads a PDF from Firebase Storage (mirrors QuizService logic).
  Future<Uint8List?> _downloadPdf(String url) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      Uint8List? bytes;
      try {
        bytes = await ref.getData(100 * 1024 * 1024);
      } catch (e) {
        print('StudyPlanner: getData failed: $e');
      }
      if (bytes == null) {
        final downloadUrl = await ref.getDownloadURL();
        final response = await http.get(Uri.parse(downloadUrl));
        if (response.statusCode == 200) bytes = response.bodyBytes;
      }
      return bytes;
    } catch (e) {
      print('StudyPlanner: PDF download error: $e');
      return null;
    }
  }

  Future<String> generateStudyPlan({
    required int daysPerWeek,
    required int hoursPerDay,
    void Function(String status)? onStatus,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 'Error: User not authenticated.';

      onStatus?.call('Fetching your enrolled courses...');

      final coursesSnapshot = await _firestore.collection('courses').get();

      // Collect all PDF parts and a simple syllabus outline for the prompt
      final List<Map<String, dynamic>> pdfParts = [];
      final List<String> syllabusLines = [];
      int pdfCount = 0;

      for (var courseDoc in coursesSnapshot.docs) {
        final courseId = courseDoc.id;
        final enrollDoc = await _firestore
            .collection('courses/$courseId/enrollments')
            .doc(userId)
            .get();
        if (!enrollDoc.exists) continue;

        final courseTitle = courseDoc.data()['title'] ?? 'Unknown Course';
        syllabusLines.add('## $courseTitle');

        final sectionsSnapshot = await _firestore
            .collection('courses/$courseId/sections')
            .orderBy('order')
            .get();

        for (var sectionDoc in sectionsSnapshot.docs) {
          final sectionId = sectionDoc.id;
          final sectionTitle = sectionDoc.data()['title'] ?? 'Unknown Section';
          syllabusLines.add('### $sectionTitle');

          final lessonsSnapshot = await _firestore
              .collection('courses/$courseId/sections/$sectionId/lessons')
              .orderBy('order')
              .get();

          for (var lessonDoc in lessonsSnapshot.docs) {
            final lessonData = lessonDoc.data();
            final lessonTitle = lessonData['title'] ?? 'Unknown Lesson';
            final pdfUrl = lessonData['pdfUrl'] as String?;
            syllabusLines.add('- $lessonTitle');

            if (pdfUrl != null && pdfUrl.isNotEmpty) {
              onStatus?.call('Downloading PDF: "$lessonTitle"...');
              final bytes = await _downloadPdf(pdfUrl);
              if (bytes != null && bytes.isNotEmpty) {
                pdfParts.add({
                  'inline_data': {
                    'mime_type': 'application/pdf',
                    'data': base64Encode(bytes),
                  }
                });
                pdfCount++;
                print('StudyPlanner: added PDF for "$lessonTitle" (${bytes.length} bytes)');
              }
            }
          }
        }
      }

      if (syllabusLines.isEmpty) {
        return 'You are not enrolled in any courses yet. Please enroll in a course to generate a study plan!';
      }

      onStatus?.call('Analyzing ${pdfCount > 0 ? "$pdfCount PDF(s)" : "syllabus"} with Gemini...');

      // Build the prompt text part
      final syllabusText = syllabusLines.join('\n');
      final promptText = pdfCount > 0
          ? '''You are an expert AI Study Planner. I have attached $pdfCount PDF lesson(s) from the student's enrolled courses.
Read ALL the PDFs carefully and understand the actual content of each lesson.

The student's enrolled course syllabus is:
$syllabusText

The student wants to study $daysPerWeek days per week, for about $hoursPerDay hours per day.

Based on the actual content inside the PDFs, generate a comprehensive, personalized weekly study schedule in Markdown.
- Break down topics logically based on the ACTUAL content you read from the PDFs.
- Include specific chapter references, key concepts to focus on, and topic summaries you gathered from the PDFs.
- Use Markdown headers, bullet points, and checkboxes (e.g. `- [ ]`) to make it an actionable to-do list.
- Ensure workload fits within $hoursPerDay hours per day.
- Add specific, content-aware study tips for each topic based on what you read.
- Do NOT return JSON, only return clean Markdown text.'''
          : '''You are an expert AI Study Planner. The student wants to study $daysPerWeek days per week, for about $hoursPerDay hours per day.

Their enrolled course syllabus is:
$syllabusText

Generate a structured weekly study schedule in Markdown with headers, bullet points, and checkboxes (e.g. `- [ ]`).
Ensure the workload fits $hoursPerDay hours/day. Add encouraging study tips. Return only clean Markdown.''';

      // Build Gemini request: PDFs first, then the text prompt
      final List<Map<String, dynamic>> contentParts = [
        ...pdfParts,
        {'text': promptText},
      ];

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {'parts': contentParts}
          ],
          'generationConfig': {
            'temperature': 0.6,
            'maxOutputTokens': 2048,
          }
        }),
      );

      print('StudyPlanner API status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('StudyPlanner API error: ${response.body}');
        return 'Failed to generate study plan due to an API error.';
      }

      final responseData = jsonDecode(response.body);
      final text =
          responseData['candidates'][0]['content']['parts'][0]['text'] as String;

      final cleanText = text.trim();

      onStatus?.call('Saving your plan...');
      await saveStudyPlan(cleanText);

      return cleanText;
    } catch (e) {
      print('StudyPlanner exception: $e');
      return 'An error occurred while generating the study plan: $e';
    }
  }
}
