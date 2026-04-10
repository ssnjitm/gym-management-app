import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  final String? code;
  final dynamic details;
  
  const Failure({
    required this.message,
    this.statusCode,
    this.code,
    this.details,
  });
  
  @override
  List<Object?> get props => [message, statusCode, code, details];

  String get userMessage {
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Authentication failed. Please check your credentials.';
        case 403:
          return 'Access denied. You don\'t have permission.';
        case 404:
          return 'Resource not found.';
        case 408:
          return 'Request timeout. Please try again.';
        case 42501:
          return 'Database access denied. Please contact administrator.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return message;
      }
    }
    return message;
  }
}

// Server-side failures
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
    super.code,
    super.details,
  });
}

// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.statusCode,
  });

  @override
  String get userMessage {
    final lower = message.toLowerCase();
    if (lower.contains('no internet') || lower.contains('connection')) {
      return 'No internet connection. Please check your network.';
    }
    if (lower.contains('timeout')) {
      return 'Connection timeout. Please try again.';
    }
    return message;
  }
}

// Cache/local storage failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode,
    super.code,
    super.details,
  });

  @override
  String get userMessage {
    final lower = message.toLowerCase();
    if (lower.contains('invalid') && lower.contains('credentials')) {
      return 'Invalid email or password.';
    }
    if (lower.contains('staff record not found')) {
      return 'Staff record not found. Please contact administrator.';
    }
    if (lower.contains('row-level security')) {
      return 'Access denied. Please contact administrator.';
    }
    return message;
  }
}

// Validation failures
class ValidationFailure extends Failure {
  final String field;

  const ValidationFailure({
    required this.field,
    required super.message,
  });

  @override
  String get userMessage => '$field: $message';

  @override
  List<Object?> get props => [field, message, statusCode, code, details];
}

// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.statusCode,
  });

  @override
  String get userMessage => 'Data not found: $message';
}

// Timeout failures
class TimeoutFailure extends Failure {
  final Duration timeout;

  const TimeoutFailure({
    required this.timeout,
    required super.message,
  });

  @override
  String get userMessage =>
      'Request timed out after ${timeout.inSeconds} seconds. Please try again.';

  @override
  List<Object?> get props => [timeout, message, statusCode, code, details];
}