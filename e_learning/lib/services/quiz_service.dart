// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizService {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  static const String _apiKey = 'AIzaSyAhNdcksHuBrvJISLPAm4N0qgWzil-6WCE';
  static const String _apiUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> generateQuizFromLesson({
    required String lessonTitle,
    required String pdfUrl,
    String? courseId,
    void Function(String status)? onStatus,
  }) async {
    try {
      onStatus?.call('Downloading PDF...');
      final pdfBytes = await _downloadPdf(pdfUrl);
      if (pdfBytes == null) return 'Failed to download PDF';

      onStatus?.call('Reading PDF with AI...');
      final questions = await _generateQuestions(
        pdfBytes: pdfBytes,
        lessonTitle: lessonTitle,
      );
      if (questions == null) return 'Failed to generate questions';

      onStatus?.call('Saving quiz...');
      await _saveQuiz(
        lessonTitle: lessonTitle,
        courseId: courseId,
        questions: questions,
      );

      return 'Success';
    } catch (e) {
      return 'Error: $e';
    }
  }

Future<Uint8List?> _downloadPdf(String url) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    print('Current user: ${user?.uid}');

    final ref = FirebaseStorage.instance.refFromURL(url);
    
    // Try getData first
    Uint8List? bytes;
    try {
      bytes = await ref.getData(100 * 1024 * 1024);
    } catch (e) {
      print('getData failed or threw an error: $e');
    }
    
    // If null, try getting download URL and fetching via http
    if (bytes == null) {
      print('getData returned null, trying via download URL...');
      final downloadUrl = await ref.getDownloadURL();
      print('Download URL: $downloadUrl');
      
      final response = await http.get(Uri.parse(downloadUrl));
      print('HTTP status: ${response.statusCode}');
      if (response.statusCode == 200) {
        bytes = response.bodyBytes;
      }
    }

    print('Downloaded ${bytes?.length} bytes');
    return bytes;
  } catch (e, stack) {
    print('PDF download error: $e');
    print('Stack: $stack');
    return null;
  }
}

Future<List<Map<String, dynamic>>?> _generateQuestions({
  required Uint8List pdfBytes,
  required String lessonTitle,
}) async {
  try {
    final base64Pdf = base64Encode(pdfBytes);

    final response = await http.post(
      Uri.parse('$_apiUrl?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'inline_data': {
                  'mime_type': 'application/pdf',
                  'data': base64Pdf,
                }
              },
              {
                'text': '''You are a quiz generator for an e-learning platform.
Read the entire PDF about "$lessonTitle" including all text and images, and generate exactly 10 quiz questions.
Mix multiple choice and true/false questions based ONLY on the actual content of the PDF.

Return ONLY a valid JSON array. No markdown, no backticks, no extra text.

For multiple choice:
{
  "question": "Question text?",
  "options": ["Option A", "Option B", "Option C", "Option D"],
  "correctOptionIndex": 0,
  "type": "multiple_choice"
}

For true/false:
{
  "question": "Statement here.",
  "options": ["True", "False"],
  "correctOptionIndex": 0,
  "type": "true_false"
}

Generate exactly 10 questions, mix of both types.'''
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 2048,
        }
      }),
    );

    print('Status: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('Body: ${response.body}');
      return null;
    }

    final data = jsonDecode(response.body);
    final text = data['candidates'][0]['content']['parts'][0]['text'] as String;

    final clean = text
        .trim()
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final List<dynamic> parsed = jsonDecode(clean);
    return parsed.cast<Map<String, dynamic>>();
  } catch (e) {
    print('Exception: $e');
    return null;
  }
}

  Future<void> _saveQuiz({
  required String lessonTitle,
  required List<Map<String, dynamic>> questions,
  String? courseId,
}) async {
  // 👇 Count existing quizzes for this lesson
  final existing = await _firestore
      .collection('quizzes')
      .where('lessonTitle', isEqualTo: lessonTitle)
      .where('courseId', isEqualTo: courseId)
      .get();

  final quizNumber = existing.docs.length + 1;
  final quizTitle = quizNumber == 1
      ? '$lessonTitle Quiz'
      : '$lessonTitle Quiz #$quizNumber';

  final quizRef = await _firestore.collection('quizzes').add({
    'title': quizTitle,
    'description': 'AI-generated quiz from $lessonTitle PDF',
    'courseId': courseId,
    'lessonTitle': lessonTitle, // 👈 store this so we can query it above
    'questionCount': questions.length,
    'autoGraded': true,
    'aiGenerated': true,
    'createdAt': Timestamp.now(),
  });

  for (final question in questions) {
    await _firestore.collection('quizzes/${quizRef.id}/questions').add({
      'question': question['question'],
      'options': question['options'],
      'correctOptionIndex': question['correctOptionIndex'],
      'type': question['type'],
      'points': 1,
      'autoGraded': true,
      'createdAt': Timestamp.now(),
    });
  }
}
}