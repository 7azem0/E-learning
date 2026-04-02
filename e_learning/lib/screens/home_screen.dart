import 'package:flutter/material.dart';
import '../widgets/menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      drawer: const Menu(),
      body: ListView(
        children: [
          ///Hero Section
          Container(
            height: screenHeight * 0.5, 
            width: double.infinity,
            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title
                Text(
                  "Learn Computer Science",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Text(
                  "Start your journey in programming, AI, and data science.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                const SizedBox(height: 20),

                /// Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/courses');
                  },
                  child: const Text("Start Learning"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ///Courses
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Courses We Offer",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                /// List of CS Courses
                const CourseItem(title: "Programming"),
                const CourseItem(title: "Data Structures"),
                const CourseItem(title: "Algorithms"),
                const CourseItem(title: "Database Systems"),
                const CourseItem(title: "Operating Systems"),
                const CourseItem(title: "Computer Networks"),
                const CourseItem(title: "Artificial Intelligence"),
                const CourseItem(title: "Machine Learning"),
                const CourseItem(title: "Cybersecurity"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//Reusable Course Item Widget
class CourseItem extends StatelessWidget {
  final String title;

  const CourseItem({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.book),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}