/**
 * Customer Inquiry Entity Model
 * DHOLERA REAL ESTATE
 */
class InquiryModel {
  final int id;
  final String customerName;
  final String customerCity;
  final String customerMobile;
  final String? notes;
  final String? creatorName;
  final String? createdAt;

  InquiryModel({
    required this.id,
    required this.customerName,
    required this.customerCity,
    required this.customerMobile,
    this.notes,
    this.creatorName,
    this.createdAt,
  });

  factory InquiryModel.fromJson(Map<String, dynamic> json) {
    return InquiryModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      customerName: json['customer_name'] ?? '',
      customerCity: json['customer_city'] ?? '',
      customerMobile: json['customer_mobile'] ?? '',
      notes: json['notes'],
      creatorName: json['creator_name'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_city': customerCity,
      'customer_mobile': customerMobile,
      'notes': notes,
      'creator_name': creatorName,
      'created_at': createdAt,
    };
  }
}
