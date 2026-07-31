import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../storage/secure_storage_service.dart';
import '../../models/app_picked_image.dart';
import 'api_exceptions.dart';

/**
 * Centralized HTTP API Client
 * DHOLERA REAL ESTATE (Cross-Platform Web & Mobile)
 */
class ApiClient {
  final http.Client _client = http.Client();

  // Helper to build headers with Bearer token
  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await SecureStorageService.getToken();
    final Map<String, String> headers = {
      'Accept': 'application/json',
    };

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      headers['X-Auth-Token'] = token;
    }

    return headers;
  }

  // GET Request
  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      Uri uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _getHeaders();
      final response = await _client.get(uri, headers: headers).timeout(ApiConfig.timeoutDuration);
      return _processResponse(response);
    } on TimeoutException {
      throw NetworkTimeoutException();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network unreachable. Please check backend server and connection.');
    }
  }

  // POST Request (JSON)
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders();
      final bodyStr = body != null ? jsonEncode(body) : null;

      final response = await _client.post(uri, headers: headers, body: bodyStr).timeout(ApiConfig.timeoutDuration);
      return _processResponse(response);
    } on TimeoutException {
      throw NetworkTimeoutException();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network unreachable. Please check backend server.');
    }
  }

  // Multipart POST Request (Property Creation & Image Upload — Cross-Platform)
  Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    List<AppPickedImage>? images,
    String fileFieldName = 'images[]',
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      final headers = await _getHeaders(isMultipart: true);
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      if (images != null && images.isNotEmpty) {
        for (var img in images) {
          final multipartFile = http.MultipartFile.fromBytes(
            fileFieldName,
            img.bytes,
            filename: img.name,
          );
          request.files.add(multipartFile);
        }
      }

      final streamedResponse = await request.send().timeout(ApiConfig.timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } on TimeoutException {
      throw NetworkTimeoutException();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network or file upload error: ${e.toString()}');
    }
  }

  // Process & Normalize JSON Responses
  dynamic _processResponse(http.Response response) {
    dynamic jsonResponseBody;
    try {
      jsonResponseBody = jsonDecode(response.body);
    } catch (_) {
      throw ApiException('Invalid JSON response received from backend server.', statusCode: response.statusCode);
    }

    final bool success = jsonResponseBody['success'] == true;
    final String message = jsonResponseBody['message'] ?? 'An unknown error occurred';
    final dynamic data = jsonResponseBody['data'];
    final Map<String, dynamic>? errors = jsonResponseBody['errors'] != null ? Map<String, dynamic>.from(jsonResponseBody['errors']) : null;
    final Map<String, dynamic>? pagination = jsonResponseBody['pagination'] != null ? Map<String, dynamic>.from(jsonResponseBody['pagination']) : null;

    switch (response.statusCode) {
      case 200:
      case 201:
        if (success) {
          return {
            'data': data,
            'message': message,
            'pagination': pagination,
          };
        }
        throw ApiException(message, statusCode: response.statusCode, errors: errors);

      case 401:
        // Unauthorized -> Clear storage
        SecureStorageService.clearAll();
        throw UnauthorizedException(message, statusCode: 401);

      case 403:
        throw ForbiddenException(message, statusCode: 403);

      case 422:
        throw ValidationException(message, statusCode: 422, errors: errors);

      default:
        throw ApiException(message, statusCode: response.statusCode, errors: errors);
    }
  }
}
