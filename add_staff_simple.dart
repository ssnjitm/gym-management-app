import 'dart:convert';
import 'dart:io';

// Simple script to add staff records using HTTP requests
void main() async {
  const supabaseUrl = 'https://aelfxxwqsemkzyonojgz.supabase.co';
  const supabaseKey = 'sb_publishable_4d7aa1LYSPEuiwzGktw7wA_tXZWfzEB';
  
  final client = HttpClient();
  
  // Staff records to add
  final staffRecords = [
    {
      'email': 'rajendra@himalayanfitness.com',
      'full_name': 'Rajendra Sharma',
      'phone': '9841234567',
      'role': 'admin',
      'is_active': true,
      'gym_id': '550e8400-e29b-41d4-a716-446655440000',
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
      final request = await client.postUrl(
        Uri.parse('$supabaseUrl/rest/v1/staff'),
      );
      
      request.headers.set('apikey', supabaseKey);
      request.headers.set('Authorization', 'Bearer $supabaseKey');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Prefer', 'return=representation');

      request.add(utf8.encode(jsonEncode(record)));

      final response = await request.close();

      if (response.statusCode == 201) {
        final responseBody = await response.transform(utf8.decoder).join();
        final responseData = jsonDecode(responseBody);
        print('Added staff: ${record['email']} - ID: ${responseData[0]['staff_id']}');
      } else {
        print('Error adding staff ${record['email']}: ${response.statusCode}');
        final errorBody = await response.transform(utf8.decoder).join();
        print('Error details: $errorBody');
      }
    } catch (e) {
      print('Exception adding staff ${record['email']}: $e');
    }
  }

  print('\nVerifying staff records...');
  try {
    final request = await client.getUrl(
      Uri.parse('$supabaseUrl/rest/v1/staff?select=*'),
    );
    
    request.headers.set('apikey', supabaseKey);
    request.headers.set('Authorization', 'Bearer $supabaseKey');

    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final staffList = jsonDecode(responseBody);
      print('Total staff records: ${staffList.length}');
      
      for (final staff in staffList) {
        print('- ${staff['email']} (${staff['full_name']}) - ${staff['role']}');
      }
    } else {
      print('Error fetching staff: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception fetching staff: $e');
  }

  client.close();
  exit(0);
}
