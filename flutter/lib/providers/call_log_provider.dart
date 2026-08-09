import 'package:flutter/material.dart';
import '../models/inquiry_model.dart';
import '../models/call_log_model.dart';
import '../services/call_log_service.dart';

/**
 * Call Log Provider — State Management for "Calls Today" Feature
 * DHOLERA REAL ESTATE
 *
 * Logic:
 *   N = total inquiries, ordered by id ASC
 *   cycleLength = ceil(N / 10)
 *   dayIndex    = daysSince(epoch:2026-01-01) % cycleLength
 *   batchStart  = (dayIndex * 10) % N
 *   batch[i]    = allInquiries[(batchStart + i) % N]   ← circular wrap, always 10
 */
class CallLogProvider extends ChangeNotifier {
  final CallLogService _service = CallLogService();

  // ── State ───────────────────────────────────────────────────────────────────
  List<InquiryModel>        _allInquiries     = [];
  List<InquiryModel>        _todaysBatch      = [];
  Map<int, CallLogModel>    _todaysLogs       = {}; // inquiryId → log
  bool                      _isLoading        = false;
  int?                      _savingInquiryId; // Tracks currently saving item
  String?                   _errorMessage;

  // Computed cycle info
  int _dayIndex    = 0;
  int _cycleLength = 1;

  // Fixed epoch: Day 1 of the cycle system
  static final DateTime _epoch = DateTime(2026, 1, 1);

  // ── Getters ─────────────────────────────────────────────────────────────────
  List<InquiryModel>     get todaysBatch    => List.unmodifiable(_todaysBatch);
  Map<int, CallLogModel> get todaysLogs     => Map.unmodifiable(_todaysLogs);
  bool                   get isLoading      => _isLoading;
  bool                   get isSaving       => _savingInquiryId != null;
  int?                   get savingInquiryId=> _savingInquiryId;
  String?                get errorMessage   => _errorMessage;
  int                    get dayIndex       => _dayIndex;
  int                    get cycleLength    => _cycleLength;
  int                    get totalInquiries => _allInquiries.length;

  /// Check if a specific inquiry card is currently saving
  bool isSavingInquiry(int id) => _savingInquiryId == id;

  /// e.g. "Day 3 of 12"
  String get dayLabel => 'Day ${_dayIndex + 1} of $_cycleLength';

  /// Progress 0.0 – 1.0
  double get cycleProgress =>
      _cycleLength > 0 ? (_dayIndex + 1) / _cycleLength : 0.0;

  /// How many contacts in today's batch have been logged today
  int get calledTodayCount {
    if (_todaysBatch.isEmpty) return 0;
    final batchIds = _todaysBatch.map((i) => i.id).toSet();
    return _todaysLogs.values
        .where((l) => batchIds.contains(l.inquiryId) && l.status != 'pending')
        .length;
  }

  /// Compact range label, e.g. "Contacts 21–30" or "All 3 contacts"
  String get batchRangeLabel {
    if (_allInquiries.isEmpty) return '';
    final n = _allInquiries.length;
    if (n <= 10) {
      return 'All $n contacts';
    }
    final start = (_dayIndex * 10) % n;
    final end   = (start + 9) % n;
    if (end >= start) {
      return 'Contacts ${start + 1}–${end + 1}';
    }
    return 'Contacts ${start + 1}–$n + 1–${end + 1}';
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Load all inquiries + today's logs, then compute batch.
  Future<void> loadData({bool silent = false}) async {
    if (!silent) {
      _isLoading    = true;
      _errorMessage = null;
      notifyListeners();
    }
    try {
      final today  = _todayDateString();
      final result = await _service.fetchAllInquiries();
      _allInquiries = result['inquiries'] as List<InquiryModel>;

      _computeCycle();
      _todaysBatch = _computeBatch();

      final logs = await _service.fetchTodaysLogs(today);
      _todaysLogs = { for (final l in logs) l.inquiryId: l };

    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save or update a call log for a single contact.
  Future<bool> saveLog({
    required int    inquiryId,
    required String status,
    required String remarks,
  }) async {
    _savingInquiryId = inquiryId;
    _errorMessage    = null;
    notifyListeners();

    try {
      final today   = _todayDateString();
      final success = await _service.saveCallLog(
        inquiryId:  inquiryId,
        calledDate: today,
        status:     status,
        remarks:    remarks,
      );

      if (success) {
        _todaysLogs[inquiryId] = CallLogModel(
          inquiryId:  inquiryId,
          calledDate: today,
          status:     status,
          remarks:    remarks,
        );
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '');
      return false;
    } finally {
      _savingInquiryId = null;
      notifyListeners();
    }
  }

  /// Returns the saved log for an inquiry (null if not yet logged today).
  CallLogModel? getLogFor(int inquiryId) => _todaysLogs[inquiryId];

  /// Returns true if this inquiry has a non-pending log today.
  bool isCalled(int inquiryId) {
    final log = _todaysLogs[inquiryId];
    return log != null && log.status != 'pending';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Private Helpers ─────────────────────────────────────────────────────────

  void _computeCycle() {
    final n        = _allInquiries.length;
    _cycleLength   = n == 0 ? 1 : (n / 10).ceil();
    final today    = DateTime.now();
    final daysSince = today.difference(_epoch).inDays;
    _dayIndex      = _cycleLength > 0 ? daysSince % _cycleLength : 0;
  }

  /// Returns unique batch items (max 10, or total count if total < 10).
  List<InquiryModel> _computeBatch() {
    final n = _allInquiries.length;
    if (n == 0) return [];
    final count = n < 10 ? n : 10;
    final start = (_dayIndex * 10) % n;
    return List.generate(count, (i) => _allInquiries[(start + i) % n]);
  }

  String _todayDateString() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}
