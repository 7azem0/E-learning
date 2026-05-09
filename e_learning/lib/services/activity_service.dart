import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ActivityService {
  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Log an activity event for the current user.
  Future<void> logActivity({
    required String type,
    String? courseId,
    String? lessonId,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final dateKey = _todayKey();
      await _firestore.collection('activity_logs').add({
        'userId': userId,
        'type': type,
        'courseId': courseId,
        'lessonId': lessonId,
        'date': dateKey,
        'timestamp': Timestamp.now(),
      });
      debugPrint('ActivityService: logged "$type" for $userId on $dateKey');
    } catch (e) {
      debugPrint('ActivityService: failed to log activity: $e');
    }
  }

  /// Returns a map of { 'YYYY-MM-DD' -> activityCount } for the past [days] days.
  /// Filters locally to avoid Firestore composite index requirements.
  Future<Map<String, int>> getActivityMap({int days = 91}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return {};

    try {
      // Only filter by userId — no date filter to avoid composite index
      final snapshot = await _firestore
          .collection('activity_logs')
          .where('userId', isEqualTo: userId)
          .get();

      // Build the set of valid date keys for the window
      final now = DateTime.now();
      final validKeys = <String>{};
      for (int i = 0; i < days; i++) {
        final d = now.subtract(Duration(days: i));
        validKeys.add(
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
        );
      }

      final Map<String, int> counts = {};
      for (var doc in snapshot.docs) {
        final date = doc.data()['date'] as String?;
        if (date != null && validKeys.contains(date)) {
          counts[date] = (counts[date] ?? 0) + 1;
        }
      }

      debugPrint('ActivityService: found ${counts.values.fold(0, (a, b) => a + b)} activities across ${counts.length} days');
      return counts;
    } catch (e) {
      debugPrint('ActivityService: getActivityMap error: $e');
      return {};
    }
  }
}
