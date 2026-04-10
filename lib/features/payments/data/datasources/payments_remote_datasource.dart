import 'package:supabase_flutter/supabase_flutter.dart';

abstract class PaymentsRemoteDataSource {
  Future<List<Map<String, dynamic>>> getPayments({
    required String gymId,
    required int limit,
  });

  Future<void> recordPayment({
    required String memberId,
    String? subscriptionId,
    required num amount,
    required String paymentMode,
    required DateTime paymentDate,
    String? receiptNumber,
    String? notes,
    required String recordedBy,
  });
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  final SupabaseClient supabaseClient;

  PaymentsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<Map<String, dynamic>>> getPayments({
    required String gymId,
    required int limit,
  }) async {
    final res = await supabaseClient
        .from('payments')
        .select(
          'payment_id, member_id, subscription_id, amount, payment_mode, payment_date, receipt_number, notes, recorded_by, created_at, members(full_name, member_code, gym_id)',
        )
        .eq('members.gym_id', gymId)
        .order('payment_date', ascending: false)
        .limit(limit);
    return (res as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<void> recordPayment({
    required String memberId,
    String? subscriptionId,
    required num amount,
    required String paymentMode,
    required DateTime paymentDate,
    String? receiptNumber,
    String? notes,
    required String recordedBy,
  }) async {
    await supabaseClient.from('payments').insert({
      'member_id': memberId,
      'subscription_id': subscriptionId,
      'amount': amount,
      'payment_mode': paymentMode,
      'payment_date': paymentDate.toIso8601String().split('T')[0],
      'receipt_number': receiptNumber,
      'notes': notes,
      'recorded_by': recordedBy,
    });
  }
}

