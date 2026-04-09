import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dashboard_stats_model.dart';

abstract class HomeRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats(String gymId);
  Future<List<Map<String, dynamic>>> getRecentActivities(String gymId);
  Future<List<Map<String, dynamic>>> getExpiringMembers(String gymId);
  Future<List<Map<String, dynamic>>> getTodayAttendance(String gymId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient supabaseClient;
  
  HomeRemoteDataSourceImpl({required this.supabaseClient});
  
  @override
  Future<DashboardStatsModel> getDashboardStats(String gymId) async {
    try {
      // Get total members - using count() method
      final totalMembersResponse = await supabaseClient
          .from('members')
          .select()
          .eq('gym_id', gymId)
          .eq('status', 'active');
      
      final totalMembers = totalMembersResponse.length;
      
      // Get today's check-ins
      final today = DateTime.now().toIso8601String().split('T')[0];
      final todayCheckinsResponse = await supabaseClient
          .from('attendance')
          .select()
          .eq('gym_id', gymId)
          .eq('attendance_date', today);
      
      final todayCheckins = todayCheckinsResponse.length;
      
      // Get expiring this week (subscriptions in grace period)
      final today_date = DateTime.now().toIso8601String().split('T')[0];
      final nextWeek = DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0];
      
      final expiringResponse = await supabaseClient
          .from('subscriptions')
          .select()
          .eq('status', 'grace')
          .gte('expiry_date', today_date)
          .lte('expiry_date', nextWeek);
      
      final expiringThisWeek = expiringResponse.length;
      
      // Get monthly revenue
      final firstDayOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1)
          .toIso8601String().split('T')[0];
      
      final monthlyRevenueResponse = await supabaseClient
          .from('payments')
          .select('amount')
          .gte('payment_date', firstDayOfMonth);
      
      double monthlyRevenue = 0;
      for (var payment in monthlyRevenueResponse) {
        monthlyRevenue += (payment['amount'] as num).toDouble();
      }
      
      // Get total revenue (all time)
      final totalRevenueResponse = await supabaseClient
          .from('payments')
          .select('amount');
      
      double totalRevenue = 0;
      for (var payment in totalRevenueResponse) {
        totalRevenue += (payment['amount'] as num).toDouble();
      }
      
      // Get collection target from gym settings
      final gymSettingsResponse = await supabaseClient
          .from('gym_settings')
          .select('monthly_target')
          .eq('gym_id', gymId)
          .maybeSingle();
      
      double collectionTarget = 50000; // Default value
      if (gymSettingsResponse != null && gymSettingsResponse['monthly_target'] != null) {
        collectionTarget = (gymSettingsResponse['monthly_target'] as num).toDouble();
      }
      
      return DashboardStatsModel(
        totalMembers: totalMembers,
        todayCheckins: todayCheckins,
        expiringThisWeek: expiringThisWeek,
        monthlyRevenue: monthlyRevenue,
        totalRevenue: totalRevenue,
        collectionTarget: collectionTarget,
      );
    } catch (e) {
      print('Error in getDashboardStats: $e');
      throw Exception('Failed to load dashboard stats: $e');
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> getRecentActivities(String gymId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final activities = await supabaseClient
          .from('attendance')
          .select('''
            attendance_id,
            check_in_time,
            members!inner (
              member_id,
              full_name,
              profile_photo_url
            )
          ''')
          .eq('attendance_date', today)
          .eq('members.gym_id', gymId)
          .order('check_in_time', ascending: false)
          .limit(10);
      
      return activities.map((activity) {
        final memberData = activity['members'] as Map<String, dynamic>;
        return {
          'id': activity['attendance_id'],
          'member_name': memberData['full_name'],
          'action': 'Checked in',
          'time': DateTime.parse(activity['check_in_time']),
          'thumbnail': memberData['profile_photo_url'],
        };
      }).toList();
    } catch (e) {
      print('Error in getRecentActivities: $e');
      return [];
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> getExpiringMembers(String gymId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final nextWeek = DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0];
      
      final expiring = await supabaseClient
          .from('subscriptions')
          .select('''
            subscription_id,
            expiry_date,
            status,
            packages!inner (
              package_name
            ),
            members!inner (
              member_id,
              full_name,
              phone
            )
          ''')
          .eq('members.gym_id', gymId)
          .eq('status', 'grace')
          .gte('expiry_date', today)
          .lte('expiry_date', nextWeek)
          .order('expiry_date', ascending: true);
      
      return expiring.map((sub) {
        final memberData = sub['members'] as Map<String, dynamic>;
        final packageData = sub['packages'] as Map<String, dynamic>;
        final expiryDate = DateTime.parse(sub['expiry_date']);
        final daysLeft = expiryDate.difference(DateTime.now()).inDays;
        
        return {
          'member_id': memberData['member_id'],
          'member_name': memberData['full_name'],
          'phone': memberData['phone'],
          'package_name': packageData['package_name'],
          'expiry_date': expiryDate,
          'days_left': daysLeft > 0 ? daysLeft : 0,
        };
      }).toList();
    } catch (e) {
      print('Error in getExpiringMembers: $e');
      return [];
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> getTodayAttendance(String gymId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      final attendance = await supabaseClient
          .from('attendance')
          .select('''
            attendance_id,
            check_in_time,
            check_out_time,
            members!inner (
              member_id,
              full_name,
              member_code,
              profile_photo_url
            )
          ''')
          .eq('attendance_date', today)
          .eq('members.gym_id', gymId)
          .order('check_in_time', ascending: false);
      
      return attendance.map((record) {
        final memberData = record['members'] as Map<String, dynamic>;
        return {
          'attendance_id': record['attendance_id'],
          'check_in_time': record['check_in_time'],
          'check_out_time': record['check_out_time'],
          'member_id': memberData['member_id'],
          'full_name': memberData['full_name'],
          'member_code': memberData['member_code'],
          'profile_photo_url': memberData['profile_photo_url'],
        };
      }).toList();
    } catch (e) {
      print('Error in getTodayAttendance: $e');
      return [];
    }
  }
}