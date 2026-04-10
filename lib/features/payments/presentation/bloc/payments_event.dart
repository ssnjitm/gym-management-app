import 'package:equatable/equatable.dart';

sealed class PaymentsEvent extends Equatable {
  const PaymentsEvent();

  @override
  List<Object?> get props => [];
}

class PaymentsStarted extends PaymentsEvent {
  final String gymId;
  const PaymentsStarted({required this.gymId});

  @override
  List<Object?> get props => [gymId];
}

class PaymentsRefreshRequested extends PaymentsEvent {
  final String gymId;
  const PaymentsRefreshRequested({required this.gymId});

  @override
  List<Object?> get props => [gymId];
}

class PaymentRecordRequested extends PaymentsEvent {
  final String gymId;
  final String memberId;
  final String? subscriptionId;
  final num amount;
  final String paymentMode;
  final DateTime paymentDate;
  final String? receiptNumber;
  final String? notes;

  const PaymentRecordRequested({
    required this.gymId,
    required this.memberId,
    required this.subscriptionId,
    required this.amount,
    required this.paymentMode,
    required this.paymentDate,
    required this.receiptNumber,
    required this.notes,
  });

  @override
  List<Object?> get props => [gymId, memberId, subscriptionId, amount, paymentMode, paymentDate, receiptNumber, notes];
}

