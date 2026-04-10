part of 'attendance_bloc.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class AttendanceStarted extends AttendanceEvent {
  final String gymId;

  const AttendanceStarted({required this.gymId});

  @override
  List<Object?> get props => [gymId];
}

class AttendanceRefreshToday extends AttendanceEvent {
  const AttendanceRefreshToday();
}

class AttendanceSearchRequested extends AttendanceEvent {
  final String query;

  const AttendanceSearchRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

class AttendanceClearSearch extends AttendanceEvent {
  const AttendanceClearSearch();
}

class AttendanceCheckInRequested extends AttendanceEvent {
  final String memberId;

  const AttendanceCheckInRequested({required this.memberId});

  @override
  List<Object?> get props => [memberId];
}

class AttendanceCheckOutRequested extends AttendanceEvent {
  final String attendanceId;

  const AttendanceCheckOutRequested({required this.attendanceId});

  @override
  List<Object?> get props => [attendanceId];
}

