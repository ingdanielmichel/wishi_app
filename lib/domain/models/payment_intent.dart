import 'package:wishi_app/data/models/payment_intent_dto.dart';

class PaymentIntent {
  final String id;
  final int amount;
  final String currency;
  final PaymentIntentStatus status;
  final String? clientSecret;
  final DateTime createdAt;

  PaymentIntent({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    this.clientSecret,
    required this.createdAt,
  });

  factory PaymentIntent.fromDTO(PaymentIntentDTO dto) {
    return PaymentIntent(
      id: dto.id,
      amount: dto.amount,
      currency: dto.currency,
      status: PaymentIntentStatus.fromJson(dto.status),
      clientSecret: dto.clientSecret,
      createdAt: dto.createdAt,
    );
  }

  PaymentIntentDTO toDTO() {
    return PaymentIntentDTO(
      id: id,
      amount: amount,
      currency: currency,
      status: status.toJson(),
      clientSecret: clientSecret,
      createdAt: createdAt,
    );
  }

  PaymentIntent copyWith({
    String? id,
    int? amount,
    String? currency,
    PaymentIntentStatus? status,
    String? clientSecret,
    DateTime? createdAt,
  }) {
    return PaymentIntent(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      clientSecret: clientSecret ?? this.clientSecret,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum PaymentIntentStatus {
  requiresPaymentMethod,
  requiresConfirmation,
  requiresAction,
  processing,
  succeeded,
  canceled;

  String toJson() {
    switch (this) {
      case PaymentIntentStatus.requiresPaymentMethod:
        return 'requires_payment_method';
      case PaymentIntentStatus.requiresConfirmation:
        return 'requires_confirmation';
      case PaymentIntentStatus.requiresAction:
        return 'requires_action';
      case PaymentIntentStatus.processing:
        return 'processing';
      case PaymentIntentStatus.succeeded:
        return 'succeeded';
      case PaymentIntentStatus.canceled:
        return 'canceled';
    }
  }

  static PaymentIntentStatus fromJson(String json) {
    switch (json) {
      case 'requires_payment_method':
        return PaymentIntentStatus.requiresPaymentMethod;
      case 'requires_confirmation':
        return PaymentIntentStatus.requiresConfirmation;
      case 'requires_action':
        return PaymentIntentStatus.requiresAction;
      case 'processing':
        return PaymentIntentStatus.processing;
      case 'succeeded':
        return PaymentIntentStatus.succeeded;
      case 'canceled':
        return PaymentIntentStatus.canceled;
      default:
        return PaymentIntentStatus.requiresPaymentMethod;
    }
  }
}
