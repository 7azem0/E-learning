import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LessonNote {
  final String id;
  final String userId;
  final String content;
  final double? videoTimestamp; // in seconds
  final int? pdfPage;
  final Timestamp createdAt;

  LessonNote({
    required this.id,
    required this.userId,
    required this.content,
    this.videoTimestamp,
    this.pdfPage,
    required this.createdAt,
  });

  factory LessonNote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LessonNote(
      id: doc.id,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      videoTimestamp: (data['videoTimestamp'] as num?)?.toDouble(),
      pdfPage: data['pdfPage'] as int?,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'content': content,
    'videoTimestamp': videoTimestamp,
    'pdfPage': pdfPage,
    'createdAt': createdAt,
  };
}

class NotesService {
  static final NotesService _instance = NotesService._internal();
  factory NotesService() => _instance;
  NotesService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> addNote({
    required String courseId,
    required String sectionId,
    required String lessonId,
    required String content,
    double? videoTimestamp,
    int? pdfPage,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'User not authenticated';

      await _firestore
          .collection('courses/$courseId/sections/$sectionId/lessons/$lessonId/notes')
          .add({
            'userId': user.uid,
            'content': content,
            'videoTimestamp': videoTimestamp,
            'pdfPage': pdfPage,
            'createdAt': Timestamp.now(),
          });

      return 'Success';
    } catch (e) {
      return 'Failed to add note: $e';
    }
  }

  Stream<List<LessonNote>> getMyNotes({
    required String courseId,
    required String sectionId,
    required String lessonId,
  }) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('courses/$courseId/sections/$sectionId/lessons/$lessonId/notes')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => LessonNote.fromFirestore(doc)).toList());
  }

  Future<void> deleteNote(String courseId, String sectionId, String lessonId, String noteId) async {
    await _firestore
        .collection('courses/$courseId/sections/$sectionId/lessons/$lessonId/notes')
        .doc(noteId)
        .delete();
  }
}
