import '../core/network/api_client.dart';
import '../core/config/api_config.dart';
import '../models/user_model.dart';

/**
 * Authentication Network Service
 * DHOLERA REAL ESTATE
 */
class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _apiClient.post(
      ApiConfig.login,
      body: {
        'username': username,
        'password': password,
      },
    );

    final data = response['data'];
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user']);

    return {
      'token': token,
      'user': user,
      'message': response['message'],
    };
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConfig.logout);
    } catch (_) {
      // Ignore errors on logout network call
    }
  }
}
