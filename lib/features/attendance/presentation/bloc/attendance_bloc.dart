import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/attendance_entities.dart';
import '../../domain/usecases/check_in_usecase.dart';
import '../../domain/usecases/check_out_usecase.dart';
import '../../domain/usecases/get_today_attendance_usecase.dart';
import '../../domain/usecases/search_members_for_attendance_usecase.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GetTodayAttendanceUseCase getTodayAttendance;
  final SearchMembersForAttendanceUseCase searchMembers;
  final CheckInUseCase checkIn;
  final CheckOutUseCase checkOut;

  AttendanceBloc({
    required this.getTodayAttendance,
    required this.searchMembers,
    required this.checkIn,
    required this.checkOut,
  }) : super(const AttendanceState()) {
    on<AttendanceStarted>(_onStarted);
    on<AttendanceSearchRequested>(_onSearch);
    on<AttendanceCheckInRequested>(_onCheckIn);
    on<AttendanceCheckOutRequested>(_onCheckOut);
    on<AttendanceClearSearch>(_onClearSearch);
    on<AttendanceRefreshToday>(_onRefreshToday);
  }

  Future<void> _onStarted(AttendanceStarted event, Emitter<AttendanceState> emit) async {
    emit(state.copyWith(gymId: event.gymId));
    add(const AttendanceRefreshToday());
  }

  Future<void> _onRefreshToday(AttendanceRefreshToday event, Emitter<AttendanceState> emit) async {
    final gymId = state.gymId;
    if (gymId == null || gymId.isEmpty) return;

    emit(state.copyWith(loadingToday: true, error: null));
    final res = await getTodayAttendance(gymId: gymId);
    res.fold(
      (f) => emit(state.copyWith(loadingToday: false, error: f)),
      (records) => emit(state.copyWith(loadingToday: false, today: records)),
    );
  }

  Future<void> _onSearch(AttendanceSearchRequested event, Emitter<AttendanceState> emit) async {
    final gymId = state.gymId;
    if (gymId == null || gymId.isEmpty) return;
    final q = event.query.trim();
    if (q.isEmpty) return;

    emit(state.copyWith(loadingSearch: true, error: null, lastQuery: q));
    final res = await searchMembers(gymId: gymId, query: q);
    res.fold(
      (f) => emit(state.copyWith(loadingSearch: false, error: f, results: const [])),
      (results) => emit(state.copyWith(loadingSearch: false, results: results)),
    );
  }

  Future<void> _onClearSearch(AttendanceClearSearch event, Emitter<AttendanceState> emit) async {
    emit(state.copyWith(results: const [], lastQuery: null, error: null));
  }

  Future<void> _onCheckIn(AttendanceCheckInRequested event, Emitter<AttendanceState> emit) async {
    final gymId = state.gymId;
    if (gymId == null || gymId.isEmpty) return;

    emit(state.copyWith(actionInProgress: true, error: null, lastActionMessage: null));
    final res = await checkIn(gymId: gymId, memberId: event.memberId);
    res.fold(
      (f) => emit(state.copyWith(actionInProgress: false, error: f)),
      (_) {
        emit(state.copyWith(actionInProgress: false, lastActionMessage: 'Checked in'));
        add(const AttendanceRefreshToday());
      },
    );
  }

  Future<void> _onCheckOut(AttendanceCheckOutRequested event, Emitter<AttendanceState> emit) async {
    emit(state.copyWith(actionInProgress: true, error: null, lastActionMessage: null));
    final res = await checkOut(attendanceId: event.attendanceId);
    res.fold(
      (f) => emit(state.copyWith(actionInProgress: false, error: f)),
      (_) {
        emit(state.copyWith(actionInProgress: false, lastActionMessage: 'Checked out'));
        add(const AttendanceRefreshToday());
      },
    );
  }
}

