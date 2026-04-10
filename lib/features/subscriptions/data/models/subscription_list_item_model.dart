import '../../../members/domain/entities/member_related_entities.dart';
import '../../domain/entities/subscription_list_item_entity.dart';

class SubscriptionListItemModel extends SubscriptionListItemEntity {
  const SubscriptionListItemModel({
    required super.subscription,
    required super.memberName,
    required super.memberPhone,
    required super.packageName,
  });

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory SubscriptionListItemModel.fromMap(Map<String, dynamic> map) {
    final members = (map['members'] as Map?)?.cast<String, dynamic>();
    final packages = (map['packages'] as Map?)?.cast<String, dynamic>();

    final subscription = SubscriptionEntity(
      subscriptionId: map['subscription_id']?.toString() ?? '',
      memberId: map['member_id']?.toString() ?? '',
      packageId: map['package_id']?.toString() ?? '',
      startDate: _parseDate(map['start_date']),
      expiryDate: _parseDate(map['expiry_date']),
      status: map['status']?.toString() ?? 'active',
      amountPaid: _parseDouble(map['amount_paid']),
      paymentMode: map['payment_mode']?.toString() ?? '',
      paymentReference: map['payment_reference']?.toString(),
      createdBy: map['created_by']?.toString() ?? '',
      createdAt: _parseDate(map['created_at']),
    );

    return SubscriptionListItemModel(
      subscription: subscription,
      memberName: members?['full_name']?.toString() ?? map['member_id']?.toString() ?? '',
      memberPhone: members?['phone']?.toString(),
      packageName: packages?['package_name']?.toString() ?? map['package_id']?.toString() ?? '',
    );
  }
}

