import '../../../../core/utils/typedefs.dart';
import '../repositories/subscriptions_repository.dart';

class UpdateSubscriptionStatusUseCase {
  final SubscriptionsRepository repository;

  UpdateSubscriptionStatusUseCase({required this.repository});

  FutureVoid call({
    required String subscriptionId,
    required String status,
  }) {
    return repository.updateSubscriptionStatus(subscriptionId: subscriptionId, status: status);
  }
}

