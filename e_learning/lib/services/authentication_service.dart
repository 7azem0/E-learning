import 'dart:async';
import 'dart:typed_data';

class User {
  String name;
  String email;
  String password;
  Uint8List? avatar;

  User({
    required this.name,
    required this.email,
    required this.password,
    this.avatar,
  });
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Map<String, User> _users = {};
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<String> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_users.containsKey(email)) return 'Email already exists';
    _users[email] = User(name: name, email: email, password: password);
    return 'Success';
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (!_users.containsKey(email)) return 'Email not registered';
    final user = _users[email]!;
    if (user.password != password) return 'Incorrect password';
    _currentUser = user;
    return 'Success';
  }

  String updateCurrentUser({
    required String name,
    required String email,
    Uint8List? avatar,
  }) {
    if (_currentUser == null) return 'No logged-in user';

    final currentEmail = _currentUser!.email;
    if (email != currentEmail && _users.containsKey(email)) {
      return 'Email already in use';
    }

    final updatedUser = User(
      name: name,
      email: email,
      password: _currentUser!.password,
      avatar: avatar ?? _currentUser!.avatar,
    );

    _users.remove(currentEmail);
    _users[email] = updatedUser;
    _currentUser = updatedUser;
    return 'Success';
  }

  void logout() {
    _currentUser = null;
  }
}