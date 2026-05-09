import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/achievement_service.dart';

class MoodTrackingService {
  static final MoodTrackingService _instance = MoodTrackingService._internal();
  factory MoodTrackingService() => _instance;
  MoodTrackingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Log a new mood
  Future<String> logMood(int moodValue, String note) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not authenticated';

      // moodValue scale: 1 (Sad/Tired) to 5 (Great/Energetic)
      await _firestore.collection('learning_moods').add({
        'userId': user.uid,
        'moodValue': moodValue,
        'note': note,
        'timestamp': Timestamp.now(),
      });

      await AchievementService().checkAndUnlockBadge('mood_logger');

      return 'Success';
    } catch (e) {
      return 'Failed to log mood: $e';
    }
  }

  // Check if the user has already logged a mood today
  Future<bool> hasLoggedMoodToday() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final snapshot = await _firestore
          .collection('learning_moods')
          .where('userId', isEqualTo: user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get mood history (stream)
  Stream<QuerySnapshot> getMoodHistory() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('learning_moods')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }
}
