// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'dart:html' as html;
import 'dart:async';
import 'platform_file_picker.dart';

class QuizService {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  static const String _apiKey = 'AIzaSyAmjxu6tZ5tC3IjfHqgi0kXRLPJUGl2qmE';
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

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
  return fetchFileBytes(url);
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
Read the PDF about "$lessonTitle" and generate exactly 10 quiz questions.
Mix multiple choice and true/false questions.

Return ONLY a valid JSON array. No markdown, no backticks, no extra text.

For multiple choice use this exact format:
{
  "question": "Question text?",
  "options": ["Option A", "Option B", "Option C", "Option D"],
  "correctOptionIndex": 0,
  "type": "multiple_choice"
}

For true/false use this exact format:
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
            'maxOutputTokens': 4096,
          }
        }),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final text =
          data['candidates'][0]['content']['parts'][0]['text'] as String;

      final clean = text
          .trim()
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final List<dynamic> parsed = jsonDecode(clean);
      return parsed.cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }

  /// Saves quiz using YOUR existing Firestore structure
  Future<void> _saveQuiz({
    required String lessonTitle,
    required List<Map<String, dynamic>> questions,
    String? courseId,
  }) async {
    // Create the quiz document — matches your existing structure
    final quizRef = await _firestore.collection('quizzes').add({
      'title': '$lessonTitle Quiz',
      'description': 'AI-generated quiz from $lessonTitle PDF',
      'courseId': courseId,
      'questionCount': questions.length,
      'autoGraded': true,
      'aiGenerated': true,
      'createdAt': Timestamp.now(),
    });

    // Save each question — matches your existing subcollection structure
    for (final question in questions) {
      await _firestore
          .collection('quizzes/${quizRef.id}/questions')
          .add({
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