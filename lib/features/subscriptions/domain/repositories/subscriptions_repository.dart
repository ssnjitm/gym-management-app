import '../../../../core/utils/typedefs.dart';
import '../entities/subscription_list_item_entity.dart';

abstract class SubscriptionsRepository {
  FutureEither<List<SubscriptionListItemEntity>> getSubscriptions({
    required String gymId,
    int limit = 200,
  });

  FutureEither<List<SubscriptionListItemEntity>> getExpiringSubscriptions({
    required String gymId,
    required int withinDays,
    int limit = 200,
  });

  FutureVoid updateSubscriptionStatus({
    required String subscriptionId,
    required String status,
  });
}

