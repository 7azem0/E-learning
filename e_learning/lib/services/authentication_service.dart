// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

class User {
  final String uid;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;

  User({
    required this.uid,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Uint8List? get avatar => null;

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.now(),
    };
  }
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  firebase_auth.User? get firebaseUser => _firebaseAuth.currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => firebaseUser != null;

  /// Listen to authentication state changes
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Initialize and load current user
  Future<void> initialize() async {
    if (firebaseUser != null) {
      await _loadUserData(firebaseUser!.uid);
    }
  }

  /// Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = User.fromFirestore(doc);
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  /// Register new user with Firebase
  Future<String> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create Firebase Auth user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Create user document in Firestore
      final newUser = User(
        uid: userCredential.user!.uid,
        name: name.trim(),
        email: email.trim(),
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set(newUser.toFirestore());

      _currentUser = newUser;
      return 'Success';
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email already exists';
      } else if (e.code == 'weak-password') {
        return 'Password is too weak';
      }
      return e.message ?? 'Registration failed';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  /// Login user with Firebase
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _loadUserData(userCredential.user!.uid);
      return 'Success';
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Email not registered';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password';
      }
      return e.message ?? 'Login failed';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  /// Update current user profile
  Future<String> updateCurrentUser({
    required String name,
    required String email,
    String? avatarUrl, Uint8List? avatar,
  }) async {
    try {
      if (firebaseUser == null) return 'No logged-in user';

      // Update email if changed
      if (email != firebaseUser!.email) {
        await firebaseUser!.verifyBeforeUpdateEmail(email.trim());
      }

      // Update user document in Firestore
      final updatedUser = User(
        uid: firebaseUser!.uid,
        name: name.trim(),
        email: email.trim(),
        avatarUrl: avatarUrl,
        createdAt: _currentUser?.createdAt ?? DateTime.now(),
      );

      await _firestore.collection('users').doc(firebaseUser!.uid).update(updatedUser.toFirestore());
      _currentUser = updatedUser;
      return 'Success';
    } catch (e) {
      return 'Failed to update profile';
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
  }

  /// Reset password
  Future<String> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return 'Success';
    } on firebase_auth.FirebaseAuthException catch (e) {
      return e.message ?? 'Password reset failed';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }
}