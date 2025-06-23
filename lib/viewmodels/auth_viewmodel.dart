import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // Initialize - check if user is already logged in
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.getCurrentUser();
      _clearError();
    } catch (e) {
      _setError('Error initializing: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        _setError('Email dan password tidak boleh kosong');
        return false;
      }

      if (!_isValidEmail(email)) {
        _setError('Format email tidak valid');
        return false;
      }

      _currentUser = await _authRepository.login(email, password);

      if (_currentUser != null) {
        _clearError();
        return true;
      } else {
        _setError('Email atau password salah');
        return false;
      }
    } catch (e) {
      _setError('Error saat login: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register(
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate input
      if (username.isEmpty ||
          email.isEmpty ||
          password.isEmpty ||
          confirmPassword.isEmpty) {
        _setError('Semua field harus diisi');
        return false;
      }

      if (!_isValidEmail(email)) {
        _setError('Format email tidak valid');
        return false;
      }

      if (password.length < 6) {
        _setError('Password minimal 6 karakter');
        return false;
      }

      if (password != confirmPassword) {
        _setError('Konfirmasi password tidak cocok');
        return false;
      }

      bool result = await _authRepository.register(username, email, password);

      if (result) {
        _clearError();
        return true;
      } else {
        _setError('Email sudah terdaftar atau terjadi kesalahan');
        return false;
      }
    } catch (e) {
      _setError('Error saat register: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authRepository.logout();
      _currentUser = null;
      _clearError();
    } catch (e) {
      _setError('Error saat logout: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Clear error message
  void clearError() {
    _clearError();
  }
}
