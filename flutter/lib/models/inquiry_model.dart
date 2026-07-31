/**
 * Customer Inquiry Entity Model
 * DHOLERA REAL ESTATE — 4 Core Fields: Name, City, Mobile, Requirement + Notes
 */
class InquiryModel {
  final int id;
  final String customerName;
  final String customerCity;
  final String customerMobile;
  final String? requirement;
  final String? notes;
  final String? creatorName;
  final String? createdAt;

  InquiryModel({
    required this.id,
    required this.customerName,
    required this.customerCity,
    required this.customerMobile,
    this.requirement,
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
      requirement: json['requirement'],
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
      'requirement': requirement,
      'notes': notes,
      'creator_name': creatorName,
      'created_at': createdAt,
    };
  }
}
