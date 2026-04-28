// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'session_details_screen.dart';

class SessionsScreen extends StatelessWidget {
  final String courseName;
  const SessionsScreen({super.key, required this.courseName});

  static const Map<String, List<String>> courseSessions = {
    "Programming": ["Variables & Types", "Control Flow", "Functions"],
    "Data Structures": ["Arrays & Lists", "Stacks & Queues", "Trees & Graphs"],
    "Algorithms": ["Sorting", "Searching", "Dynamic Programming"],
    "Database Systems": ["SQL Basics", "Joins", "Transactions"],
    "Operating Systems": ["Processes", "Threads", "Memory Management"],
    "Computer Networks": ["TCP/IP", "HTTP Protocol", "DNS"],
    "Artificial Intelligence": ["Intro to AI", "Search Algorithms", "Knowledge Representation"],
    "Machine Learning": ["Supervised Learning", "Unsupervised Learning", "Model Evaluation"],
    "Cybersecurity": ["Network Security", "Cryptography", "Ethical Hacking"],
  };

  @override
  Widget build(BuildContext context) {
    final List<String> sessions = courseSessions[courseName] ?? [];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "$courseName Sessions",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final sessionTitle = sessions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6366F1).withOpacity(0.05),
                      const Color(0xFF8B5CF6).withOpacity(0.05),
                    ],
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    sessionTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  subtitle: Text(
                    "Learn about $sessionTitle",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF6366F1)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SessionDetailsScreen(
                          courseName: courseName,
                          sessionTitle: sessionTitle,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}