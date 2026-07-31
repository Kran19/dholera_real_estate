import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

/**
 * User Management Provider State Management
 * DHOLERA REAL ESTATE
 */
class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsers = 0;
  String _searchQuery = '';

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalUsers => _totalUsers;

  Future<void> fetchUsers({bool refresh = false, String search = ''}) async {
    if (refresh) {
      _currentPage = 1;
      _users.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    _searchQuery = search;
    notifyListeners();

    try {
      final res = await _userService.fetchUsers(page: _currentPage, limit: 20, search: _searchQuery);
      final List<UserModel> fetched = res['users'];
      final Map<String, dynamic>? pagination = res['pagination'];

      if (refresh || _currentPage == 1) {
        _users = fetched;
      } else {
        _users.addAll(fetched);
      }

      if (pagination != null) {
        _totalPages = pagination['total_pages'] ?? 1;
        _totalUsers = pagination['total'] ?? _users.length;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(String username, String password, String status) async {
    try {
      final newUser = await _userService.createUser(username, password, status);
      _users.insert(0, newUser);
      _totalUsers++;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser({required int id, String? username, String? password, String? status}) async {
    try {
      final updated = await _userService.updateUser(id: id, username: username, password: password, status: status);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleUserStatus(int id, String newStatus) async {
    try {
      await _userService.toggleUserStatus(id, newStatus);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        final u = _users[index];
        _users[index] = UserModel(
          id: u.id,
          username: u.username,
          role: u.role,
          status: newStatus,
          createdAt: u.createdAt,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      await _userService.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      _totalUsers = max(0, _totalUsers - 1);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  int max(int a, int b) => a > b ? a : b;
}
