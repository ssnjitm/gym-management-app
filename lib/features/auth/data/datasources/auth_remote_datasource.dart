import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/error/exceptions.dart';
import '../models/staff_model.dart';

abstract class AuthRemoteDataSource {
  Future<StaffModel> login({required String email, required String password});
  Future<void> logout();
  Future<StaffModel> getCurrentStaff({required String staffId});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;
  
  AuthRemoteDataSourceImpl({required this.supabaseClient});


  @override
Future<StaffModel> login({
  required String email,
  required String password,
}) async {
  try {
    print('Attempting login for: $email');
    
    // Sign in with Supabase Auth
    final authResponse = await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (authResponse.user == null) {
      throw AuthException('Invalid email or password');
    }
    
    print('Auth successful, user ID: ${authResponse.user!.id}');
    print('Fetching staff details...');
    
    // Prefer auth.uid mapping (staff_id == auth user id).
    print('Querying staff table by auth user id...');
    var response = await supabaseClient
        .from('staff')
        .select()
        .eq('staff_id', authResponse.user!.id)
        .timeout(Duration(seconds: 10));

    // Backward-compatible fallback for existing demo rows not linked by staff_id.
    if (response.isEmpty) {
      response = await supabaseClient
          .from('staff')
          .select()
          .eq('email', email)
          .timeout(Duration(seconds: 10));
    }
    
    print('Staff query response length: ${response.length}');
    
    if (response.isEmpty) {
      print('No staff record found for email: $email');
      throw AuthException('Staff profile not found. Ask admin to add this staff email to the staff table.');
    }
    
    final staffData = response[0];
    print('Staff found: ${staffData['full_name']}, Role: ${staffData['role']}');
    
    return StaffModel.fromMap(staffData);
    
  } on AuthException {
    rethrow;
  } catch (e) {
    print('Login error: $e');
    if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
      throw AuthException('Connection timeout. Please check your internet connection and try again.');
    }
    if (e is supabase.AuthException) {
      if (e.message.contains('Invalid login credentials')) {
        throw AuthException('Invalid email or password');
      }
      throw AuthException(e.message);
    }
    throw ServerException(e.toString());
  }
}
  
  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
      print('Logout successful');
    } catch (e) {
      print('Logout error: $e');
      throw ServerException(e.toString());
    }
  }
  
  @override
  Future<StaffModel> getCurrentStaff({required String staffId}) async {
    try {
      print('Fetching staff with ID: $staffId');
      
      final response = await supabaseClient
          .from('staff')
          .select()
          .eq('staff_id', staffId)
          .timeout(Duration(seconds: 10));
      
      if (response.isEmpty) {
        throw AuthException('Staff record not found');
      }
      
      final staffData = response[0];
      return StaffModel.fromMap(staffData);
      
    } catch (e) {
      print('Get current staff error: $e');
      throw ServerException(e.toString());
    }
  }
}