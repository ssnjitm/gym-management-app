import 'package:equatable/equatable.dart';
import '../../domain/entities/subscription_list_item_entity.dart';

class SubscriptionsState extends Equatable {
  final bool loadingAll;
  final bool loadingExpiring;
  final List<SubscriptionListItemEntity> all;
  final List<SubscriptionListItemEntity> expiring;
  final String? error;
  final String? lastActionMessage;

  const SubscriptionsState({
    required this.loadingAll,
    required this.loadingExpiring,
    required this.all,
    required this.expiring,
    required this.error,
    required this.lastActionMessage,
  });

  factory SubscriptionsState.initial() => const SubscriptionsState(
        loadingAll: false,
        loadingExpiring: false,
        all: [],
        expiring: [],
        error: null,
        lastActionMessage: null,
      );

  SubscriptionsState copyWith({
    bool? loadingAll,
    bool? loadingExpiring,
    List<SubscriptionListItemEntity>? all,
    List<SubscriptionListItemEntity>? expiring,
    String? error,
    String? lastActionMessage,
  }) {
    return SubscriptionsState(
      loadingAll: loadingAll ?? this.loadingAll,
      loadingExpiring: loadingExpiring ?? this.loadingExpiring,
      all: all ?? this.all,
      expiring: expiring ?? this.expiring,
      error: error,
      lastActionMessage: lastActionMessage,
    );
  }

  @override
  List<Object?> get props => [loadingAll, loadingExpiring, all, expiring, error, lastActionMessage];
}

