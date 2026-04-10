import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' as auth;
import '../../../../core/error/failure.dart';
import '../../domain/usecases/get_payments_usecase.dart';
import '../../domain/usecases/record_payment_usecase.dart';
import 'payments_event.dart';
import 'payments_state.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final GetPaymentsUseCase getPayments;
  final RecordGymPaymentUseCase recordPayment;
  final AuthBloc authBloc;

  PaymentsBloc({
    required this.getPayments,
    required this.recordPayment,
    required this.authBloc,
  }) : super(PaymentsState.initial()) {
    on<PaymentsStarted>(_onStarted);
    on<PaymentsRefreshRequested>(_onRefresh);
    on<PaymentRecordRequested>(_onRecord);
  }

  String? _staffId() {
    final s = authBloc.state;
    if (s is auth.AuthAuthenticated) return s.staff.staffId;
    return null;
  }

  Future<void> _onStarted(PaymentsStarted event, Emitter<PaymentsState> emit) async {
    emit(state.copyWith(loading: true, error: null, lastMessage: null));
    final res = await getPayments(gymId: event.gymId);
    res.match(
      (l) => emit(state.copyWith(loading: false, error: l.userMessage)),
      (r) => emit(state.copyWith(loading: false, items: r)),
    );
  }

  Future<void> _onRefresh(PaymentsRefreshRequested event, Emitter<PaymentsState> emit) async {
    add(PaymentsStarted(gymId: event.gymId));
  }

  Future<void> _onRecord(PaymentRecordRequested event, Emitter<PaymentsState> emit) async {
    final staff = _staffId();
    if (staff == null) {
      emit(state.copyWith(error: const AuthFailure(message: 'Not authenticated').userMessage));
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
      recordedBy: staff,
    );

    await res.match(
      (l) async => emit(state.copyWith(actionInProgress: false, error: l.userMessage)),
      (_) async {
        emit(state.copyWith(actionInProgress: false, lastMessage: 'Payment recorded'));
        add(PaymentsStarted(gymId: event.gymId));
      },
    );
  }
}

