import 'package:flutter/material.dart';
import 'authentication/screens/register_screen.dart';
import 'authentication/screens/login.dart';
import 'student/student_dashboard.dart';
import 'instructor/instructor_dashboard.dart';
import 'admin/admin_dashboard.dart';

void main() {
  runApp(const ELearningApp());
}

class ELearningApp extends StatelessWidget {
  const ELearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Learning',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
          secondary: Colors.teal,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),

      // Initial screen
      initialRoute: '/login',

      // App navigation routes
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/student_dashboard': (context) => const StudentDashboard(),
        '/instructor_dashboard': (context) => const InstructorDashboard(),
        '/admin_dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}
