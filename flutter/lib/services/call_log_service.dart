import '../core/network/api_client.dart';
import '../core/config/api_config.dart';
import '../models/call_log_model.dart';
import '../models/inquiry_model.dart';

/// Call Log API Service
/// DHOLERA REAL ESTATE
class CallLogService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch ALL inquiries ordered by id ASC (stable index for batch math).
  /// Returns list of InquiryModel and total count.
  Future<Map<String, dynamic>> fetchAllInquiries() async {
    final response = await _apiClient.get(ApiConfig.inquiryAll);
    if (_isSuccess(response['success']) && response['data'] != null) {
      final rawList = response['data']['inquiries'] as List? ?? [];
      final inquiries = rawList
          .map((item) => InquiryModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      final total = response['data']['total'] as int? ?? inquiries.length;
      return {'inquiries': inquiries, 'total': total};
    }
    throw Exception(response['message'] ?? 'Failed to fetch inquiries.');
  }

  /// Save or update a call log for an inquiry on a given date (upsert).
  Future<bool> saveCallLog({
    required int    inquiryId,
    required String calledDate,
    required String status,
    required String remarks,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.callLogSave,
      body: {
        'inquiry_id':  inquiryId,
        'called_date': calledDate,
        'status':      status,
        'remarks':     remarks,
      },
    );
    return _isSuccess(response['success']);
  }

  /// Fetch all call logs for the given date (admin's logs only).
  Future<List<CallLogModel>> fetchTodaysLogs(String date) async {
    final endpoint = '${ApiConfig.callLogToday}?date=$date';
    final response = await _apiClient.get(endpoint);
    if (_isSuccess(response['success']) && response['data'] != null) {
      final rawList = response['data']['logs'] as List? ?? [];
      return rawList
          .map((item) => CallLogModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  bool _isSuccess(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    if (val is int) return val == 1;
    if (val is String) return val.toLowerCase() == 'true' || val == '1';
    return false;
  }
}
