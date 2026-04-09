import '../../../../core/utils/typedefs.dart';
import '../entities/home_entity.dart';

abstract class HomeRepository {
  FutureEither<DashboardStats> getDashboardStats(String gymId);
  FutureEither<List<RecentActivity>> getRecentActivities(String gymId);
  FutureEither<List<ExpiringMember>> getExpiringMembers(String gymId);
  FutureEither<List<Map<String, dynamic>>> getTodayAttendance(String gymId);
}