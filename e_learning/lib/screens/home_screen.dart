// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../widgets/menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("EduHub", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      drawer:  Menu(),
      body: ListView(
        children: [
          // Hero Section with Gradient
          Container(
            height: screenHeight * 0.35,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  "Learn Computer\nScience",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Start your journey in programming, AI, and data science.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 24),
                // Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/courses');
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Explore Courses"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Featured Courses Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Popular Courses",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/courses');
                      },
                      child: Text(
                        "View All",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF6366F1),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Course Cards
                const CourseCardItem(
                  icon: Icons.code,
                  title: "Programming",
                  description: "Learn to code",
                  color: Color(0xFF6366F1),
                ),
                const SizedBox(height: 12),
                const CourseCardItem(
                  icon: Icons.data_usage,
                  title: "Data Structures",
                  description: "Master DSA",
                  color: Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 12),
                CourseCardItem(
                  title: "Algorithms",   // ✅ REQUIRED
                  icon: Icons.psychology, // also fixed icon
                  description: "Problem solving",
                  color: const Color(0xFF06B6D4),
                  ),
                const SizedBox(height: 12),
                const CourseCardItem(
                  icon: Icons.storage,
                  title: "Database Systems",
                  description: "Data management",
                  color: Color(0xFF10B981),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
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