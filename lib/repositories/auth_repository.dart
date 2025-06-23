import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/database_helper.dart';

class AuthRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  static const String _currentUserKey = 'current_user_id';

  // Register new user
  Future<bool> register(String username, String email, String password) async {
    try {
      // Check if user already exists
      User? existingUser = await _databaseHelper.getUserByEmail(email);
      if (existingUser != null) {
        return false; // User already exists
      }

      // Hash password
      String hashedPassword = _hashPassword(password);

      // Create new user
      User newUser = User(
        username: username,
        email: email,
        password: hashedPassword,
        createdAt: DateTime.now(),
      );

      int userId = await _databaseHelper.insertUser(newUser);
      return userId > 0;
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  // Login user
  Future<User?> login(String email, String password) async {
    try {
      User? user = await _databaseHelper.getUserByEmail(email);

      if (user != null && _verifyPassword(password, user.password)) {
        // Save user session
        await _saveUserSession(user.id!);
        return user;
      }

      return null;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Get current logged in user
  Future<User?> getCurrentUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt(_currentUserKey);

      if (userId != null) {
        return await _databaseHelper.getUserById(userId);
      }

      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    User? user = await getCurrentUser();
    return user != null;
  }

  // Save user session
  Future<void> _saveUserSession(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentUserKey, userId);
  }

  // Hash password using SHA256
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Verify password
  bool _verifyPassword(String password, String hashedPassword) {
    return _hashPassword(password) == hashedPassword;
  }
}
