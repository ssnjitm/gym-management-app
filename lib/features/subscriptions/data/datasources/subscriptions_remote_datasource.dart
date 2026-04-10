import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SubscriptionsRemoteDataSource {
  Future<List<Map<String, dynamic>>> getSubscriptions({
    required String gymId,
    required int limit,
  });

  Future<List<Map<String, dynamic>>> getExpiringSubscriptions({
    required String gymId,
    required int withinDays,
    required int limit,
  });

  Future<void> updateSubscriptionStatus({
    required String subscriptionId,
    required String status,
  });
}

class SubscriptionsRemoteDataSourceImpl implements SubscriptionsRemoteDataSource {
  final SupabaseClient supabaseClient;

  SubscriptionsRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<Map<String, dynamic>>> getSubscriptions({
    required String gymId,
    required int limit,
  }) async {
    final res = await supabaseClient
        .from('subscriptions')
        .select(
          'subscription_id, member_id, package_id, start_date, expiry_date, status, amount_paid, payment_mode, payment_reference, created_by, created_at, members(full_name, phone, gym_id), packages(package_name)',
        )
        .eq('members.gym_id', gymId)
        .order('expiry_date', ascending: true)
        .limit(limit);

    return (res as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> getExpiringSubscriptions({
    required String gymId,
    required int withinDays,
    required int limit,
  }) async {
    final today = DateTime.now();
    final to = today.add(Duration(days: withinDays));
    final toDate = to.toIso8601String().split('T')[0];

    final res = await supabaseClient
        .from('subscriptions')
        .select(
          'subscription_id, member_id, package_id, start_date, expiry_date, status, amount_paid, payment_mode, payment_reference, created_by, created_at, members(full_name, phone, gym_id), packages(package_name)',
        )
        .eq('members.gym_id', gymId)
        .lte('expiry_date', toDate)
        .order('expiry_date', ascending: true)
        .limit(limit);

    return (res as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<void> updateSubscriptionStatus({
    required String subscriptionId,
    required String status,
  }) async {
    await supabaseClient.from('subscriptions').update({'status': status}).eq('subscription_id', subscriptionId);
  }
}

