class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  ServerException(this.message, {this.statusCode});
  
  @override
  String toString() => 'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  
  AuthException(this.message, {this.statusCode});
  
  @override
  String toString() => 'AuthException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class TimeoutException implements Exception {
  final String message;
  final Duration timeout;
  
  TimeoutException(this.message, this.timeout);
  
  @override
  String toString() => 'TimeoutException: $message (Timeout: ${timeout.inSeconds}s)';
}

class ValidationException implements Exception {
  final String field;
  final String message;
  
  ValidationException(this.field, this.message);
  
  @override
  String toString() => 'ValidationException: $field - $message';
}