class CheckoutSessionDTO {
  final String id;
  final String orderId;
  final String? paymentIntentClientSecret;
  final String? ephemeralKeySecret;
  final String? customer;
  final String? url;
  final String status;
  final DateTime createdAt;

  CheckoutSessionDTO({
    required this.id,
    required this.orderId,
    this.paymentIntentClientSecret,
    this.ephemeralKeySecret,
    this.customer,
    this.url,
    required this.status,
    required this.createdAt,
  });

  factory CheckoutSessionDTO.fromJson(Map<String, dynamic> json) {
    return CheckoutSessionDTO(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      paymentIntentClientSecret:
          json['paymentIntentClientSecret'] as String? ??
          json['payment_intent_client_secret'] as String?,
      ephemeralKeySecret:
          json['ephemeralKeySecret'] as String? ??
          json['ephemeral_key_secret'] as String?,
      customer: json['customer'] as String?,
      url: json['url'] as String?,
      status: json['status'] as String? ?? 'open',
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['createdAt'] as num).toInt(),
            )
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      if (paymentIntentClientSecret != null)
        'paymentIntentClientSecret': paymentIntentClientSecret,
      if (ephemeralKeySecret != null) 'ephemeralKeySecret': ephemeralKeySecret,
      if (customer != null) 'customer': customer,
      if (url != null) 'url': url,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
