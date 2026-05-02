import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizAttemptService {
  static final QuizAttemptService _instance = QuizAttemptService._internal();
  factory QuizAttemptService() => _instance;
  QuizAttemptService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// بدء محاولة جديدة للـ Quiz
  Future<String> startQuizAttempt({required String quizId}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // إنشاء محاولة جديدة
      final attemptRef = await _firestore.collection('quiz_attempts').add({
        'userId': userId,
        'quizId': quizId,
        'startedAt': Timestamp.now(),
        'completedAt': null,
        'score': null,
        'totalQuestions': 0,
        'answers': {}, // سيتم حفظ الإجابات هنا
      });

      return attemptRef.id;
    } catch (e) {
      throw Exception('Failed to start quiz attempt: $e');
    }
  }

  /// حفظ إجابة واحدة أثناء الإجابة
  Future<void> saveAnswer({
    required String attemptId,
    required int questionIndex,
    required int selectedOptionIndex,
  }) async {
    try {
      await _firestore.collection('quiz_attempts').doc(attemptId).update({
        'answers.$questionIndex': selectedOptionIndex,
      });
    } catch (e) {
      throw Exception('Failed to save answer: $e');
    }
  }

  /// تسليم الـ Quiz وحساب النتيجة
  Future<Map<String, dynamic>> submitQuiz({
    required String attemptId,
    required String quizId,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // الحصول على بيانات المحاولة
      final attemptDoc = await _firestore
          .collection('quiz_attempts')
          .doc(attemptId)
          .get();

      final attemptData = attemptDoc.data() as Map<String, dynamic>;
      final answers = attemptData['answers'] as Map<String, dynamic>? ?? {};

      // الحصول على جميع أسئلة الـ Quiz
      final questionsSnapshot = await _firestore
          .collection('quizzes/$quizId/questions')
          .get();

      int correctCount = 0;
      int totalQuestions = questionsSnapshot.docs.length;

      // حساب الإجابات الصحيحة
      for (int i = 0; i < questionsSnapshot.docs.length; i++) {
        final question =
            questionsSnapshot.docs[i].data() as Map<String, dynamic>;
        final correctIndex = question['correctOptionIndex'] as int?;

        final answeredIndex = answers['$i'] as int?;

        if (answeredIndex != null && answeredIndex == correctIndex) {
          correctCount++;
        }
      }

      // حساب النسبة المئوية
      final percentage = totalQuestions > 0
          ? (correctCount / totalQuestions * 100).toInt()
          : 0;

      // تحديث بيانات المحاولة بالنتيجة
      await _firestore.collection('quiz_attempts').doc(attemptId).update({
        'completedAt': Timestamp.now(),
        'score': percentage,
        'correctAnswers': correctCount,
        'totalQuestions': totalQuestions,
      });

      return {
        'correctAnswers': correctCount,
        'totalQuestions': totalQuestions,
        'score': percentage,
        'attemptId': attemptId,
      };
    } catch (e) {
      throw Exception('Failed to submit quiz: $e');
    }
  }

  /// الحصول على محاولات الطالب السابقة للـ Quiz
  Stream<QuerySnapshot> getStudentAttempts(String quizId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.empty();

    return _firestore
        .collection('quiz_attempts')
        .where('userId', isEqualTo: userId)
        .where('quizId', isEqualTo: quizId)
        .orderBy('startedAt', descending: true)
        .snapshots();
  }

  /// الحصول على تفاصيل محاولة معينة
  Future<Map<String, dynamic>?> getAttemptDetails(String attemptId) async {
    try {
      final doc = await _firestore
          .collection('quiz_attempts')
          .doc(attemptId)
          .get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }
}
