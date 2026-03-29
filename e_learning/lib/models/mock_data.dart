import 'user_role.dart';

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String imageUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.imageUrl = 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?q=80&w=150&h=150&fit=crop',
  });
}

class Course {
  final String id;
  final String title;
  final String instructorName;
  final double price;
  final double rating;
  final int studentsEnrolled;
  final String imageUrl;
  final String description;
  final double progress;

  Course({
    required this.id,
    required this.title,
    required this.instructorName,
    required this.price,
    this.rating = 4.5,
    this.studentsEnrolled = 0,
    this.imageUrl = 'https://images.unsplash.com/photo-1633356122544-f134324ef6db?q=80&w=300&h=150&fit=crop',
    this.description = 'Learn the basics and advanced topics in this comprehensive course.',
    this.progress = 0.0,
  });
}

class MockData {
  static final List<User> users = [
    User(id: '1', name: 'Ahmed Hassan', email: 'student@test.com', role: UserRole.student),
    User(id: '2', name: 'Yasmine Ali', email: 'instructor@test.com', role: UserRole.instructor),
    User(id: '3', name: 'Mostafa Kamal', email: 'admin@test.com', role: UserRole.admin),
  ];

  static final List<Course> courses = [
    Course(
      id: 'c1',
      title: 'Flutter for Beginners',
      instructorName: 'Yasmine Ali',
      price: 49.99,
      rating: 4.8,
      studentsEnrolled: 1240,
      imageUrl: 'https://storage.googleapis.com/cms-storage-bucket/70760bf1e88b184bb1bc.png',
      description: 'Start your mobile dev journey with Flutter.',
      progress: 0.3,
    ),
    Course(
      id: 'c2',
      title: 'Advanced UI/UX Design',
      instructorName: 'Nour El-Din',
      price: 89.99,
      rating: 4.9,
      studentsEnrolled: 850,
      imageUrl: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?q=80&w=2000&auto=format&fit=crop',
      description: 'Master Figma and modern design principles.',
      progress: 0.8,
    ),
    Course(
      id: 'c3',
      title: 'Python Data Science',
      instructorName: 'Dr. Kareem Magdy',
      price: 199.99,
      rating: 4.6,
      studentsEnrolled: 3020,
      imageUrl: 'https://images.unsplash.com/photo-1526379095098-d400fd0bf935?q=80&w=2000&auto=format&fit=crop',
      description: 'Learn Python, Pandas, and Machine Learning.',
      progress: 0.0,
    ),
    Course(
      id: 'c4',
      title: 'Web Dev Bootcamp',
      instructorName: 'Tarek Mansour',
      price: 120.00,
      rating: 4.7,
      studentsEnrolled: 5000,
      imageUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?q=80&w=2000&auto=format&fit=crop',
      description: 'HTML, CSS, JS, Node, and React basics.',
      progress: 0.0,
    ),
  ];
}
