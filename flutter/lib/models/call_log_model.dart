/**
 * Call Log Entity Model
 * DHOLERA REAL ESTATE — Stores call outcome per inquiry per day
 */
class CallLogModel {
  final int    inquiryId;
  final String calledDate; // "yyyy-MM-dd"
  final String status;     // received | pending | no_answer | callback | not_interested
  final String remarks;
  final String? updatedAt;

  const CallLogModel({
    required this.inquiryId,
    required this.calledDate,
    required this.status,
    required this.remarks,
    this.updatedAt,
  });

  factory CallLogModel.fromJson(Map<String, dynamic> json) {
    return CallLogModel(
      inquiryId:  json['inquiry_id'] is int
          ? json['inquiry_id']
          : int.parse(json['inquiry_id'].toString()),
      calledDate: json['called_date'] ?? '',
      status:     json['status']      ?? 'pending',
      remarks:    json['remarks']     ?? '',
      updatedAt:  json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'inquiry_id':  inquiryId,
        'called_date': calledDate,
        'status':      status,
        'remarks':     remarks,
      };

  /// Returns a human-readable label for the status value
  String get statusLabel {
    const map = {
      'received':       '✅ Received',
      'pending':        '🕐 Pending',
      'no_answer':      '📵 No Answer',
      'callback':       '🔁 Callback Requested',
      'not_interested': '❌ Not Interested',
    };
    return map[status] ?? status;
  }
}
