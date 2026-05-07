import 'dart:async';

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

  String _nestedCommentsPath({
    required String courseId,
    required String sectionId,
    required String lessonId,
  }) {
    return 'courses/$courseId/sections/$sectionId/lessons/$lessonId/comments';
  }

  String _sharedCommentsPath(String lessonId) {
    return 'lessonDiscussions/$lessonId/comments';
  }

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

      final commentRef = _firestore
          .collection(
            _nestedCommentsPath(
              courseId: courseId,
              sectionId: sectionId,
              lessonId: lessonId,
            ),
          )
          .doc();
      final commentData = {
        'courseId': courseId,
        'sectionId': sectionId,
        'lessonId': lessonId,
        'userId': user.uid,
        'userName': currentUser.name.isNotEmpty
            ? currentUser.name
            : 'Anonymous',
        'userEmail': user.email,
        'isAdmin': currentUser.isAdmin,
        'text': text.trim(),
        'createdAt': Timestamp.now(),
      };

      await commentRef.set(commentData);
      try {
        await _firestore
            .collection(_sharedCommentsPath(lessonId))
            .doc(commentRef.id)
            .set(commentData);
      } catch (_) {
        // Keep the original lesson-scoped discussion path as the source of truth.
      }

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
    final controller = StreamController<List<LessonComment>>();
    final nestedComments = <String, LessonComment>{};
    final sharedComments = <String, LessonComment>{};

    void emitComments() {
      final commentsById = <String, LessonComment>{
        ...nestedComments,
        ...sharedComments,
      };
      final comments = commentsById.values.toList()
        ..sort((a, b) => a.createdAt.toDate().compareTo(b.createdAt.toDate()));
      controller.add(comments);
    }

    final nestedSubscription = _firestore
        .collection(
          _nestedCommentsPath(
            courseId: courseId,
            sectionId: sectionId,
            lessonId: lessonId,
          ),
        )
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
          nestedComments
            ..clear()
            ..addEntries(
              snapshot.docs.map(
                (doc) => MapEntry(doc.id, LessonComment.fromFirestore(doc)),
              ),
            );
          emitComments();
        }, onError: (_) => emitComments());

    final sharedSubscription = _firestore
        .collection(_sharedCommentsPath(lessonId))
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
          sharedComments
            ..clear()
            ..addEntries(
              snapshot.docs.map(
                (doc) => MapEntry(doc.id, LessonComment.fromFirestore(doc)),
              ),
            );
          emitComments();
        }, onError: (_) => emitComments());

    controller.onCancel = () async {
      await nestedSubscription.cancel();
      await sharedSubscription.cancel();
    };

    return controller.stream;
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
            _nestedCommentsPath(
              courseId: courseId,
              sectionId: sectionId,
              lessonId: lessonId,
            ),
          )
          .doc(commentId);
      final comment = await commentRef.get();
      final sharedCommentRef = _firestore
          .collection(_sharedCommentsPath(lessonId))
          .doc(commentId);
      final sharedComment = await sharedCommentRef.get();
      if (!comment.exists && !sharedComment.exists) return 'Comment not found';

      final data =
          (comment.exists ? comment.data() : sharedComment.data())
              as Map<String, dynamic>;
      final isAuthor = data['userId'] == user.uid;
      if (!isAuthor && !currentUser.isAdmin) {
        return 'You can only delete your own comments';
      }

      if (comment.exists) {
        await commentRef.delete();
      }
      if (sharedComment.exists) {
        try {
          await sharedCommentRef.delete();
        } catch (_) {}
      }
      return 'Success';
    } catch (e) {
      return 'Failed to delete comment: $e';
    }
  }
}
