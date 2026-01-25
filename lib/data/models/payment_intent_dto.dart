class PaymentIntentDTO {
  final String id;
  final int amount;
  final String currency;
  final String status;
  final String? clientSecret;
  final DateTime createdAt;

  PaymentIntentDTO({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    this.clientSecret,
    required this.createdAt,
  });

  factory PaymentIntentDTO.fromJson(Map<String, dynamic> json) {
    return PaymentIntentDTO(
      id: json['id'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      clientSecret: json['clientSecret'] as String?,
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
      'amount': amount,
      'currency': currency,
      'status': status,
      if (clientSecret != null) 'clientSecret': clientSecret,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
