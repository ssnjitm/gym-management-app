import 'package:equatable/equatable.dart';

class AttendanceMemberSummary extends Equatable {
  final String memberId;
  final String fullName;
  final String phone;
  final String memberCode;

  const AttendanceMemberSummary({
    required this.memberId,
    required this.fullName,
    required this.phone,
    required this.memberCode,
  });

  @override
  List<Object?> get props => [memberId, fullName, phone, memberCode];
}

class AttendanceRecord extends Equatable {
  final String attendanceId;
  final String gymId;
  final String memberId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final DateTime attendanceDate;
  final AttendanceMemberSummary member;

  const AttendanceRecord({
    required this.attendanceId,
    required this.gymId,
    required this.memberId,
    required this.checkInTime,
    required this.checkOutTime,
    required this.attendanceDate,
    required this.member,
  });

  bool get isCheckedOut => checkOutTime != null;

  @override
  List<Object?> get props => [
        attendanceId,
        gymId,
        memberId,
        checkInTime,
        checkOutTime,
        attendanceDate,
        member,
      ];
}

class MemberSearchResult extends Equatable {
  final String memberId;
  final String fullName;
  final String phone;
  final String memberCode;
  final String status;

  const MemberSearchResult({
    required this.memberId,
    required this.fullName,
    required this.phone,
    required this.memberCode,
    required this.status,
  });

  @override
  List<Object?> get props => [memberId, fullName, phone, memberCode, status];
}

