/**
 * User Entity Model
 * DHOLERA REAL ESTATE
 */
class UserModel {
  final int id;
  final String username;
  final String role;
  final String status;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.role,
    required this.status,
    this.createdAt,
  });

  bool get isSuperAdmin => role == 'super_admin';
  bool get isActive => status == 'active';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      username: json['username'] ?? '',
      role: json['role'] ?? 'user',
      status: json['status'] ?? 'active',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'status': status,
      'created_at': createdAt,
    };
  }
}
