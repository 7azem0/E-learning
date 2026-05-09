import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // A StreamController or similar could be used to broadcast new unlocks globally,
  // but for simplicity, we'll return a boolean indicating if it was newly unlocked.

  static const Map<String, Map<String, dynamic>> badgeDefinitions = {
    'first_enrollment': {
      'title': 'First Steps',
      'description': 'Enrolled in your first course.',
      'icon': Icons.school,
      'color': Colors.blue,
    },
    'quiz_apprentice': {
      'title': 'Quiz Apprentice',
      'description': 'Completed your first quiz.',
      'icon': Icons.assignment_turned_in,
      'color': Colors.orange,
    },
    'quiz_master': {
      'title': 'Quiz Master',
      'description': 'Completed 5 quizzes.',
      'icon': Icons.emoji_events,
      'color': Colors.purple,
    },
    'perfect_score': {
      'title': 'Perfect Score',
      'description': 'Got 100% on a quiz.',
      'icon': Icons.star,
      'color': Colors.amber,
    },
    'mood_logger': {
      'title': 'Self-Aware',
      'description': 'Logged your learning mood for the first time.',
      'icon': Icons.mood,
      'color': Colors.green,
    },
  };

  Future<bool> checkAndUnlockBadge(String badgeId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    if (!badgeDefinitions.containsKey(badgeId)) return false;

    try {
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('achievements')
          .doc(badgeId);

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        // Already unlocked
        return false;
      }

      await docRef.set({
        'badgeId': badgeId,
        'unlockedAt': Timestamp.now(),
      });

      return true; // Newly unlocked
    } catch (e) {
      debugPrint('Error unlocking badge: $e');
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> getUnlockedBadges() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('achievements')
        .orderBy('unlockedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final badgeId = data['badgeId'] as String;
        final def = badgeDefinitions[badgeId] ?? {};
        return {
          'badgeId': badgeId,
          'title': def['title'] ?? 'Unknown',
          'description': def['description'] ?? '',
          'icon': def['icon'] ?? Icons.help,
          'color': def['color'] ?? Colors.grey,
          'unlockedAt': (data['unlockedAt'] as Timestamp?)?.toDate(),
        };
      }).toList();
    });
  }
}
