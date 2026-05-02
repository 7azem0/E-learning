// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/quiz_attempt_service.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;
  final Color courseColor;

  const QuizScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.courseColor,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late String _attemptId;
  final QuizAttemptService _quizService = QuizAttemptService();
  late PageController _pageController;
  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {}; 

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeQuizAttempt();
  }

  void _initializeQuizAttempt() async {
    try {
      _attemptId = await _quizService.startQuizAttempt(quizId: widget.quizId);
      setState(() {});
    } catch (e) {
      _showErrorDialog('Error starting quiz: $e');
    }
  }

  void _onAnswerSelected(int optionIndex) async {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = optionIndex;
    });

    try {
      await _quizService.saveAnswer(
        attemptId: _attemptId,
        questionIndex: _currentQuestionIndex,
        selectedOptionIndex: optionIndex,
      );
    } catch (e) {
      _showErrorDialog('Error saving answer: $e');
    }
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < 9) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitQuiz() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: const Text('Are you sure you want to submit the quiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _submitQuizHandler();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _submitQuizHandler() async {
    try {
      final result = await _quizService.submitQuiz(
        attemptId: _attemptId,
        quizId: widget.quizId,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => QuizResultScreen(
              quizTitle: widget.quizTitle,
              courseColor: widget.courseColor,
              correctAnswers: result['correctAnswers'],
              totalQuestions: result['totalQuestions'],
              score: result['score'],
              attemptId: _attemptId,
              quizId: widget.quizId,
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Error submitting quiz: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: widget.courseColor,
        foregroundColor: Colors.white,
        title: const Text('Solve the Quiz'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .doc(widget.quizId)
            .snapshots(),
        builder: (context, quizSnapshot) {
          if (!quizSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('quizzes/${widget.quizId}/questions')
                .snapshots(),
            builder: (context, questionsSnapshot) {
              if (!questionsSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final questions = questionsSnapshot.data!.docs;

              return Column(
                children: [
                  // Progress Bar
                  Container(
                    height: 8,
                    color: Colors.grey.shade200,
                    child: Row(
                      children: [
                        Expanded(
                          flex: _currentQuestionIndex + 1,
                          child: Container(color: widget.courseColor),
                        ),
                        Expanded(
                          flex: questions.length - _currentQuestionIndex - 1,
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                  // Question Counter
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.courseColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Answered: ${_selectedAnswers.length}',
                            style: TextStyle(
                              color: widget.courseColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Questions PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentQuestionIndex = index;
                        });
                      },
                      itemCount: questions.length,
                      itemBuilder: (BuildContext context, int index) {
                        final questionDoc = questions[index];
                        final question =
                            questionDoc.data() as Map<String, dynamic>;
                        final questionText = question['question'] as String;
                        final options = List<String>.from(
                          question['options'] ?? [],
                        );
                        final type =
                            question['type'] as String? ?? 'multiple_choice';

                        return QuestionCard(
                          question: questionText,
                          options: options,
                          type: type,
                          selectedOption: _selectedAnswers[index],
                          onAnswerSelected: _onAnswerSelected,
                          courseColor: widget.courseColor,
                        );
                      },
                    ),
                  ),
                  // Navigation Buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (_currentQuestionIndex > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _goToPreviousQuestion,
                              child: const Text('Previous'),
                            ),
                          )
                        else
                          const Expanded(child: SizedBox()),
                        const SizedBox(width: 12),
                        if (_currentQuestionIndex < questions.length - 1)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _goToNextQuestion,
                              child: const Text('Next'),
                            ),
                          )
                        else
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: _submitQuiz,
                              child: const Text(
                                'Submit',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// Card للسؤال الواحد
class QuestionCard extends StatelessWidget {
  final String question;
  final List<String> options;
  final String type;
  final int? selectedOption;
  final Function(int) onAnswerSelected;
  final Color courseColor;

  const QuestionCard({
    super.key,
    required this.question,
    required this.options,
    required this.type,
    this.selectedOption,
    required this.onAnswerSelected,
    required this.courseColor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: courseColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: courseColor.withOpacity(0.2)),
            ),
            child: Text(
              question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Options
          Text(
            'Options:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            options.length,
            (index) => OptionButton(
              label: options[index],
              isSelected: selectedOption == index,
              onTap: () => onAnswerSelected(index),
              courseColor: courseColor,
            ),
          ),
        ],
      ),
    );
  }
}

// زر الاختيار
class OptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color courseColor;

  const OptionButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.courseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? courseColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected ? courseColor.withOpacity(0.1) : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? courseColor : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isSelected
                        ? Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: courseColor,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? courseColor : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
