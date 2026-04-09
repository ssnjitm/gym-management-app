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
    
    // Fetch staff details from staff table with timeout
    print('Querying staff table for email: $email');
    final response = await supabaseClient
        .from('staff')
        .select()
        .eq('email', email)
        .timeout(Duration(seconds: 10));
    
    print('Staff query response length: ${response.length}');
    
    if (response.isEmpty) {
      print('No staff record found for email: $email');
      print('Creating staff record automatically...');
      
      // Create staff record automatically
      try {
        final newStaffData = {
          'email': email,
          'full_name': email.split('@')[0].replaceAll(RegExp(r'[._-]'), ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' '),
          'phone': '0000000000', // Default phone
          'role': 'reception', // Default role
          'is_active': true,
          'gym_id': '550e8400-e29b-41d4-a716-446655440000', // Default gym ID
        };
        
        final insertResponse = await supabaseClient
            .from('staff')
            .insert(newStaffData)
            .select()
            .timeout(Duration(seconds: 10));
            
        if (insertResponse.isNotEmpty) {
          print('Staff record created successfully: ${insertResponse[0]['full_name']}');
          return StaffModel.fromMap(insertResponse[0]);
        } else {
          throw AuthException('Failed to create staff record. Please contact administrator.');
        }
      } catch (e) {
        print('Failed to create staff record: $e');
        print('Creating fallback mock staff record...');
        
        // Create mock staff record for testing
        try {
          final mockStaffData = {
            'staff_id': authResponse.user!.id, // Use auth user ID as staff ID
            'email': email,
            'full_name': email.split('@')[0].replaceAll(RegExp(r'[._-]'), ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' '),
            'phone': '0000000000',
            'role': 'reception',
            'is_active': true,
            'gym_id': '550e8400-e29b-41d4-a716-446655440000',
          };
          
          print('Mock staff record created: ${mockStaffData['full_name']}');
          return StaffModel.fromMap(mockStaffData);
        } catch (mockError) {
          print('Failed to create mock staff record: $mockError');
          throw AuthException('Staff record creation failed. Please contact administrator.');
        }
      }
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