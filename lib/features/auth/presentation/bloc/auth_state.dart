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
}

class AuthAuthenticated extends AuthState {
  final Staff staff;
  
  const AuthAuthenticated(this.staff);
  
  @override
  List<Object?> get props => [staff];
}

class AuthUnauthenticated extends AuthState {}