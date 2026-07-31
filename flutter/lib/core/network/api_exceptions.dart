/**
 * Network Layer Custom Exceptions
 * DHOLERA REAL ESTATE
 */

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message, {super.statusCode, super.errors});
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message, {super.statusCode, super.errors});
}

class ValidationException extends ApiException {
  ValidationException(super.message, {super.statusCode, super.errors});
}

class NetworkTimeoutException extends ApiException {
  NetworkTimeoutException() : super('Connection timed out. Please check your internet connection or backend server.');
}
