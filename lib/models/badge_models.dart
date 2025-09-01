/// Modelo para payload de badge PIX
class PixBadgePayload {
  final String userId;
  final double amount;
  final int timestamp;

  PixBadgePayload({
    required this.userId,
    required this.amount,
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  /// Converte para Map para serialização
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'amount': amount,
        'timestamp': timestamp,
      };

  /// Cria a partir de um Map
  factory PixBadgePayload.fromJson(Map<String, dynamic> json) {
    return PixBadgePayload(
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: json['timestamp'] as int,
    );
  }

  @override
  String toString() =>
      'PixBadgePayload(userId: $userId, amount: $amount, timestamp: $timestamp)';
}

/// Modelo para payload de badge de Cartão
class CardBadgePayload {
  final String userId;
  final double amount;
  final String cardNumber;
  final String expirationYear;
  final String expirationMonth;
  final String securityCode;
  final int installments;
  final int timestamp;

  CardBadgePayload({
    required this.userId,
    required this.amount,
    required this.cardNumber,
    required this.expirationYear,
    required this.expirationMonth,
    required this.securityCode,
    this.installments = 1,
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  /// Converte para Map para serialização
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'amount': amount,
        'cardNumber': cardNumber.replaceAll(' ', ''),
        'expirationYear': expirationYear,
        'expirationMonth': expirationMonth,
        'securityCode': securityCode,
        'installments': installments,
        'timestamp': timestamp,
      };

  /// Cria a partir de um Map
  factory CardBadgePayload.fromJson(Map<String, dynamic> json) {
    return CardBadgePayload(
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      cardNumber: json['cardNumber'] as String,
      expirationYear: json['expirationYear'] as String,
      expirationMonth: json['expirationMonth'] as String,
      securityCode: json['securityCode'] as String,
      installments: json['installments'] as int? ?? 1,
      timestamp: json['timestamp'] as int,
    );
  }

  @override
  String toString() =>
      'CardBadgePayload(userId: $userId, amount: $amount, installments: $installments)';
}

/// Tipos de método de pagamento
enum PaymentMethod {
  pix,
  creditCard,
  debitCard,
}

/// Bandeiras de cartão suportadas
enum CardBrand {
  mastercard('master'),
  visa('visa'),
  amex('amex'),
  elo('elo'),
  hipercard('hipercard'),
  unknown('unknown');

  final String paymentMethodId;
  const CardBrand(this.paymentMethodId);
}