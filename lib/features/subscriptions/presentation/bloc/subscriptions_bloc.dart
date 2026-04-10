import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_expiring_subscriptions_usecase.dart';
import '../../domain/usecases/get_subscriptions_usecase.dart';
import '../../domain/usecases/update_subscription_status_usecase.dart';
import 'subscriptions_event.dart';
import 'subscriptions_state.dart';

class SubscriptionsBloc extends Bloc<SubscriptionsEvent, SubscriptionsState> {
  final GetSubscriptionsUseCase getSubscriptions;
  final GetExpiringSubscriptionsUseCase getExpiringSubscriptions;
  final UpdateSubscriptionStatusUseCase updateStatus;

  SubscriptionsBloc({
    required this.getSubscriptions,
    required this.getExpiringSubscriptions,
    required this.updateStatus,
  }) : super(SubscriptionsState.initial()) {
    on<SubscriptionsStarted>(_onStarted);
    on<SubscriptionsRefreshRequested>(_onRefresh);
    on<SubscriptionStatusChangeRequested>(_onStatusChange);
  }

  Future<void> _onStarted(SubscriptionsStarted event, Emitter<SubscriptionsState> emit) async {
    emit(state.copyWith(loadingAll: true, loadingExpiring: true, error: null, lastActionMessage: null));

    final allRes = await getSubscriptions(gymId: event.gymId);
    allRes.match(
      (l) => emit(state.copyWith(loadingAll: false, error: l.userMessage)),
      (r) => emit(state.copyWith(loadingAll: false, all: r, error: null)),
    );

    final expRes = await getExpiringSubscriptions(gymId: event.gymId, withinDays: 7);
    expRes.match(
      (l) => emit(state.copyWith(loadingExpiring: false, error: l.userMessage)),
      (r) => emit(state.copyWith(loadingExpiring: false, expiring: r, error: null)),
    );
  }

  Future<void> _onRefresh(SubscriptionsRefreshRequested event, Emitter<SubscriptionsState> emit) async {
    add(SubscriptionsStarted(gymId: event.gymId));
  }

  Future<void> _onStatusChange(SubscriptionStatusChangeRequested event, Emitter<SubscriptionsState> emit) async {
    emit(state.copyWith(error: null, lastActionMessage: null));
    final res = await updateStatus(subscriptionId: event.subscriptionId, status: event.status);
    await res.match(
      (l) async => emit(state.copyWith(error: l.userMessage)),
      (r) async {
        emit(state.copyWith(lastActionMessage: 'Updated status to "${event.status}"'));
        add(SubscriptionsStarted(gymId: event.gymId));
      },
    );
  }
}

