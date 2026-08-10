import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../models/telecalling_contact_model.dart';
import '../models/call_log_model.dart';

/// Telecalling Contacts Network Service
/// DHOLERA REAL ESTATE
class TelecallingService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches today's rotating 10-day batch & call logs from server
  Future<Map<String, dynamic>> fetchTodayBatch(String date) async {
    final response = await _apiClient.get('${ApiConfig.telecallingToday}?date=$date');
    final data = response['data'] ?? {};

    final rawBatch = data['today_batch'] as List? ?? [];
    final todayBatch = rawBatch.map((item) => TelecallingContactModel.fromJson(item)).toList();

    final rawLogs = data['logs'] as List? ?? [];
    final logsMap = <int, CallLogModel>{};
    for (var l in rawLogs) {
      final log = CallLogModel.fromJson(l);
      logsMap[log.inquiryId] = log; // contact_id mapped to inquiryId field
    }

    return {
      'date': data['date'] ?? date,
      'dayIndex': data['day_index'] ?? 0,
      'cycleLength': data['cycle_length'] ?? 10,
      'totalContacts': data['total_contacts'] ?? 0,
      'dailyTarget': data['daily_target'] ?? 0,
      'todayBatch': todayBatch,
      'logs': logsMap,
    };
  }

  /// Lists all active telecalling contacts with search
  Future<Map<String, dynamic>> fetchContacts({String search = '', int page = 1, int limit = 50}) async {
    final searchUri = '${ApiConfig.telecallingList}?search=${Uri.encodeComponent(search)}&page=$page&limit=$limit';
    final response = await _apiClient.get(searchUri);
    final data = response['data'] ?? {};

    final rawContacts = data['contacts'] as List? ?? [];
    final contacts = rawContacts.map((c) => TelecallingContactModel.fromJson(c)).toList();

    return {
      'contacts': contacts,
      'total': data['pagination']?['total'] ?? contacts.length,
      'page': data['pagination']?['page'] ?? page,
    };
  }

  /// Creates a new telecalling contact
  Future<TelecallingContactModel> createContact({
    required String name,
    required String mobile,
    String city = '',
    String notes = '',
  }) async {
    final response = await _apiClient.post(ApiConfig.telecallingCreate, body: {
      'name': name,
      'mobile': mobile,
      'city': city,
      'notes': notes,
    });
    return TelecallingContactModel.fromJson(response['data']);
  }

  /// Saves call status and remarks for a contact
  Future<void> saveLog({
    required int contactId,
    required String date,
    required String status,
    String remarks = '',
  }) async {
    await _apiClient.post(ApiConfig.telecallingSaveLog, body: {
      'contact_id': contactId,
      'called_date': date,
      'status': status,
      'remarks': remarks,
    });
  }

  /// Atomically moves a telecalling contact to customer_inquiries
  Future<int> moveToInquiry({
    required int contactId,
    required String requirement,
    String notes = '',
  }) async {
    final response = await _apiClient.post(ApiConfig.telecallingMoveToInquiry, body: {
      'contact_id': contactId,
      'requirement': requirement,
      'notes': notes,
    });
    return response['data']?['inquiry_id'] ?? 0;
  }

  /// Deletes a telecalling contact
  Future<void> deleteContact(int contactId) async {
    await _apiClient.post(ApiConfig.telecallingDelete, body: {
      'contact_id': contactId,
    });
  }
}
