import 'package:equatable/equatable.dart';

sealed class SubscriptionsEvent extends Equatable {
  const SubscriptionsEvent();

  @override
  List<Object?> get props => [];
}

class SubscriptionsStarted extends SubscriptionsEvent {
  final String gymId;
  const SubscriptionsStarted({required this.gymId});

  @override
  List<Object?> get props => [gymId];
}

class SubscriptionsRefreshRequested extends SubscriptionsEvent {
  final String gymId;
  const SubscriptionsRefreshRequested({required this.gymId});

  @override
  List<Object?> get props => [gymId];
}

class SubscriptionStatusChangeRequested extends SubscriptionsEvent {
  final String subscriptionId;
  final String status;
  final String gymId;

  const SubscriptionStatusChangeRequested({
    required this.subscriptionId,
    required this.status,
    required this.gymId,
  });

  @override
  List<Object?> get props => [subscriptionId, status, gymId];
}

