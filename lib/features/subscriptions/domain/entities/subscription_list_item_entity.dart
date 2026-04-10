import 'package:equatable/equatable.dart';
import '../../../members/domain/entities/member_related_entities.dart';

class SubscriptionListItemEntity extends Equatable {
  final SubscriptionEntity subscription;
  final String memberName;
  final String? memberPhone;
  final String packageName;

  const SubscriptionListItemEntity({
    required this.subscription,
    required this.memberName,
    required this.memberPhone,
    required this.packageName,
  });

  @override
  List<Object?> get props => [subscription, memberName, memberPhone, packageName];
}

