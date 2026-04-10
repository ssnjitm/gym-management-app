import '../../../../core/utils/typedefs.dart';
import '../entities/subscription_list_item_entity.dart';
import '../repositories/subscriptions_repository.dart';

class GetSubscriptionsUseCase {
  final SubscriptionsRepository repository;

  GetSubscriptionsUseCase({required this.repository});

  FutureEither<List<SubscriptionListItemEntity>> call({
    required String gymId,
    int limit = 200,
  }) {
    return repository.getSubscriptions(gymId: gymId, limit: limit);
  }
}

