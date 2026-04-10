part of 'member_detail_bloc.dart';

class MemberDetailState extends Equatable {
  final String? memberId;
  final bool loading;
  final MemberDetailEntity? detail;
  final bool actionInProgress;
  final String? lastMessage;
  final Failure? error;

  const MemberDetailState({
    this.memberId,
    this.loading = false,
    this.detail,
    this.actionInProgress = false,
    this.lastMessage,
    this.error,
  });

  MemberDetailState copyWith({
    String? memberId,
    bool? loading,
    MemberDetailEntity? detail,
    bool? actionInProgress,
    String? lastMessage,
    Failure? error,
  }) {
    return MemberDetailState(
      memberId: memberId ?? this.memberId,
      loading: loading ?? this.loading,
      detail: detail ?? this.detail,
      actionInProgress: actionInProgress ?? this.actionInProgress,
      lastMessage: lastMessage,
      error: error,
    );
  }

  @override
  List<Object?> get props => [memberId, loading, detail, actionInProgress, lastMessage, error];
}

