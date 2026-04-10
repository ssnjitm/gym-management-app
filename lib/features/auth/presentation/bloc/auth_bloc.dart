import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:members_management_app/features/auth/domain/usecases/get_current_staff_usecase.dart';
import 'package:members_management_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:members_management_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:members_management_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:members_management_app/features/auth/presentation/bloc/auth_state.dart';
import '../../../../core/usecase/usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _login;
  final LogoutUseCase _logout;
  final GetCurrentStaffUseCase _getCurrentStaff;
  
  AuthBloc({
    required LoginUseCase login,
    required LogoutUseCase logout,
    required GetCurrentStaffUseCase getCurrentStaff,
  }) : _login = login,
       _logout = logout,
       _getCurrentStaff = getCurrentStaff,
       super(AuthInitial()) {
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthCheckStatusEvent>(_onCheckStatus);
  }
  
  Future<void> _onLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _login(LoginParams(
      email: event.email,
      password: event.password,
    ));
    
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (staff) => emit(AuthAuthenticated(staff)),
    );
  }
  
  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _logout(NoParams());
    
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }
  
  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _getCurrentStaff(NoParams());
    
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (staff) => emit(AuthAuthenticated(staff)),
    );
  }
}