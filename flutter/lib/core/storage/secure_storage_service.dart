import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/user_model.dart';

/**
 * Secure Encrypted Storage Service (with In-Memory Token Cache)
 * DHOLERA REAL ESTATE
 */
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';

  // In-Memory Token Cache (guarantees synchronous instant retrieval on Web & Mobile)
  static String? _inMemoryToken;

  // Token Methods
  static Future<void> saveToken(String token) async {
    _inMemoryToken = token;
    try {
      await _storage.write(key: _keyToken, value: token);
    } catch (_) {}
  }

  static Future<String?> getToken() async {
    if (_inMemoryToken != null && _inMemoryToken!.isNotEmpty) {
      return _inMemoryToken;
    }
    try {
      final token = await _storage.read(key: _keyToken);
      if (token != null && token.isNotEmpty) {
        _inMemoryToken = token;
      }
      return token;
    } catch (_) {
      return _inMemoryToken;
    }
  }

  static Future<void> deleteToken() async {
    _inMemoryToken = null;
    try {
      await _storage.delete(key: _keyToken);
    } catch (_) {}
  }

  // User Methods
  static Future<void> saveUser(UserModel user) async {
    final String jsonStr = jsonEncode(user.toJson());
    try {
      await _storage.write(key: _keyUser, value: jsonStr);
    } catch (_) {}
  }

  static Future<UserModel?> getUser() async {
    try {
      final String? jsonStr = await _storage.read(key: _keyUser);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
      return UserModel.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  static Future<void> deleteUser() async {
    try {
      await _storage.delete(key: _keyUser);
    } catch (_) {}
  }

  // Clear Session
  static Future<void> clearAll() async {
    _inMemoryToken = null;
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
