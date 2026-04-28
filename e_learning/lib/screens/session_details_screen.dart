// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SessionDetailsScreen extends StatelessWidget {
  final String courseName;
  final String sessionTitle;

  const SessionDetailsScreen({
    super.key,
    required this.courseName,
    required this.sessionTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          sessionTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6366F1),
                    const Color(0xFF8B5CF6),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseName,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sessionTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Overview Section
          Text(
            "Overview",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Content for $sessionTitle will appear here. This is where you can add detailed learning materials, video tutorials, code examples, and practice problems.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Learning Objectives
          Text(
            "What You'll Learn",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _LearningObjective(
            title: "Understand the fundamentals",
            description: "Learn core concepts of $sessionTitle",
          ),
          const SizedBox(height: 12),
          _LearningObjective(
            title: "Practical applications",
            description: "Apply knowledge to real-world scenarios",
          ),
          const SizedBox(height: 12),
          _LearningObjective(
            title: "Problem solving",
            description: "Practice with hands-on exercises",
          ),
          const SizedBox(height: 24),

          // CTA Button
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Session materials coming soon!"),
                  backgroundColor: const Color(0xFF6366F1),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            icon: const Icon(Icons.play_circle_outline),
            label: const Text("Start Learning"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _LearningObjective extends StatelessWidget {
  final String title;
  final String description;

  const _LearningObjective({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle_outline, color: Color(0xFF6366F1)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
          ],
        ),
      ),
    );
  }
}