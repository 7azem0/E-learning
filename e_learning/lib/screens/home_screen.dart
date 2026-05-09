// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../widgets/menu.dart';

import '../services/mood_tracking_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasLoggedMood = true;
  bool _isLoadingMood = true;
  int? _selectedMood;
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmittingMood = false;

  @override
  void initState() {
    super.initState();
    _checkMoodStatus();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _checkMoodStatus() async {
    final hasLogged = await MoodTrackingService().hasLoggedMoodToday();
    if (mounted) {
      setState(() {
        _hasLoggedMood = hasLogged;
        _isLoadingMood = false;
      });
    }
  }

  Future<void> _submitMood() async {
    if (_selectedMood == null) return;
    
    setState(() => _isSubmittingMood = true);
    
    await MoodTrackingService().logMood(
      _selectedMood!,
      _noteController.text.trim(),
    );
    
    if (mounted) {
      setState(() {
        _hasLoggedMood = true;
        _isSubmittingMood = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mood logged successfully! Have a great day learning.'),
          backgroundColor: Colors.green.shade600,
        ),
      );
    }
  }

  Widget _buildMoodTracker() {
    if (_isLoadingMood) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasLoggedMood) {
      return Card(
        color: Colors.green.shade50,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.green.shade200),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "You've logged your mood today. Keep up the great work!",
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: const Color(0xFFFAFAF8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.mood, color: Color(0xFF6366F1)),
                const SizedBox(width: 8),
                Text(
                  "How are you feeling today?",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMoodEmoji(1, '😫'),
                _buildMoodEmoji(2, '😕'),
                _buildMoodEmoji(3, '😐'),
                _buildMoodEmoji(4, '🙂'),
                _buildMoodEmoji(5, '😃'),
              ],
            ),
            if (_selectedMood != null) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: 'Any brief thoughts? (Optional)',
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmittingMood ? null : _submitMood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmittingMood
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Log Mood'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoodEmoji(int value, String emoji) {
    final isSelected = _selectedMood == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1).withOpacity(0.1) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: isSelected ? 32 : 28,
            color: isSelected ? null : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("EduHub"),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      drawer: const Menu(),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF111111))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Computer Science Review",
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Learn Computer Science With Course Dispatches",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Programming, AI, and data science lessons organized with a quieter editorial rhythm.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/courses');
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Explore Courses"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildMoodTracker(),
          const SizedBox(height: 24),
          Text(
            "Today’s syllabus",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Enroll in courses, read instructor announcements, and continue into lessons from the Courses section.",
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// Reusable Modern Course Card Widget
class CourseCardItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const CourseCardItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
