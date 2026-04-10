import 'package:equatable/equatable.dart';
import '../../domain/entities/staff_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  
  const AuthFailure(this.message);
  
  @override
  List<Object?> get props => [message];
  
  String get userMessage {
    if (message.toLowerCase().contains('invalid') && 
        message.toLowerCase().contains('credentials')) {
      return 'Invalid email or password.';
    }
    if (message.toLowerCase().contains('staff record not found')) {
      return 'Staff record not found. Please contact administrator.';
    }
    if (message.toLowerCase().contains('row-level security')) {
      return 'Access denied. Please contact administrator.';
    }
    if (message.toLowerCase().contains('connection timeout')) {
      return 'Connection timeout. Please check your internet connection.';
    }
    return message;
  }
}

class AuthAuthenticated extends AuthState {
  final Staff staff;
  
  const AuthAuthenticated(this.staff);
  
  @override
  List<Object?> get props => [staff];
}

class AuthUnauthenticated extends AuthState {}