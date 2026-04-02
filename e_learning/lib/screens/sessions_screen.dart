import 'package:flutter/material.dart';
import 'session_details_screen.dart';

class SessionsScreen extends StatelessWidget {
  final String courseName;
  const SessionsScreen({super.key, required this.courseName});

  static const Map<String, List<String>> courseSessions = {
    "Programming Fundamentals": ["Variables & Types", "Control Flow", "Functions"],
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
      appBar: AppBar(title: Text("$courseName Sessions")),
      body: ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final sessionTitle = sessions[index];
          return ListTile(
            title: Text(sessionTitle),
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
          );
        },
      ),
    );
  }
}