import 'package:equatable/equatable.dart';
import 'member_entity.dart';
import 'member_related_entities.dart';

class MemberDetailEntity extends Equatable {
  final MemberEntity member;
  final SubscriptionEntity? currentSubscription;
  final List<PaymentEntity> payments;
  final List<AttendanceEntity> attendance;

  const MemberDetailEntity({
    required this.member,
    required this.currentSubscription,
    required this.payments,
    required this.attendance,
  });

  @override
  List<Object?> get props => [member, currentSubscription, payments, attendance];
}

