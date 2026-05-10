import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KnowledgeGapService {
  static final KnowledgeGapService _instance = KnowledgeGapService._internal();
  factory KnowledgeGapService() => _instance;
  KnowledgeGapService._internal();

  static const String _apiKey = 'AIzaSyCVxL2tXyqNZXUT5mhl95Alx3Y4fPAlYQc';
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> generateKnowledgeGapAnalysis(String attemptId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 'User not authenticated';

      final attemptDoc = await _firestore.collection('quiz_attempts').doc(attemptId).get();

      if (!attemptDoc.exists) {
        return 'Attempt not found.';
      }

      final data = attemptDoc.data()!;
      if (data['userId'] != userId) {
        return 'Unauthorized access.';
      }

      if (data['score'] == null) {
        return 'Quiz not yet completed.';
      }

      if (data['score'] == 100) {
        return 'Great job! You scored 100% on this quiz. No major knowledge gaps detected.';
      }

      final incorrectList = data['incorrectQuestions'] as List<dynamic>? ?? [];
      
      if (incorrectList.isEmpty) {
         return 'No incorrect questions found to analyze.';
      }

      // Prepare data for Gemini
      final questionsDataForAI = incorrectList.map((q) => {
        'question': q['question'],
        'correctAnswer': q['correctAnswer'],
        'userAnswer': q['userAnswer']
      }).toList();

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''You are an expert AI tutor. A student has taken a quiz and answered the following questions incorrectly.
Based on this data, identify the student's knowledge gaps, patterns in their mistakes, and provide specific, actionable study recommendations to help them improve.
Keep your response encouraging, concise, and format it nicely in Markdown (using headers, bullet points).

Incorrect Questions Data:
${jsonEncode(questionsDataForAI)}
'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (response.statusCode != 200) {
        print('Knowledge Gap AI Error: ${response.body}');
        return 'Failed to analyze knowledge gaps due to an API error.';
      }

      final responseData = jsonDecode(response.body);
      final text = responseData['candidates'][0]['content']['parts'][0]['text'] as String;

      return text.trim();
    } catch (e) {
      print('Knowledge Gap Exception: $e');
      return 'An error occurred while analyzing knowledge gaps: $e';
    }
  }
}
