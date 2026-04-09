import '../../domain/entities/home_entity.dart';

class DashboardStatsModel extends DashboardStats {
  DashboardStatsModel({
    required super.totalMembers,
    required super.todayCheckins,
    required super.expiringThisWeek,
    required super.monthlyRevenue,
    required super.totalRevenue,
    required super.collectionTarget,
  });
  
  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalMembers: json['total_members'] ?? 0,
      todayCheckins: json['today_checkins'] ?? 0,
      expiringThisWeek: json['expiring_this_week'] ?? 0,
      monthlyRevenue: (json['monthly_revenue'] ?? 0).toDouble(),
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      collectionTarget: (json['collection_target'] ?? 0).toDouble(),
    );
  }
}