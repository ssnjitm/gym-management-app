import '../../domain/entities/attendance_entities.dart';

class AttendanceMemberSummaryModel extends AttendanceMemberSummary {
  const AttendanceMemberSummaryModel({
    required super.memberId,
    required super.fullName,
    required super.phone,
    required super.memberCode,
  });

  factory AttendanceMemberSummaryModel.fromMap(Map<String, dynamic> map) {
    return AttendanceMemberSummaryModel(
      memberId: map['member_id']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      memberCode: map['member_code']?.toString() ?? '',
    );
  }
}

class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.attendanceId,
    required super.gymId,
    required super.memberId,
    required super.checkInTime,
    required super.checkOutTime,
    required super.attendanceDate,
    required super.member,
  });

  factory AttendanceRecordModel.fromMap(Map<String, dynamic> map) {
    final memberMap = (map['members'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    return AttendanceRecordModel(
      attendanceId: map['attendance_id']?.toString() ?? '',
      gymId: map['gym_id']?.toString() ?? '',
      memberId: map['member_id']?.toString() ?? '',
      checkInTime: DateTime.parse(map['check_in_time'].toString()),
      checkOutTime: map['check_out_time'] == null ? null : DateTime.parse(map['check_out_time'].toString()),
      attendanceDate: DateTime.parse(map['attendance_date'].toString()),
      member: AttendanceMemberSummaryModel.fromMap(memberMap),
    );
  }
}

class MemberSearchResultModel extends MemberSearchResult {
  const MemberSearchResultModel({
    required super.memberId,
    required super.fullName,
    required super.phone,
    required super.memberCode,
    required super.status,
  });

  factory MemberSearchResultModel.fromMap(Map<String, dynamic> map) {
    return MemberSearchResultModel(
      memberId: map['member_id']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      memberCode: map['member_code']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
    );
  }
}

