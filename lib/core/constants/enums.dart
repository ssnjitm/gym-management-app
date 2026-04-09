enum ThemeModeType {
  light,
  dark,
  system,
}

enum SubscriptionStatus {
  active,
  grace,
  expired,
  cancelled,
}

enum PaymentMode {
  cash,
  card,
  upi,
  bankTransfer,
}

extension PaymentModeExtension on PaymentMode {
  String get displayName {
    switch (this) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.card:
        return 'Card';
      case PaymentMode.upi:
        return 'UPI';
      case PaymentMode.bankTransfer:
        return 'Bank Transfer';
    }
  }
}