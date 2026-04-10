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
  Esewa,
  Khalti,
  bankTransfer,
}

extension PaymentModeExtension on PaymentMode {
  String get displayName {
    switch (this) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.card:
        return 'Card';
      case PaymentMode.Esewa:
        return 'E-sewa';
      case PaymentMode.Khalti:
        return 'Khalti';
        case PaymentMode.bankTransfer:
        return 'Bank Transfer';
    }
  }
}