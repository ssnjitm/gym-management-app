import '../../../../core/utils/typedefs.dart';
import '../repositories/attendance_repository.dart';

class CheckInUseCase {
  final AttendanceRepository repository;

  CheckInUseCase({required this.repository});

  FutureVoid call({
    required String gymId,
    required String memberId,
  }) {
    return repository.checkIn(gymId: gymId, memberId: memberId);
  }
}

