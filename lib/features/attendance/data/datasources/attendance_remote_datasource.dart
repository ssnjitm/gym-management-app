import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/error/exceptions.dart';
import '../models/attendance_models.dart';

abstract class AttendanceRemoteDataSource {
  Future<List<AttendanceRecordModel>> getTodayAttendance({required String gymId});
  Future<List<MemberSearchResultModel>> searchMembers({required String gymId, required String query});
  Future<void> checkIn({required String gymId, required String memberId});
  Future<void> checkOut({required String attendanceId});
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  AttendanceRemoteDataSourceImpl({required this.supabaseClient});

  String _todayDate() => DateTime.now().toIso8601String().split('T')[0];

  @override
  Future<List<AttendanceRecordModel>> getTodayAttendance({required String gymId}) async {
    try {
      final data = await supabaseClient
          .from('attendance')
          .select('''
            attendance_id,
            gym_id,
            member_id,
            check_in_time,
            check_out_time,
            attendance_date,
            members!inner(member_id, full_name, phone, member_code)
          ''')
          .eq('gym_id', gymId)
          .eq('attendance_date', _todayDate())
          .order('check_in_time', ascending: false)
          .limit(50);

      return (data as List)
          .cast<Map<String, dynamic>>()
          .map((m) => AttendanceRecordModel.fromMap(m))
          .toList();
    } catch (e) {
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
      }
      throw ServerException('Failed to load today attendance: $e');
    }
  }

  @override
  Future<List<MemberSearchResultModel>> searchMembers({
    required String gymId,
    required String query,
  }) async {
    try {
      final data = await supabaseClient
          .from('members')
          .select('member_id, full_name, phone, member_code, status')
          .eq('gym_id', gymId)
          .or('full_name.ilike.%$query%,member_code.ilike.%$query%,phone.ilike.%$query%')
          .order('full_name', ascending: true)
          .limit(20);

      return (data as List)
          .cast<Map<String, dynamic>>()
          .map((m) => MemberSearchResultModel.fromMap(m))
          .toList();
    } catch (e) {
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
      }
      throw ServerException('Failed to search members: $e');
    }
  }

  @override
  Future<void> checkIn({required String gymId, required String memberId}) async {
    try {
      await supabaseClient.from('attendance').insert({
        'member_id': memberId,
        'gym_id': gymId,
        'check_in_time': DateTime.now().toIso8601String(),
        'attendance_date': _todayDate(),
      });
    } catch (e) {
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
      }
      throw ServerException('Failed to check-in: $e');
    }
  }

  @override
  Future<void> checkOut({required String attendanceId}) async {
    try {
      await supabaseClient
          .from('attendance')
          .update({'check_out_time': DateTime.now().toIso8601String()})
          .eq('attendance_id', attendanceId);
    } catch (e) {
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
      }
      throw ServerException('Failed to check-out: $e');
    }
  }
}

