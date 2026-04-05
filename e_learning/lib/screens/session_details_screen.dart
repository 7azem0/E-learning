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
      appBar: AppBar(title: Text("$sessionTitle - $courseName")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sessionTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              "Content for $sessionTitle of $courseName will appear here.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}