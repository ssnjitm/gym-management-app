import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  
  const Failure({required this.message, this.statusCode});
  
  @override
  List<Object?> get props => [message, statusCode];
}

// Server-side failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

// Cache/local storage failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}