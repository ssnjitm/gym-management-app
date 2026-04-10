import '../../../../core/utils/typedefs.dart';
import '../entities/member_detail_entity.dart';

abstract class MemberDetailRepository {
  FutureEither<MemberDetailEntity> getMemberDetail({required String memberId});

  FutureVoid recordPayment({
    required String memberId,
    required String? subscriptionId,
    required double amount,
    required String paymentMode,
    required DateTime paymentDate,
    required String? receiptNumber,
    required String? notes,
    required String recordedBy,
  });

  FutureVoid renewSubscription({
    required String memberId,
    required String packageId,
    required DateTime startDate,
    required DateTime expiryDate,
    required double amountPaid,
    required String paymentMode,
    required String? paymentReference,
    required String createdBy,
  });
}

