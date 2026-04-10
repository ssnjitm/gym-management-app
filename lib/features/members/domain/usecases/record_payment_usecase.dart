import '../../../../core/utils/typedefs.dart';
import '../repositories/member_detail_repository.dart';

class RecordPaymentUseCase {
  final MemberDetailRepository repository;

  RecordPaymentUseCase({required this.repository});

  FutureVoid call({
    required String memberId,
    required String? subscriptionId,
    required double amount,
    required String paymentMode,
    required DateTime paymentDate,
    required String? receiptNumber,
    required String? notes,
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

