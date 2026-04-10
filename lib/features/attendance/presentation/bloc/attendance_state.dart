part of 'attendance_bloc.dart';

class AttendanceState extends Equatable {
  final String? gymId;

  final bool loadingToday;
  final List<AttendanceRecord> today;

  final bool loadingSearch;
  final String? lastQuery;
  final List<MemberSearchResult> results;

  final bool actionInProgress;
  final String? lastActionMessage;

  final Failure? error;

  const AttendanceState({
    this.gymId,
    this.loadingToday = false,
    this.today = const [],
    this.loadingSearch = false,
    this.lastQuery,
    this.results = const [],
    this.actionInProgress = false,
    this.lastActionMessage,
    this.error,
  });

  AttendanceState copyWith({
    String? gymId,
    bool? loadingToday,
    List<AttendanceRecord>? today,
    bool? loadingSearch,
    String? lastQuery,
    List<MemberSearchResult>? results,
    bool? actionInProgress,
    String? lastActionMessage,
    Failure? error,
  }) {
    return AttendanceState(
      gymId: gymId ?? this.gymId,
      loadingToday: loadingToday ?? this.loadingToday,
      today: today ?? this.today,
      loadingSearch: loadingSearch ?? this.loadingSearch,
      lastQuery: lastQuery,
      results: results ?? this.results,
      actionInProgress: actionInProgress ?? this.actionInProgress,
      lastActionMessage: lastActionMessage,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        gymId,
        loadingToday,
        today,
        loadingSearch,
        lastQuery,
        results,
        actionInProgress,
        lastActionMessage,
        error,
      ];
}

