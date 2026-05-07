import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/authentication_service.dart';

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
}
