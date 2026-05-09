import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/knowledge_gap_service.dart';
import '../services/enrollment_service.dart';
import '../widgets/menu.dart';

class QuizzesAnalysisScreen extends StatefulWidget {
  const QuizzesAnalysisScreen({super.key});

  @override
  State<QuizzesAnalysisScreen> createState() => _QuizzesAnalysisScreenState();
}

class _QuizzesAnalysisScreenState extends State<QuizzesAnalysisScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  List<Map<String, dynamic>> _coursesWithAttempts = [];
  String? _analyzingAttemptId;
  Map<String, String> _analysisResults = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // 1. Get user's enrolled courses first
      final enrolledCourses = await EnrollmentService().getEnrolledCourses();
      final enrolledCourseIds = enrolledCourses.map((c) => c['id'] as String).toSet();
      final Map<String, String> courseTitles = {};
      for (var course in enrolledCourses) {
        courseTitles[course['id']] = course['title'] ?? 'Unknown Course';
      }

      // 2. Fetch all quizzes to filter by existence and course
      final quizzesSnapshot = await _firestore.collection('quizzes').get();
      final Map<String, Map<String, dynamic>> quizzesData = {};
      for (var doc in quizzesSnapshot.docs) {
        final data = doc.data();
        final courseId = data['courseId'] as String?;
        // Only include quiz if its course is in enrolled list
        if (courseId != null && enrolledCourseIds.contains(courseId)) {
          quizzesData[doc.id] = data;
        }
      }

      // 3. Fetch user's quiz attempts
      final attemptsSnapshot = await _firestore
          .collection('quiz_attempts')
          .where('userId', isEqualTo: userId)
          .get();

      final validAttempts = attemptsSnapshot.docs.where((doc) {
        final data = doc.data();
        final quizId = data['quizId'] as String?;
        // Attempt is valid only if score exists AND the quiz still exists/belongs to enrolled course
        return data['score'] != null && 
               data['completedAt'] != null && 
               quizId != null && 
               quizzesData.containsKey(quizId);
      }).toList();
      
      validAttempts.sort((a, b) {
        final tsA = a.data()['completedAt'] as Timestamp?;
        final tsB = b.data()['completedAt'] as Timestamp?;
        if (tsA == null || tsB == null) return 0;
        return tsB.compareTo(tsA);
      });

      final Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var doc in validAttempts) {
        final attemptData = doc.data();
        final quizId = attemptData['quizId'] as String;
        final quizData = quizzesData[quizId]!;
        final courseId = quizData['courseId'] as String;
        final quizTitle = quizData['title'] as String? ?? 'Unknown Quiz';

        if (!grouped.containsKey(courseId)) {
          grouped[courseId] = [];
        }

        grouped[courseId]!.add({
          'attemptId': doc.id,
          'quizTitle': quizTitle,
          'score': attemptData['score'],
          'date': (attemptData['completedAt'] as Timestamp?)?.toDate(),
        });
      }

      final List<Map<String, dynamic>> finalData = [];
      grouped.forEach((cId, attemptsList) {
         finalData.add({
           'courseId': cId,
           'courseTitle': courseTitles[cId] ?? 'Other Quizzes',
           'attempts': attemptsList,
         });
      });

      if (mounted) {
        setState(() {
          _coursesWithAttempts = finalData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _analyzeQuiz(String attemptId) async {
    setState(() {
      _analyzingAttemptId = attemptId;
    });

    final result = await KnowledgeGapService().generateKnowledgeGapAnalysis(attemptId);

    if (mounted) {
      setState(() {
        _analyzingAttemptId = null;
        if (result != null) {
          _analysisResults[attemptId] = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Analysis'),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      drawer: const Menu(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _coursesWithAttempts.isEmpty
              ? const Center(child: Text('No completed quizzes found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _coursesWithAttempts.length,
                  itemBuilder: (context, index) {
                    final courseData = _coursesWithAttempts[index];
                    final courseTitle = courseData['courseTitle'];
                    final attempts = courseData['attempts'] as List<Map<String, dynamic>>;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            courseTitle,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        ...attempts.map((attempt) {
                          final attemptId = attempt['attemptId'];
                          final quizTitle = attempt['quizTitle'];
                          final score = attempt['score'];
                          final date = attempt['date'] as DateTime?;
                          final dateStr = date != null ? '${date.day}/${date.month}/${date.year}' : '';

                          final isAnalyzing = _analyzingAttemptId == attemptId;
                          final analysisResult = _analysisResults[attemptId];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ExpansionTile(
                              key: PageStorageKey(attemptId),
                              title: Text(quizTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('Completed: $dateStr'),
                              leading: CircleAvatar(
                                backgroundColor: score != null && score >= 80 ? Colors.green : Colors.orange,
                                child: Text(
                                  '$score%',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      if (analysisResult != null) ...[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: Text(
                                            analysisResult,
                                            style: const TextStyle(fontSize: 14, height: 1.5),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      ElevatedButton.icon(
                                        onPressed: isAnalyzing ? null : () => _analyzeQuiz(attemptId),
                                        icon: isAnalyzing 
                                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                                            : const Icon(Icons.auto_awesome),
                                        label: Text(isAnalyzing ? 'Analyzing...' : 'Generate AI Analysis'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
    );
  }
}
