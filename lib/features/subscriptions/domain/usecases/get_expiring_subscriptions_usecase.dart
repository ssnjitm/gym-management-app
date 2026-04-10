import '../../../../core/utils/typedefs.dart';
import '../entities/subscription_list_item_entity.dart';
import '../repositories/subscriptions_repository.dart';

class GetExpiringSubscriptionsUseCase {
  final SubscriptionsRepository repository;

  GetExpiringSubscriptionsUseCase({required this.repository});

  FutureEither<List<SubscriptionListItemEntity>> call({
    required String gymId,
    required int withinDays,
    int limit = 200,
  }) {
    return repository.getExpiringSubscriptions(gymId: gymId, withinDays: withinDays, limit: limit);
  }
}

