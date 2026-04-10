import 'package:equatable/equatable.dart';

class PaymentListItemEntity extends Equatable {
  final String paymentId;
  final String memberId;
  final String? subscriptionId;
  final double amount;
  final String paymentMode;
  final DateTime paymentDate;
  final String? receiptNumber;
  final String? notes;
  final String recordedBy;
  final DateTime createdAt;
  final String memberName;
  final String? memberCode;

  const PaymentListItemEntity({
    required this.paymentId,
    required this.memberId,
    required this.subscriptionId,
    required this.amount,
    required this.paymentMode,
    required this.paymentDate,
    required this.receiptNumber,
    required this.notes,
    required this.recordedBy,
    required this.createdAt,
    required this.memberName,
    required this.memberCode,
  });

  @override
  List<Object?> get props => [
        paymentId,
        memberId,
        subscriptionId,
        amount,
        paymentMode,
        paymentDate,
        receiptNumber,
        notes,
        recordedBy,
        createdAt,
        memberName,
        memberCode,
      ];
}

