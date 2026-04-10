import 'package:equatable/equatable.dart';
import 'member_related_entities.dart';

class MemberEntity extends Equatable {
  final String memberId;
  final String gymId;
  final String memberCode;
  final String fullName;
  final String phone;
  final String? email;
  final String? address;
  final String? profilePhotoUrl;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final DateTime? dateOfBirth;
  final String? gender;
  final DateTime joinedDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final List<SubscriptionEntity>? subscriptions;
  final List<PaymentEntity>? payments;
  final List<AttendanceEntity>? attendanceRecords;

  const MemberEntity({
    required this.memberId,
    required this.gymId,
    required this.memberCode,
    required this.fullName,
    required this.phone,
    this.email,
    this.address,
    this.profilePhotoUrl,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.dateOfBirth,
    this.gender,
    required this.joinedDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.subscriptions,
    this.payments,
    this.attendanceRecords,
  });

  bool get isUrgent => true; // Mock for UI
  int get daysLeft => 3; // Mock for UI
  String get packageName => 'Premium Plan'; // Mock for UI

  @override
  List<Object?> get props => [
        memberId,
        gymId,
        memberCode,
        fullName,
        phone,
        email,
        address,
        profilePhotoUrl,
        emergencyContactName,
        emergencyContactPhone,
        dateOfBirth,
        gender,
        joinedDate,
        status,
        createdAt,
        updatedAt,
        notes,
        subscriptions,
        payments,
        attendanceRecords,
      ];
}
