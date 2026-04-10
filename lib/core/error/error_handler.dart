import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'failure.dart';
import '../utils/logger.dart';

class ErrorHandler {
  static Failure handleError(dynamic error, {StackTrace? stackTrace}) {
    AppLogger.error('Error occurred', error, stackTrace);

    if (error is AuthException) {
      return AuthFailure(
        message: _getAuthErrorMessage(error),
        statusCode: _getStatusCodeFromAuthException(error),
      );
    }

    if (error is PostgrestException) {
      return ServerFailure(
        message: _getDatabaseErrorMessage(error),
        code: error.code?.toString(),
        details: {'hint': error.hint, 'details': error.details},
      );
    }

    if (error is StorageException) {
      return CacheFailure(message: error.message);
    }

    if (error is FormatException) {
      return const ServerFailure(message: 'Invalid data format received from server');
    }

    final s = error.toString();
    if (s.contains('SocketException') || s.contains('Connection refused')) {
      return const NetworkFailure(
        message: 'Unable to connect to server. Please check your internet connection.',
      );
    }

    if (s.toLowerCase().contains('timeout')) {
      return TimeoutFailure(
        message: 'Connection timeout. Please try again.',
        timeout: const Duration(seconds: 10),
      );
    }

    return ServerFailure(
      message: s,
      statusCode: 500,
    );
  }

  static int? _getStatusCodeFromAuthException(AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid') && message.contains('credentials')) return 401;
    if (message.contains('too many requests')) return 429;
    if (message.contains('network')) return 503;
    return 400;
  }

  static String _getAuthErrorMessage(AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password')) {
      return 'Invalid email or password. Please try again.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please verify your email address before logging in.';
    }
    if (message.contains('too many requests')) {
      return 'Too many login attempts. Please try again later.';
    }
    if (message.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }
    return error.message;
  }

  static String _getDatabaseErrorMessage(PostgrestException error) {
    if (error.code == '23505') return 'This record already exists.';
    if (error.code == '23503') {
      return 'Cannot perform this operation due to existing dependencies.';
    }
    if (error.code == '42P01') {
      return 'Database configuration error. Please contact support.';
    }
    return error.message;
  }

  static String getUserFriendlyMessage(Failure failure) => failure.userMessage;
}

extension FailureSnackBar on Failure {
  void showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: this is NetworkFailure ? Colors.orange : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}