import 'package:flutter/foundation.dart';

/// API Central Configuration
/// DHOLERA REAL ESTATE — Hostinger Live & Local Environment Toggle
class ApiConfig {
  // Live Hostinger Server Base URL
  static const String liveBaseUrl = 'https://emperorsmartsolutions.com/dholerarealestate/php';

  // Local Development Base URLs
  static const String _emulatorBaseUrl = 'http://10.0.2.2/dholera_real_estate/php';
  static const String _localhostBaseUrl = 'http://localhost/dholera_real_estate/php';

  // Live vs Local Environment Switch (Default: true for production build)
  static bool useLiveUrl = true;
  static bool isEmulatorMode = false;

  // Resolves API base URL dynamically
  static String get baseUrl {
    if (useLiveUrl) return liveBaseUrl;
    if (kIsWeb) return _localhostBaseUrl;
    return isEmulatorMode ? _emulatorBaseUrl : _localhostBaseUrl;
  }

  // App Version (Current installed version)
  static const String currentAppVersion = '1.4.3';

  // Endpoint URLs
  static const String versionConfig = '/api/config/version.php';
  static const String login = '/api/auth/login.php';
  static const String logout = '/api/auth/logout.php';

  static const String usersList = '/api/users/list.php';
  static const String userCreate = '/api/users/create.php';
  static const String userUpdate = '/api/users/update.php';
  static const String userStatus = '/api/users/status.php';
  static const String userDelete = '/api/users/delete.php';

  static const String propertiesList = '/api/properties/list.php';
  static const String propertyDetails = '/api/properties/details.php';
  static const String propertyCreate = '/api/properties/create.php';
  static const String propertyUpdate = '/api/properties/update.php';
  static const String propertyDelete = '/api/properties/delete.php';
  static const String propertyExportPdf = '/api/properties/pdf_brochure.php';

  static const String inquiryList      = '/api/inquiries/list.php';
  static const String inquiryAll       = '/api/inquiries/all.php';
  static const String inquiryCreate    = '/api/inquiries/create.php';
  static const String inquiryDelete    = '/api/inquiries/delete.php';
  static const String inquiryExportPdf = '/api/inquiries/export_pdf.php';

  // Legacy Call Logs
  static const String callLogSave  = '/api/inquiries/call_logs/save.php';
  static const String callLogToday = '/api/inquiries/call_logs/today.php';

  // Dedicated Telecalling Contacts & 10-Day Equal Distribution Endpoints
  static const String telecallingList          = '/api/telecalling/list.php';
  static const String telecallingCreate        = '/api/telecalling/create.php';
  static const String telecallingToday         = '/api/telecalling/today.php';
  static const String telecallingSaveLog       = '/api/telecalling/save_log.php';
  static const String telecallingMoveToInquiry = '/api/telecalling/move_to_inquiry.php';
  static const String telecallingDelete        = '/api/telecalling/delete.php';

  // Network Timeout duration (15 seconds)
  static const Duration timeoutDuration = Duration(seconds: 15);
}
