import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/authentication_service.dart';

class AnnouncementService {
  static final AnnouncementService _instance = AnnouncementService._internal();
  factory AnnouncementService() => _instance;
  AnnouncementService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getCourseAnnouncements(String courseId) {
    return _firestore
        .collection('courses/$courseId/announcements')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<String> createAnnouncement({
    required String courseId,
    required String message,
  }) async {
    final user = AuthService().currentUser;
    if (user == null || !user.isAdmin) {
      return 'Only instructors can publish announcements';
    }
    if (message.trim().isEmpty) return 'Please enter an announcement';

    try {
      await _firestore.collection('courses/$courseId/announcements').add({
        'message': message.trim(),
        'authorId': user.uid,
        'authorName': user.name,
        'createdAt': Timestamp.now(),
      });
      return 'Success';
    } catch (e) {
      return 'Failed to publish announcement';
    }
  }
}
