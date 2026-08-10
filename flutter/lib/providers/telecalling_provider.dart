import 'package:flutter/material.dart';
import '../models/telecalling_contact_model.dart';
import '../models/call_log_model.dart';
import '../services/telecalling_service.dart';

/// Telecalling Provider — State Management for Telecalling Contacts & 10-Day Rotation System
/// DHOLERA REAL ESTATE
class TelecallingProvider extends ChangeNotifier {
  final TelecallingService _service = TelecallingService();

  // ── State ───────────────────────────────────────────────────────────────────
  List<TelecallingContactModel> _todaysBatch     = [];
  List<TelecallingContactModel> _allContacts     = [];
  Map<int, CallLogModel>        _todaysLogs      = {}; // contactId → log
  bool                          _isLoading       = false;
  int?                          _savingContactId;
  String?                       _errorMessage;

  int _totalContacts = 0;
  int _dailyTarget   = 0;
  int _dayIndex      = 0;
  int _cycleLength   = 10;
  String _selectedDate = '';

  // ── Getters ─────────────────────────────────────────────────────────────────
  List<TelecallingContactModel> get todaysBatch    => List.unmodifiable(_todaysBatch);
  List<TelecallingContactModel> get allContacts    => List.unmodifiable(_allContacts);
  Map<int, CallLogModel>        get todaysLogs     => Map.unmodifiable(_todaysLogs);
  bool                          get isLoading      => _isLoading;
  bool                          get isSaving       => _savingContactId != null;
  int?                          get savingContactId=> _savingContactId;
  String?                       get errorMessage   => _errorMessage;
  int                           get totalContacts  => _totalContacts;
  int                           get dailyTarget    => _dailyTarget;
  int                           get dayIndex       => _dayIndex;
  int                           get cycleLength    => _cycleLength;

  /// e.g. "Day 3 of 10"
  String get dayLabel => 'Day ${_dayIndex + 1} of $_cycleLength';

  /// How many contacts in today's batch have been logged today
  int get calledTodayCount {
    if (_todaysBatch.isEmpty) return 0;
    final batchIds = _todaysBatch.map((c) => c.id).toSet();
    return _todaysLogs.values
        .where((l) => batchIds.contains(l.inquiryId) && l.status != 'pending')
        .length;
  }

  bool isSavingContact(int id) => _savingContactId == id;

  /// Fetches today's batch using 10-day rotation math
  Future<void> fetchTodayBatch({String? date}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final dateStr = date ?? _formatDate(DateTime.now());
    _selectedDate = dateStr;

    try {
      final res = await _service.fetchTodayBatch(dateStr);
      _dayIndex      = res['dayIndex'] ?? 0;
      _cycleLength   = res['cycleLength'] ?? 10;
      _totalContacts = res['totalContacts'] ?? 0;
      _dailyTarget   = res['dailyTarget'] ?? 0;
      _todaysBatch   = res['todayBatch'] ?? [];
      _todaysLogs    = res['logs'] ?? {};
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lists all contacts for manager list view
  Future<void> fetchContacts({String search = ''}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _service.fetchContacts(search: search);
      _allContacts = res['contacts'] ?? [];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new contact and refreshes batch
  Future<bool> createContact({
    required String name,
    required String mobile,
    String city = '',
    String notes = '',
  }) async {
    _errorMessage = null;
    try {
      await _service.createContact(name: name, mobile: mobile, city: city, notes: notes);
      await fetchTodayBatch(date: _selectedDate.isNotEmpty ? _selectedDate : null);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Saves call status & remarks for a contact
  Future<bool> saveLog({
    required int contactId,
    required String status,
    String remarks = '',
  }) async {
    _savingContactId = contactId;
    _errorMessage = null;
    notifyListeners();

    final dateStr = _selectedDate.isNotEmpty ? _selectedDate : _formatDate(DateTime.now());

    try {
      await _service.saveLog(contactId: contactId, date: dateStr, status: status, remarks: remarks);

      _todaysLogs[contactId] = CallLogModel(
        inquiryId: contactId,
        calledDate: dateStr,
        status: status,
        remarks: remarks,
        updatedAt: DateTime.now().toIso8601String(),
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _savingContactId = null;
      notifyListeners();
    }
  }

  /// Atomically moves a contact to customer_inquiries
  Future<bool> moveToInquiry({
    required int contactId,
    required String requirement,
    String notes = '',
  }) async {
    _savingContactId = contactId;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.moveToInquiry(contactId: contactId, requirement: requirement, notes: notes);
      // Remove contact from today's batch
      _todaysBatch.removeWhere((c) => c.id == contactId);
      _todaysLogs.remove(contactId);
      _totalContacts = _totalContacts > 0 ? _totalContacts - 1 : 0;
      _dailyTarget = _totalContacts > 0 ? (_totalContacts / _cycleLength).ceil() : 0;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _savingContactId = null;
      notifyListeners();
    }
  }

  /// Deletes a contact
  Future<bool> deleteContact(int contactId) async {
    _errorMessage = null;
    try {
      await _service.deleteContact(contactId);
      _todaysBatch.removeWhere((c) => c.id == contactId);
      _allContacts.removeWhere((c) => c.id == contactId);
      _todaysLogs.remove(contactId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
