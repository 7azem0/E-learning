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

  Map<String, dynamic> _users = {};

  Future<File?> get _usersFile async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return File('${directory.path}/users.json');
    } catch (e) {
      return null;
    }
  }

  Future<File?> get _adminsFile async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return File('${directory.path}/admins.json');
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadUsers() async {
    try {
      final file = await _usersFile;
      if (file != null && await file.exists()) {
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
      if (file != null && await file.exists()) {
        final contents = await file.readAsString();
        _allowedAdminEmails = List<String>.from(jsonDecode(contents));
      } else {
        _allowedAdminEmails = List.generate(
          20,
          (index) => 'admin${index + 1}@example.com',
        );
        if (file != null) {
          await file.writeAsString(jsonEncode(_allowedAdminEmails));
        }
      }
    } catch (e) {
      print('Error loading admins: $e');
    }
  }

  Future<void> _saveUsers() async {
    try {
      final file = await _usersFile;
      if (file != null) {
        await file.writeAsString(jsonEncode(_users));
      }
    } catch (e) {
      print('Error saving users: $e');
    }
  }

  List<String> _allowedAdminEmails = [];

  Future<String> registerUser({
    required String name,
    required String email,
    required String password,
    String role = 'User', 
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); 
    await _loadUsers(); 
    await _loadAdmins(); 

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

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); 
    await _loadUsers(); // ensure latest data

    if (!_users.containsKey(email)) {
      return 'Email not registered';
    } else if (_users[email]['password'] != password) {
      return 'Incorrect password';
    } else {
      String role = _users[email]['role'] ?? 'User';
      return 'Success:$role';
    }
  }
}