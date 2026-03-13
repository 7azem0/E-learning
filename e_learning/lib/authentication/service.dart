import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _loadUsers();
  }

  // Simulated user database (email -> user details Map)
  Map<String, dynamic> _users = {};

  Future<File> get _usersFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/users.json');
  }

  Future<File> get _adminsFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/admins.json');
  }

  Future<void> _loadUsers() async {
    try {
      final file = await _usersFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        _users = Map<String, dynamic>.from(jsonDecode(contents));
      }
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> _loadAdmins() async {
    try {
      final file = await _adminsFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        _allowedAdminEmails = List<String>.from(jsonDecode(contents));
      } else {
        // Create file with default 20 admin emails if it doesn't exist
        _allowedAdminEmails = List.generate(
          20,
          (index) => 'admin${index + 1}@example.com',
        );
        await file.writeAsString(jsonEncode(_allowedAdminEmails));
      }
    } catch (e) {
      print('Error loading admins: $e');
    }
  }

  Future<void> _saveUsers() async {
    try {
      final file = await _usersFile;
      await file.writeAsString(jsonEncode(_users));
    } catch (e) {
      print('Error saving users: $e');
    }
  }

  // List of emails allowed to register as Admin
  List<String> _allowedAdminEmails = [];

  // Register method
  Future<String> registerUser({
    required String name,
    required String email,
    required String password,
    String role = 'User', // default role
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // simulate network
    await _loadUsers(); // ensure latest users data
    await _loadAdmins(); // ensure latest admins data

    if (role == 'Admin' && !_allowedAdminEmails.contains(email)) {
      return 'You are not authorized to register as an Admin';
    }

    if (_users.containsKey(email)) {
      return 'Email already exists';
    } else {
      _users[email] = {
        'name': name,
        'password': password,
        'role': role,
      };
      await _saveUsers();
      return 'Success';
    }
  }

  // Login method
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // simulate network
    await _loadUsers(); // ensure latest data

    if (!_users.containsKey(email)) {
      return 'Email not registered';
    } else if (_users[email]['password'] != password) {
      return 'Incorrect password';
    } else {
      // Returning the role on successful login
      String role = _users[email]['role'] ?? 'User';
      return 'Success:$role';
    }
  }
}