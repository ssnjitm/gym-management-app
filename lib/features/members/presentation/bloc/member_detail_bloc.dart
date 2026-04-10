import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' as auth;
import '../../domain/entities/member_detail_entity.dart';
import '../../domain/usecases/get_member_detail_usecase.dart';
import '../../domain/usecases/record_payment_usecase.dart';
import '../../domain/usecases/renew_subscription_usecase.dart';

part 'member_detail_event.dart';
part 'member_detail_state.dart';

class MemberDetailBloc extends Bloc<MemberDetailEvent, MemberDetailState> {
  final GetMemberDetailUseCase getMemberDetail;
  final RecordPaymentUseCase recordPayment;
  final RenewSubscriptionUseCase renewSubscription;
  final AuthBloc authBloc;

  MemberDetailBloc({
    required this.getMemberDetail,
    required this.recordPayment,
    required this.renewSubscription,
    required this.authBloc,
  }) : super(const MemberDetailState()) {
    on<MemberDetailStarted>(_onStarted);
    on<MemberDetailRefreshRequested>(_onRefresh);
    on<MemberDetailRecordPaymentRequested>(_onRecordPayment);
    on<MemberDetailRenewSubscriptionRequested>(_onRenew);
  }

  String? _currentStaffId() {
    final s = authBloc.state;
    if (s is auth.AuthAuthenticated) return s.staff.staffId;
    return null;
  }

  Future<void> _onStarted(MemberDetailStarted event, Emitter<MemberDetailState> emit) async {
    emit(state.copyWith(memberId: event.memberId));
    add(const MemberDetailRefreshRequested());
  }

  Future<void> _onRefresh(MemberDetailRefreshRequested event, Emitter<MemberDetailState> emit) async {
    final memberId = state.memberId;
    if (memberId == null || memberId.isEmpty) return;

    emit(state.copyWith(loading: true, error: null));
    final res = await getMemberDetail(memberId: memberId);
    res.fold(
      (f) => emit(state.copyWith(loading: false, error: f)),
      (detail) => emit(state.copyWith(loading: false, detail: detail)),
    );
  }

  Future<void> _onRecordPayment(
    MemberDetailRecordPaymentRequested event,
    Emitter<MemberDetailState> emit,
  ) async {
    final staffId = _currentStaffId();
    if (staffId == null) {
      emit(state.copyWith(error: const AuthFailure(message: 'Not authenticated')));
      return;
    }

    emit(state.copyWith(actionInProgress: true, error: null, lastMessage: null));
    final res = await recordPayment(
      memberId: event.memberId,
      subscriptionId: event.subscriptionId,
      amount: event.amount,
      paymentMode: event.paymentMode,
      paymentDate: event.paymentDate,
      receiptNumber: event.receiptNumber,
      notes: event.notes,
      recordedBy: staffId,
    );
    res.fold(
      (f) => emit(state.copyWith(actionInProgress: false, error: f)),
      (_) {
        emit(state.copyWith(actionInProgress: false, lastMessage: 'Payment recorded'));
        add(const MemberDetailRefreshRequested());
      },
    );
  }

  Future<void> _onRenew(
    MemberDetailRenewSubscriptionRequested event,
    Emitter<MemberDetailState> emit,
  ) async {
    final staffId = _currentStaffId();
    if (staffId == null) {
      emit(state.copyWith(error: const AuthFailure(message: 'Not authenticated')));
      return;
    }

    emit(state.copyWith(actionInProgress: true, error: null, lastMessage: null));
    final res = await renewSubscription(
      memberId: event.memberId,
      packageId: event.packageId,
      startDate: event.startDate,
      expiryDate: event.expiryDate,
      amountPaid: event.amountPaid,
      paymentMode: event.paymentMode,
      paymentReference: event.paymentReference,
      createdBy: staffId,
    );
    res.fold(
      (f) => emit(state.copyWith(actionInProgress: false, error: f)),
      (_) {
        emit(state.copyWith(actionInProgress: false, lastMessage: 'Subscription renewed'));
        add(const MemberDetailRefreshRequested());
      },
    );
  }
}

