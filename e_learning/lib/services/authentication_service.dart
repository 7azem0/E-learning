import 'dart:async';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Map<String, String> _users = {};

  Future<String> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (_users.containsKey(email)) return 'Email already exists';
    _users[email] = password;
    return 'Success';
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (!_users.containsKey(email)) return 'Email not registered';
    if (_users[email] != password) return 'Incorrect password';
    return 'Success';
  }

  void logout() {}
}