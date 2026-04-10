import '../../../../core/utils/typedefs.dart';
import '../entities/payment_list_item_entity.dart';
import '../repositories/payments_repository.dart';

class GetPaymentsUseCase {
  final PaymentsRepository repository;

  GetPaymentsUseCase({required this.repository});

  FutureEither<List<PaymentListItemEntity>> call({
    required String gymId,
    int limit = 200,
  }) {
    return repository.getPayments(gymId: gymId, limit: limit);
  }
}

