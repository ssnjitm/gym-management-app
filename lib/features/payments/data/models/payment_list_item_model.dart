import '../../domain/entities/payment_list_item_entity.dart';

class PaymentListItemModel extends PaymentListItemEntity {
  const PaymentListItemModel({
    required super.paymentId,
    required super.memberId,
    required super.subscriptionId,
    required super.amount,
    required super.paymentMode,
    required super.paymentDate,
    required super.receiptNumber,
    required super.notes,
    required super.recordedBy,
    required super.createdAt,
    required super.memberName,
    required super.memberCode,
  });

  static DateTime _dt(dynamic v) {
    if (v is DateTime) return v;
    return DateTime.tryParse(v?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static double _num(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  factory PaymentListItemModel.fromMap(Map<String, dynamic> map) {
    final m = (map['members'] as Map?)?.cast<String, dynamic>();
    return PaymentListItemModel(
      paymentId: map['payment_id']?.toString() ?? '',
      memberId: map['member_id']?.toString() ?? '',
      subscriptionId: map['subscription_id']?.toString(),
      amount: _num(map['amount']),
      paymentMode: map['payment_mode']?.toString() ?? '',
      paymentDate: _dt(map['payment_date']),
      receiptNumber: map['receipt_number']?.toString(),
      notes: map['notes']?.toString(),
      recordedBy: map['recorded_by']?.toString() ?? '',
      createdAt: _dt(map['created_at']),
      memberName: m?['full_name']?.toString() ?? map['member_id']?.toString() ?? '',
      memberCode: m?['member_code']?.toString(),
    );
  }
}

