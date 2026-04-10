import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/error/exceptions.dart';

abstract class MemberDetailRemoteDataSource {
  Future<Map<String, dynamic>> getMember({required String memberId});
  Future<List<Map<String, dynamic>>> getCurrentSubscription({required String memberId});
  Future<List<Map<String, dynamic>>> getPayments({required String memberId});
  Future<List<Map<String, dynamic>>> getAttendance({required String memberId});

  Future<void> recordPayment({
    required String memberId,
    required String? subscriptionId,
    required num amount,
    required String paymentMode,
    required DateTime paymentDate,
    required String? receiptNumber,
    required String? notes,
    required String recordedBy,
  });

  Future<void> renewSubscription({
    required String memberId,
    required String packageId,
    required DateTime startDate,
    required DateTime expiryDate,
    required num amountPaid,
    required String paymentMode,
    required String? paymentReference,
    required String createdBy,
  });
}

class MemberDetailRemoteDataSourceImpl implements MemberDetailRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;

  MemberDetailRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<Map<String, dynamic>> getMember({required String memberId}) async {
    try {
      final data = await supabaseClient
          .from('members')
          .select('*')
          .eq('member_id', memberId)
          .single();
      return (data as Map).cast<String, dynamic>();
    } catch (e) {
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
      }
      throw ServerException('Failed to load member: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCurrentSubscription({required String memberId}) async {
    try {
      final data = await supabaseClient
          .from('subscriptions')
          .select('''
            subscription_id,
            member_id,
            package_id,
            start_date,
            expiry_date,
            status,
            amount_paid,
            payment_mode,
            payment_reference,
            created_by,
            created_at,
            packages(package_id, package_name, duration_days, price)
          ''')
          .eq('member_id', memberId)
          .order('start_date', ascending: false)
          .limit(1);

      return (data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
      }
      throw ServerException('Failed to load subscription: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPayments({required String memberId}) async {
    try {
      final data = await supabaseClient
          .from('payments')
          .select('*')
          .eq('member_id', memberId)
          .order('payment_date', ascending: false)
          .limit(50);
      return (data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
      }
      throw ServerException('Failed to load payments: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAttendance({required String memberId}) async {
    try {
      final data = await supabaseClient
          .from('attendance')
          .select('*')
          .eq('member_id', memberId)
          .order('check_in_time', ascending: false)
          .limit(50);
      return (data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
      }
      throw ServerException('Failed to load attendance: $e');
    }
  }

  @override
  Future<void> recordPayment({
    required String memberId,
    required String? subscriptionId,
    required num amount,
    required String paymentMode,
    required DateTime paymentDate,
    required String? receiptNumber,
    required String? notes,
    required String recordedBy,
  }) async {
    try {
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
    } catch (e) {
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
      }
      throw ServerException('Failed to record payment: $e');
    }
  }

  @override
  Future<void> renewSubscription({
    required String memberId,
    required String packageId,
    required DateTime startDate,
    required DateTime expiryDate,
    required num amountPaid,
    required String paymentMode,
    required String? paymentReference,
    required String createdBy,
  }) async {
    try {
      final subRow = await supabaseClient
          .from('subscriptions')
          .insert({
        'member_id': memberId,
        'package_id': packageId,
        'start_date': startDate.toIso8601String().split('T')[0],
        'expiry_date': expiryDate.toIso8601String().split('T')[0],
        'status': 'active',
        'amount_paid': amountPaid,
        'payment_mode': paymentMode,
        'payment_reference': paymentReference,
        'created_by': createdBy,
          })
          .select('subscription_id')
          .single();

      // Also create a payment record for receipt/collections history.
      await supabaseClient.from('payments').insert({
        'member_id': memberId,
        'subscription_id': subRow['subscription_id']?.toString(),
        'amount': amountPaid,
        'payment_mode': paymentMode,
        'payment_date': DateTime.now().toIso8601String().split('T')[0],
        'receipt_number': paymentReference,
        'notes': null,
        'recorded_by': createdBy,
      });
    } catch (e) {
      if (e is supabase.PostgrestException) {
        throw ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
      }
      throw ServerException('Failed to renew subscription: $e');
    }
  }
}

