import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/error/exceptions.dart';
import '../models/member_model.dart';

abstract class MemberRemoteDataSource {
  Future<List<MemberModel>> getMembers({
    String? gymId,
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? sortBy,
    bool? ascending = true,
  });

  Future<MemberModel> getMemberById({
    required String memberId,
  });

  Future<MemberModel> createMember({
    required String gymId,
    required Map<String, dynamic> memberData,
  });

  Future<MemberModel> updateMember({
    required String memberId,
    required Map<String, dynamic> memberData,
  });

  Future<void> deleteMember({
    required String memberId,
  });

  Future<List<MemberModel>> searchMembers({
    required String query,
    String? gymId,
    int limit = 20,
  });
}

class MemberRemoteDataSourceImpl implements MemberRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;
  
  MemberRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<MemberModel>> getMembers({
    String? gymId,
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? sortBy,
    bool? ascending = true,
  }) async {
    try {
      dynamic query = supabaseClient.from('members').select('*');
      
      // Apply filters
      if (gymId != null) {
        query = query.eq('gym_id', gymId);
      }
      
      if (search != null && search.isNotEmpty) {
        query = query.or('full_name.ilike.%$search%,member_code.ilike.%$search%,phone.ilike.%$search%');
      }
      
      if (status != null) {
        query = query.eq('status', status);
      }
      
      // Apply sorting
      if (sortBy != null) {
        query = query.order(sortBy, ascending: ascending ?? true);
      }
      
      // Apply pagination
      final response = await query
          .range((page - 1) * limit, (page * limit) - 1)
          .timeout(const Duration(seconds: 10));
      
      final rows = (response as List).cast<Map<String, dynamic>>();
      final members = rows.map((data) => MemberModel.fromMap(data)).toList();
      
      print('Fetched ${members.length} members');
      return members;
      
    } catch (e) {
      print('Error fetching members: $e');
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
      }
      throw ServerException('Failed to fetch members: ${e.toString()}');
    }
  }

  @override
  Future<MemberModel> getMemberById({
    required String memberId,
  }) async {
    try {
      final response = await supabaseClient
          .from('members')
          .select('*')
          .eq('member_id', memberId)
          .single()
          .timeout(const Duration(seconds: 10));
      
      final member = MemberModel.fromMap(response);
      print('Fetched member: ${member.fullName}');
      return member;
      
    } catch (e) {
      print('Error fetching member: $e');
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
      }
      throw ServerException('Failed to fetch member: ${e.toString()}');
    }
  }

  @override
  Future<MemberModel> createMember({
    required String gymId,
    required Map<String, dynamic> memberData,
  }) async {
    try {
      final payload = <String, dynamic>{
        ...memberData,
        'gym_id': gymId,
        'status': memberData['status'] ?? 'active',
      };
      final response = await supabaseClient
          .from('members')
          .insert(payload)
          .select()
          .single()
          .timeout(const Duration(seconds: 10));
      
      final member = MemberModel.fromMap(response);
      print('Created member: ${member.fullName}');
      return member;
      
    } catch (e) {
      print('Error creating member: $e');
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
      }
      throw ServerException('Failed to create member: ${e.toString()}');
    }
  }

  @override
  Future<MemberModel> updateMember({
    required String memberId,
    required Map<String, dynamic> memberData,
  }) async {
    try {
      final response = await supabaseClient
          .from('members')
          .update(memberData)
          .eq('member_id', memberId)
          .select()
          .single()
          .timeout(const Duration(seconds: 10));
      
      final member = MemberModel.fromMap(response);
      print('Updated member: ${member.fullName}');
      return member;
      
    } catch (e) {
      print('Error updating member: $e');
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
      }
      throw ServerException('Failed to update member: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteMember({
    required String memberId,
  }) async {
    try {
      await supabaseClient
          .from('members')
          .delete()
          .eq('member_id', memberId)
          .timeout(const Duration(seconds: 10));
      
      print('Deleted member: $memberId');
      
    } catch (e) {
      print('Error deleting member: $e');
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
      }
      throw ServerException('Failed to delete member: ${e.toString()}');
    }
  }

  @override
  Future<List<MemberModel>> searchMembers({
    required String query,
    String? gymId,
    int limit = 20,
  }) async {
    try {
      var supabaseQuery = supabaseClient
          .from('members')
          .select('*');
      
      if (gymId != null) {
        supabaseQuery = supabaseQuery.eq('gym_id', gymId);
      }
      
      // Multi-field search
      supabaseQuery = supabaseQuery.or('full_name.ilike.%$query%,member_code.ilike.%$query%,phone.ilike.%$query%');
      
      final response = await supabaseQuery
          .limit(limit)
          .timeout(const Duration(seconds: 10));
      
      final rows = (response as List).cast<Map<String, dynamic>>();
      final members = rows.map((data) => MemberModel.fromMap(data)).toList();
      
      print('Found ${members.length} members for query: $query');
      return members;
      
    } catch (e) {
      print('Error searching members: $e');
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
      }
      throw ServerException('Failed to search members: ${e.toString()}');
    }
  }
}