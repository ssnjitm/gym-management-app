import '../../../../core/utils/typedefs.dart';
import '../entities/attendance_entities.dart';
import '../repositories/attendance_repository.dart';

class GetTodayAttendanceUseCase {
  final AttendanceRepository repository;

  GetTodayAttendanceUseCase({required this.repository});

  FutureEither<List<AttendanceRecord>> call({required String gymId}) {
    return repository.getTodayAttendance(gymId: gymId);
  }
}

