/// Telecalling Contact Data Model
/// DHOLERA REAL ESTATE
class TelecallingContactModel {
  final int id;
  final String name;
  final String mobile;
  final String city;
  final String notes;
  final String status;
  final String createdAt;

  TelecallingContactModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.city = '',
    this.notes = '',
    this.status = 'pending',
    this.createdAt = '',
  });

  factory TelecallingContactModel.fromJson(Map<String, dynamic> json) {
    return TelecallingContactModel(
      id: (json['id'] is int) ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'city': city,
      'notes': notes,
      'status': status,
      'created_at': createdAt,
    };
  }

  TelecallingContactModel copyWith({
    int? id,
    String? name,
    String? mobile,
    String? city,
    String? notes,
    String? status,
    String? createdAt,
  }) {
    return TelecallingContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      city: city ?? this.city,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
