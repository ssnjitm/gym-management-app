import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

// Add this script to your project root and run with: dart add_staff_records.dart
// Make sure to add supabase_flutter to your pubspec.yaml dependencies

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://aelfxxwqsemkzyonojgz.supabase.co',
    anonKey: 'sb_publishable_4d7aa1LYSPEuiwzGktw7wA_tXZWfzEB',
  );

  final supabaseClient = Supabase.instance.client;

  // Staff records to add
  final staffRecords = [
    {
      'email': 'rajendra@himalayanfitness.com',
      'full_name': 'Rajendra Sharma',
      'phone': '9841234567',
      'role': 'admin',
      'is_active': true,
      'gym_id': '550e8400-e29b-41d4-a716-446655440000', // Sample gym ID
    },
    {
      'email': 'sita@himalayanfitness.com',
      'full_name': 'Sita Kumari',
      'phone': '9841234568',
      'role': 'manager',
      'is_active': true,
      'gym_id': '550e8400-e29b-41d4-a716-446655440000',
    },
    {
      'email': 'bikram@himalayanfitness.com',
      'full_name': 'Bikram Thapa',
      'phone': '9841234569',
      'role': 'trainer',
      'is_active': true,
      'gym_id': '550e8400-e29b-41d4-a716-446655440000',
    },
    {
      'email': 'test@himalayanfitness.com',
      'full_name': 'Test User',
      'phone': '9841234570',
      'role': 'reception',
      'is_active': true,
      'gym_id': '550e8400-e29b-41d4-a716-446655440000',
    },
  ];

  print('Adding staff records...');

  for (final record in staffRecords) {
    try {
      final response = await supabaseClient
          .from('staff')
          .insert(record)
          .select();

      print('Added staff: ${record['email']} - ID: ${response[0]['staff_id']}');
    } catch (e) {
      print('Error adding staff ${record['email']}: $e');
    }
  }

  print('\nVerifying staff records...');
  final allStaff = await supabaseClient.from('staff').select();
  print('Total staff records: ${allStaff.length}');
  
  for (final staff in allStaff) {
    print('- ${staff['email']} (${staff['full_name']}) - ${staff['role']}');
  }

  exit(0);
}
