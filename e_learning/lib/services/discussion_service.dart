import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/authentication_service.dart';

class LessonComment {
  final String id;
  final String userId;
  final String userName;
  final bool isAdmin;
  final String userEmail;
  final String text;
  final Timestamp createdAt;

  LessonComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.isAdmin,
    required this.userEmail,
    required this.text,
    required this.createdAt,
  });

  factory LessonComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LessonComment(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      isAdmin: data['isAdmin'] ?? false,
      userEmail: data['userEmail'] ?? '',
      text: data['text'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userName': userName,
    'isAdmin': isAdmin,
    'userEmail': userEmail,
    'text': text,
    'createdAt': createdAt,
  };
}

class DiscussionService {
  static final DiscussionService _instance = DiscussionService._internal();
  factory DiscussionService() => _instance;
  DiscussionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add a comment to a lesson
  Future<String> addComment({
    required String courseId,
    required String sectionId,
    required String lessonId,
    required String text,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not authenticated';

      final authService = AuthService();
      final currentUser = authService.currentUser;
      if (currentUser == null) return 'User data not found';

      await _firestore
          .collection(
            'courses/$courseId/sections/$sectionId/lessons/$lessonId/comments',
          )
          .add({
            'userId': user.uid,
            'userName': currentUser.name.isNotEmpty
                ? currentUser.name
                : 'Anonymous',
            'userEmail': user.email,
            'isAdmin': currentUser.isAdmin,
            'text': text.trim(),
            'createdAt': Timestamp.now(),
          });

      return 'Success';
    } catch (e) {
      return 'Failed to add comment: $e';
    }
  }

  /// Get comments stream for a lesson
  Stream<List<LessonComment>> getComments({
    required String courseId,
    required String sectionId,
    required String lessonId,
  }) {
    return _firestore
        .collection(
          'courses/$courseId/sections/$sectionId/lessons/$lessonId/comments',
        )
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LessonComment.fromFirestore(doc))
              .toList(),
        );
  }

  /// Delete a comment (only by the author or admin)
  Future<String> deleteComment({
    required String courseId,
    required String sectionId,
    required String lessonId,
    required String commentId,
  }) async {
    try {
      final user = _auth.currentUser;
      final currentUser = AuthService().currentUser;
      if (user == null || currentUser == null) return 'User not authenticated';

      final commentRef = _firestore
          .collection(
            'courses/$courseId/sections/$sectionId/lessons/$lessonId/comments',
          )
          .doc(commentId);
      final comment = await commentRef.get();
      if (!comment.exists) return 'Comment not found';

      final data = comment.data() as Map<String, dynamic>;
      final isAuthor = data['userId'] == user.uid;
      if (!isAuthor && !currentUser.isAdmin) {
        return 'You can only delete your own comments';
      }

      await commentRef.delete();
      return 'Success';
    } catch (e) {
      return 'Failed to delete comment: $e';
    }
  }
}
