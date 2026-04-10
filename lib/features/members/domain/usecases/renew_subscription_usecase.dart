import '../../../../core/utils/typedefs.dart';
import '../repositories/member_detail_repository.dart';

class RenewSubscriptionUseCase {
  final MemberDetailRepository repository;

  RenewSubscriptionUseCase({required this.repository});

  FutureVoid call({
    required String memberId,
    required String packageId,
    required DateTime startDate,
    required DateTime expiryDate,
    required double amountPaid,
    required String paymentMode,
    required String? paymentReference,
    required String createdBy,
  }) {
    return repository.renewSubscription(
      memberId: memberId,
      packageId: packageId,
      startDate: startDate,
      expiryDate: expiryDate,
      amountPaid: amountPaid,
      paymentMode: paymentMode,
      paymentReference: paymentReference,
      createdBy: createdBy,
    );
  }
}

