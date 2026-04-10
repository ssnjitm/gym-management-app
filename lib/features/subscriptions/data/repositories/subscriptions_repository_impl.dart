import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/subscription_list_item_entity.dart';
import '../../domain/repositories/subscriptions_repository.dart';
import '../datasources/subscriptions_remote_datasource.dart';
import '../models/subscription_list_item_model.dart';

class SubscriptionsRepositoryImpl implements SubscriptionsRepository {
  final SubscriptionsRemoteDataSource remote;

  SubscriptionsRepositoryImpl({required this.remote});

  @override
  FutureEither<List<SubscriptionListItemEntity>> getSubscriptions({
    required String gymId,
    int limit = 200,
  }) async {
    try {
      final rows = await remote.getSubscriptions(gymId: gymId, limit: limit);
      final items = rows.map(SubscriptionListItemModel.fromMap).toList(growable: false);
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load subscriptions: $e', statusCode: 500));
    }
  }

  @override
  FutureEither<List<SubscriptionListItemEntity>> getExpiringSubscriptions({
    required String gymId,
    required int withinDays,
    int limit = 200,
  }) async {
    try {
      final rows = await remote.getExpiringSubscriptions(gymId: gymId, withinDays: withinDays, limit: limit);
      final items = rows.map(SubscriptionListItemModel.fromMap).toList(growable: false);
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load expiring subscriptions: $e', statusCode: 500));
    }
  }

  @override
  FutureVoid updateSubscriptionStatus({
    required String subscriptionId,
    required String status,
  }) async {
    try {
      await remote.updateSubscriptionStatus(subscriptionId: subscriptionId, status: status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update subscription: $e', statusCode: 500));
    }
  }
}

