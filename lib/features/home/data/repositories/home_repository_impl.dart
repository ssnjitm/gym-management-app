import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  
  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.connectionChecker,
  });
  
  @override
  FutureEither<DashboardStats> getDashboardStats(String gymId) async {
    if (!await connectionChecker.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    
    try {
      final stats = await remoteDataSource.getDashboardStats(gymId);
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  FutureEither<List<RecentActivity>> getRecentActivities(String gymId) async {
    if (!await connectionChecker.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    
    try {
      final activities = await remoteDataSource.getRecentActivities(gymId);
      final recentActivities = activities.map((activity) => RecentActivity(
        id: activity['id'],
        memberName: activity['member_name'],
        action: activity['action'],
        time: activity['time'],
        thumbnail: activity['thumbnail'],
      )).toList();
      return Right(recentActivities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  FutureEither<List<ExpiringMember>> getExpiringMembers(String gymId) async {
    if (!await connectionChecker.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    
    try {
      final expiring = await remoteDataSource.getExpiringMembers(gymId);
      final expiringMembers = expiring.map((member) => ExpiringMember(
        memberId: member['member_id'],
        memberName: member['member_name'],
        phone: member['phone'],
        packageName: member['package_name'],
        expiryDate: member['expiry_date'],
        daysLeft: member['days_left'],
      )).toList();
      return Right(expiringMembers);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  FutureEither<List<Map<String, dynamic>>> getTodayAttendance(String gymId) async {
    if (!await connectionChecker.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    
    try {
      final attendance = await remoteDataSource.getTodayAttendance(gymId);
      return Right(attendance);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}