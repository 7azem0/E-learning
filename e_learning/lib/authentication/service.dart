class AuthService {
  // Singleton pattern (optional, professional)
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Simulated user database (in-memory)
  final Map<String, String> _users = {}; // email -> password

  // Register method
  Future<String> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network

    if (_users.containsKey(email)) {
      return 'Email already exists';
    } else {
      _users[email] = password;
      return 'Success';
    }
  }

  // Login method
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network

    if (!_users.containsKey(email)) {
      return 'Email not registered';
    } else if (_users[email] != password) {
      return 'Incorrect password';
    } else {
      return 'Success';
    }
  }
}