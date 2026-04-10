import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/attendance_entities.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl({required this.remoteDataSource});

  @override
  FutureEither<void> checkIn({required String gymId, required String memberId}) async {
    try {
      await remoteDataSource.checkIn(gymId: gymId, memberId: memberId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to check-in: $e', statusCode: 500));
    }
  }

  @override
  FutureEither<void> checkOut({required String attendanceId}) async {
    try {
      await remoteDataSource.checkOut(attendanceId: attendanceId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to check-out: $e', statusCode: 500));
    }
  }

  @override
  FutureEither<List<AttendanceRecord>> getTodayAttendance({required String gymId}) async {
    try {
      final models = await remoteDataSource.getTodayAttendance(gymId: gymId);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load attendance: $e', statusCode: 500));
    }
  }

  @override
  FutureEither<List<MemberSearchResult>> searchMembers({
    required String gymId,
    required String query,
  }) async {
    try {
      final models = await remoteDataSource.searchMembers(gymId: gymId, query: query);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search members: $e', statusCode: 500));
    }
  }
}

