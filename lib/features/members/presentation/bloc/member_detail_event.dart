part of 'member_detail_bloc.dart';

abstract class MemberDetailEvent extends Equatable {
  const MemberDetailEvent();

  @override
  List<Object?> get props => [];
}

class MemberDetailStarted extends MemberDetailEvent {
  final String memberId;

  const MemberDetailStarted({required this.memberId});

  @override
  List<Object?> get props => [memberId];
}

class MemberDetailRefreshRequested extends MemberDetailEvent {
  const MemberDetailRefreshRequested();
}

class MemberDetailRecordPaymentRequested extends MemberDetailEvent {
  final String memberId;
  final String? subscriptionId;
  final double amount;
  final String paymentMode;
  final DateTime paymentDate;
  final String? receiptNumber;
  final String? notes;

  const MemberDetailRecordPaymentRequested({
    required this.memberId,
    required this.subscriptionId,
    required this.amount,
    required this.paymentMode,
    required this.paymentDate,
    required this.receiptNumber,
    required this.notes,
  });

  @override
  List<Object?> get props => [
        memberId,
        subscriptionId,
        amount,
        paymentMode,
        paymentDate,
        receiptNumber,
        notes,
      ];
}

class MemberDetailRenewSubscriptionRequested extends MemberDetailEvent {
  final String memberId;
  final String packageId;
  final DateTime startDate;
  final DateTime expiryDate;
  final double amountPaid;
  final String paymentMode;
  final String? paymentReference;

  const MemberDetailRenewSubscriptionRequested({
    required this.memberId,
    required this.packageId,
    required this.startDate,
    required this.expiryDate,
    required this.amountPaid,
    required this.paymentMode,
    required this.paymentReference,
  });

  @override
  List<Object?> get props => [
        memberId,
        packageId,
        startDate,
        expiryDate,
        amountPaid,
        paymentMode,
        paymentReference,
      ];
}

