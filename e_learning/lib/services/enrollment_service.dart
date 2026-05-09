import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/authentication_service.dart';
import '../services/achievement_service.dart';

class EnrollmentService {
  static final EnrollmentService _instance = EnrollmentService._internal();
  factory EnrollmentService() => _instance;
  EnrollmentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _uid => AuthService().currentUser?.uid;

  Stream<bool> isEnrolled(String courseId) {
    final uid = _uid;
    if (uid == null) return Stream.value(false);
    return _firestore
        .collection('courses/$courseId/enrollments')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<String> enroll(String courseId) async {
    final user = AuthService().currentUser;
    if (user == null) return 'User not authenticated';
    try {
      await _firestore
          .collection('courses/$courseId/enrollments')
          .doc(user.uid)
          .set({
            'userId': user.uid,
            'name': user.name,
            'email': user.email,
            'createdAt': Timestamp.now(),
          });
          
      // Check for achievement
      await AchievementService().checkAndUnlockBadge('first_enrollment');
      
      return 'Success';
    } catch (e) {
      return 'Failed to enroll';
    }
  }

  Future<String> leave(String courseId) async {
    final uid = _uid;
    if (uid == null) return 'User not authenticated';
    try {
      await _firestore
          .collection('courses/$courseId/enrollments')
          .doc(uid)
          .delete();
      return 'Success';
    } catch (e) {
      return 'Failed to leave course';
    }
  }
  Future<List<Map<String, dynamic>>> getEnrolledCourses() async {
    final uid = _uid;
    if (uid == null) return [];
    
    try {
      final coursesSnapshot = await _firestore.collection('courses').get();
      final List<Map<String, dynamic>> enrolledCourses = [];
      
      for (var doc in coursesSnapshot.docs) {
        final enrollment = await _firestore
            .collection('courses/${doc.id}/enrollments')
            .doc(uid)
            .get();
            
        if (enrollment.exists) {
          final data = doc.data();
          data['id'] = doc.id;
          enrolledCourses.add(data);
        }
      }
      return enrolledCourses;
    } catch (e) {
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> streamEnrolledCourses() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    
    return _firestore.collection('courses').snapshots().asyncMap((snapshot) async {
      final List<Map<String, dynamic>> enrolledCourses = [];
      for (var doc in snapshot.docs) {
        final enrollment = await _firestore
            .collection('courses/${doc.id}/enrollments')
            .doc(uid)
            .get();
            
        if (enrollment.exists) {
          final data = doc.data();
          data['id'] = doc.id;
          enrolledCourses.add(data);
        }
      }
      return enrolledCourses;
    });
  }

  Future<void> completeLesson(String courseId, String lessonId) async {
    final uid = _uid;
    if (uid == null) return;
    
    await _firestore
        .collection('courses/$courseId/enrollments')
        .doc(uid)
        .collection('completed_lessons')
        .doc(lessonId)
        .set({'completedAt': Timestamp.now()});
  }

  Stream<List<String>> getCompletedLessons(String courseId) {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    
    return _firestore
        .collection('courses/$courseId/enrollments')
        .doc(uid)
        .collection('completed_lessons')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Stream<double> getCourseProgress(String courseId, int totalLessons) {
    if (totalLessons == 0) return Stream.value(0.0);
    return getCompletedLessons(courseId).map((completed) {
      return completed.length / totalLessons;
    });
  }
}
