import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/config/api_config.dart';
import '../models/inquiry_model.dart';

/**
 * Inquiry State Management Provider
 * DHOLERA REAL ESTATE
 */
class InquiryProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<InquiryModel> _inquiries = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalInquiries = 0;
  String _searchQuery = '';

  List<InquiryModel> get inquiries => List.unmodifiable(_inquiries);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalInquiries => _totalInquiries;
  String get searchQuery => _searchQuery;

  /// Clear any residual error state
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool _isSuccess(dynamic successVal) {
    if (successVal == null) return false;
    if (successVal is bool) return successVal;
    if (successVal is int) return successVal == 1;
    if (successVal is String) return successVal.toLowerCase() == 'true' || successVal == '1';
    return false;
  }

  /// Fetch Inquiry List
  Future<void> fetchInquiries({int page = 1, String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = page;
    if (search != null) _searchQuery = search;
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'page': _currentPage.toString(),
        'limit': '20',
      };
      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }

      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '${ApiConfig.inquiryList}?$queryString';

      final response = await _apiClient.get(endpoint);

      if (_isSuccess(response['success']) && response['data'] != null) {
        _errorMessage = null; // Clear error on success
        final rawList = response['data']['inquiries'] as List? ?? [];
        _inquiries = rawList
            .map((item) => InquiryModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        final pagination = response['pagination'];
        if (pagination != null) {
          _totalPages = pagination['total_pages'] ?? 1;
          _totalInquiries = pagination['total'] ?? _inquiries.length;
        }
      } else {
        _errorMessage = response['message'] ?? 'Failed to retrieve inquiries.';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('ApiException: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create Inquiry
  Future<bool> createInquiry({
    required String name,
    required String city,
    required String mobile,
    String? requirement,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConfig.inquiryCreate,
        body: {
          'customer_name': name,
          'customer_city': city,
          'customer_mobile': mobile,
          'requirement': requirement ?? '',
          'notes': notes ?? '',
        },
      );

      if (_isSuccess(response['success'])) {
        _errorMessage = null; // Clear error on success
        await fetchInquiries(page: 1);
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to record inquiry.';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('ApiException: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete Inquiry
  Future<bool> deleteInquiry(int id) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.inquiryDelete,
        body: {'id': id},
      );

      if (_isSuccess(response['success'])) {
        _errorMessage = null;
        _inquiries.removeWhere((inq) => inq.id == id);
        _totalInquiries = (_totalInquiries - 1).clamp(0, 999999);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to delete inquiry.';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('ApiException: ', '');
      return false;
    }
  }
}
