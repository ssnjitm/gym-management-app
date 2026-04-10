import '../../../../core/utils/typedefs.dart';
import '../repositories/attendance_repository.dart';

class CheckOutUseCase {
  final AttendanceRepository repository;

  CheckOutUseCase({required this.repository});

  FutureVoid call({required String attendanceId}) {
    return repository.checkOut(attendanceId: attendanceId);
  }
}

