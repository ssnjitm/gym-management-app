import 'package:equatable/equatable.dart';

class SubscriptionEntity extends Equatable {
  final String subscriptionId;
  final String memberId;
  final String packageId;
  final DateTime startDate;
  final DateTime expiryDate;
  final String status;
  final double amountPaid;
  final String paymentMode;
  final String? paymentReference;
  final String createdBy;
  final DateTime createdAt;

  const SubscriptionEntity({
    required this.subscriptionId,
    required this.memberId,
    required this.packageId,
    required this.startDate,
    required this.expiryDate,
    required this.status,
    required this.amountPaid,
    required this.paymentMode,
    this.paymentReference,
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        subscriptionId,
        memberId,
        packageId,
        startDate,
        expiryDate,
        status,
        amountPaid,
        paymentMode,
        paymentReference,
        createdBy,
        createdAt,
      ];
}

class PaymentEntity extends Equatable {
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

  const PaymentEntity({
    required this.paymentId,
    required this.memberId,
    this.subscriptionId,
    required this.amount,
    required this.paymentMode,
    required this.paymentDate,
    this.receiptNumber,
    this.notes,
    required this.recordedBy,
    required this.createdAt,
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
      ];
}

class AttendanceEntity extends Equatable {
  final String attendanceId;
  final String memberId;
  final String gymId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String markedBy;
  final DateTime attendanceDate;
  final DateTime createdAt;

  const AttendanceEntity({
    required this.attendanceId,
    required this.memberId,
    required this.gymId,
    required this.checkInTime,
    this.checkOutTime,
    required this.markedBy,
    required this.attendanceDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        attendanceId,
        memberId,
        gymId,
        checkInTime,
        checkOutTime,
        markedBy,
        attendanceDate,
        createdAt,
      ];
}
