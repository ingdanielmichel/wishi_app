import 'package:wishi_app/data/models/checkout_session_dto.dart';

class CheckoutSession {
  final String id;
  final String orderId;
  final String? paymentIntentClientSecret;
  final String? ephemeralKeySecret;
  final String? customer;
  final String? url;
  final CheckoutSessionStatus status;
  final DateTime createdAt;

  CheckoutSession({
    required this.id,
    required this.orderId,
    this.paymentIntentClientSecret,
    this.ephemeralKeySecret,
    this.customer,
    this.url,
    required this.status,
    required this.createdAt,
  });

  factory CheckoutSession.fromDTO(CheckoutSessionDTO dto) {
    return CheckoutSession(
      id: dto.id,
      orderId: dto.orderId,
      paymentIntentClientSecret: dto.paymentIntentClientSecret,
      ephemeralKeySecret: dto.ephemeralKeySecret,
      customer: dto.customer,
      url: dto.url,
      status: CheckoutSessionStatus.fromJson(dto.status),
      createdAt: dto.createdAt,
    );
  }

  CheckoutSessionDTO toDTO() {
    return CheckoutSessionDTO(
      id: id,
      orderId: orderId,
      paymentIntentClientSecret: paymentIntentClientSecret,
      ephemeralKeySecret: ephemeralKeySecret,
      customer: customer,
      url: url,
      status: status.toJson(),
      createdAt: createdAt,
    );
  }

  CheckoutSession copyWith({
    String? id,
    String? orderId,
    String? paymentIntentClientSecret,
    String? ephemeralKeySecret,
    String? customer,
    String? url,
    CheckoutSessionStatus? status,
    DateTime? createdAt,
  }) {
    return CheckoutSession(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      paymentIntentClientSecret:
          paymentIntentClientSecret ?? this.paymentIntentClientSecret,
      ephemeralKeySecret: ephemeralKeySecret ?? this.ephemeralKeySecret,
      customer: customer ?? this.customer,
      url: url ?? this.url,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum CheckoutSessionStatus {
  open,
  complete,
  expired;

  String toJson() {
    switch (this) {
      case CheckoutSessionStatus.open:
        return 'open';
      case CheckoutSessionStatus.complete:
        return 'complete';
      case CheckoutSessionStatus.expired:
        return 'expired';
    }
  }

  static CheckoutSessionStatus fromJson(String json) {
    switch (json) {
      case 'open':
        return CheckoutSessionStatus.open;
      case 'complete':
        return CheckoutSessionStatus.complete;
      case 'expired':
        return CheckoutSessionStatus.expired;
      default:
        return CheckoutSessionStatus.open;
    }
  }
}
