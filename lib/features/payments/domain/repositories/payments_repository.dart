import '../../../../core/utils/typedefs.dart';
import '../entities/payment_list_item_entity.dart';

abstract class PaymentsRepository {
  FutureEither<List<PaymentListItemEntity>> getPayments({
    required String gymId,
    int limit = 200,
  });

  FutureVoid recordPayment({
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

