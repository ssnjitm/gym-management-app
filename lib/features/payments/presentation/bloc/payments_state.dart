import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_list_item_entity.dart';

class PaymentsState extends Equatable {
  final bool loading;
  final bool actionInProgress;
  final List<PaymentListItemEntity> items;
  final String? error;
  final String? lastMessage;

  const PaymentsState({
    required this.loading,
    required this.actionInProgress,
    required this.items,
    required this.error,
    required this.lastMessage,
  });

  factory PaymentsState.initial() => const PaymentsState(
        loading: false,
        actionInProgress: false,
        items: [],
        error: null,
        lastMessage: null,
      );

  PaymentsState copyWith({
    bool? loading,
    bool? actionInProgress,
    List<PaymentListItemEntity>? items,
    String? error,
    String? lastMessage,
  }) {
    return PaymentsState(
      loading: loading ?? this.loading,
      actionInProgress: actionInProgress ?? this.actionInProgress,
      items: items ?? this.items,
      error: error,
      lastMessage: lastMessage,
    );
  }

  @override
  List<Object?> get props => [loading, actionInProgress, items, error, lastMessage];
}

