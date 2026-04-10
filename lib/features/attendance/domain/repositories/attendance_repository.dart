import '../../../../core/utils/typedefs.dart';
import '../entities/attendance_entities.dart';

abstract class AttendanceRepository {
  FutureEither<List<AttendanceRecord>> getTodayAttendance({
    required String gymId,
  });

  FutureEither<List<MemberSearchResult>> searchMembers({
    required String gymId,
    required String query,
  });

  FutureEither<void> checkIn({
    required String gymId,
    required String memberId,
  });

  FutureEither<void> checkOut({
    required String attendanceId,
  });
}

