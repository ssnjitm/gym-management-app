import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart' as app_exceptions;
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final ConnectionChecker connectionChecker;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectionChecker,
  });
  
  @override
  FutureEither<Staff> login({
    required String email,
    required String password,
  }) async {
    if (!await connectionChecker.isConnected) {
      return Left(NetworkFailure(message: AppConstants.noConnectionErrorMessage));
    }
    
    try {
      final staffModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      
      // Save to local storage
      await localDataSource.saveAuthData(
        accessToken: Supabase.instance.client.auth.currentSession?.accessToken ?? '',
        staffId: staffModel.staffId,
        email: email,
      );
      
      return Right(staffModel);
    } 
    on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: AppConstants.serverErrorMessage));
    }
  }
  
  @override
  FutureVoid logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAuthData();
      return const Right(null);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: AppConstants.serverErrorMessage));
    }
  }
  
  @override
  FutureEither<Staff> getCurrentStaff() async {
    try {
      final staffId = localDataSource.getStaffId();
      if (staffId == null) {
        return Left(AuthFailure(message: 'No logged in user found'));
      }
      
      final staffModel = await remoteDataSource.getCurrentStaff(staffId: staffId);
      return Right(staffModel);
    } 
    on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: AppConstants.serverErrorMessage));
    }
  }
  
  @override
  FutureEither<bool> isLoggedIn() async {
    try {
      final isLoggedIn = localDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      return Right(false);
    }
  }
  
  @override
  FutureEither<bool> enableBiometric({required bool enable}) async {
    try {
      await localDataSource.setBiometricEnabled(enable);
      return Right(true);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save biometric preference'));
    }
  }
  
  @override
  FutureEither<bool> isBiometricEnabled() async {
    try {
      final isEnabled = localDataSource.isBiometricEnabled();
      return Right(isEnabled);
    } catch (e) {
      return Right(false);
    }
  }
}
