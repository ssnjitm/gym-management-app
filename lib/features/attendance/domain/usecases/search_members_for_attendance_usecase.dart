import '../../../../core/utils/typedefs.dart';
import '../entities/attendance_entities.dart';
import '../repositories/attendance_repository.dart';

class SearchMembersForAttendanceUseCase {
  final AttendanceRepository repository;

  SearchMembersForAttendanceUseCase({required this.repository});

  FutureEither<List<MemberSearchResult>> call({
    required String gymId,
    required String query,
  }) {
    return repository.searchMembers(gymId: gymId, query: query);
  }
}

