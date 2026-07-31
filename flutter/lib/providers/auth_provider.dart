import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/storage/secure_storage_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

/**
 * Authentication Provider State Management
 * DHOLERA REAL ESTATE
 */
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _currentUser != null;
  bool get isSuperAdmin => _currentUser?.isSuperAdmin ?? false;
  String? get errorMessage => _errorMessage;

  // Initialize Auth State on Splash Screen
  Future<void> initAuth() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final token = await SecureStorageService.getToken();
      final user = await SecureStorageService.getUser();

      if (token != null && token.isNotEmpty && user != null && user.isActive) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
        await SecureStorageService.clearAll();
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Login Action
  Future<bool> login(String username, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(username, password);
      final String token = result['token'];
      final UserModel user = result['user'];

      await SecureStorageService.saveToken(token);
      await SecureStorageService.saveUser(user);

      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Logout Action
  Future<void> logout() async {
    await _authService.logout();
    await SecureStorageService.clearAll();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
