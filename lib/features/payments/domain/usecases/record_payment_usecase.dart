import '../../../../core/utils/typedefs.dart';
import '../repositories/payments_repository.dart';

class RecordGymPaymentUseCase {
  final PaymentsRepository repository;

  RecordGymPaymentUseCase({required this.repository});

  FutureVoid call({
    required String memberId,
    String? subscriptionId,
    required num amount,
    required String paymentMode,
    required DateTime paymentDate,
    String? receiptNumber,
    String? notes,
    required String recordedBy,
  }) {
    return repository.recordPayment(
      memberId: memberId,
      subscriptionId: subscriptionId,
      amount: amount,
      paymentMode: paymentMode,
      paymentDate: paymentDate,
      receiptNumber: receiptNumber,
      notes: notes,
      recordedBy: recordedBy,
    );
  }
}

