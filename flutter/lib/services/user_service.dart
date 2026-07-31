import '../core/network/api_client.dart';
import '../core/config/api_config.dart';
import '../models/user_model.dart';

/**
 * User Management Service (Super Admin)
 * DHOLERA REAL ESTATE
 */
class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> fetchUsers({int page = 1, int limit = 20, String search = ''}) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _apiClient.get(ApiConfig.usersList, queryParams: queryParams);
    final rawList = response['data']['users'] as List? ?? [];
    final List<UserModel> users = rawList.map((u) => UserModel.fromJson(Map<String, dynamic>.from(u))).toList();

    return {
      'users': users,
      'pagination': response['pagination'],
    };
  }

  Future<UserModel> createUser(String username, String password, String status) async {
    final response = await _apiClient.post(
      ApiConfig.userCreate,
      body: {
        'username': username,
        'password': password,
        'status': status,
      },
    );
    return UserModel.fromJson(response['data']['user']);
  }

  Future<UserModel> updateUser({required int id, String? username, String? password, String? status}) async {
    final Map<String, dynamic> body = {'id': id};
    if (username != null && username.isNotEmpty) body['username'] = username;
    if (password != null && password.isNotEmpty) body['password'] = password;
    if (status != null && status.isNotEmpty) body['status'] = status;

    final response = await _apiClient.post(ApiConfig.userUpdate, body: body);
    return UserModel.fromJson(response['data']['user']);
  }

  Future<void> toggleUserStatus(int id, String status) async {
    await _apiClient.post(
      ApiConfig.userStatus,
      body: {
        'id': id,
        'status': status,
      },
    );
  }

  Future<void> deleteUser(int id) async {
    await _apiClient.post(
      ApiConfig.userDelete,
      body: {'id': id},
    );
  }
}
