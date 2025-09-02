/// Modelo de resposta base da API
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'] as String?,
      message: json['message'] as String?,
    );
  }
}

/// Modelo de resposta de pagamento PIX
class PixPaymentResponse {
  final String expirationDate;
  final double amount;
  final String qrCodeBase64;
  final String qrCode;
  final String ticketUrl;
  final int paymentId;
  final String status;

  PixPaymentResponse({
    required this.expirationDate,
    required this.amount,
    required this.qrCodeBase64,
    required this.qrCode,
    required this.ticketUrl,
    required this.paymentId,
    required this.status,
  });

  factory PixPaymentResponse.fromJson(Map<String, dynamic> json) {
    return PixPaymentResponse(
      expirationDate: json['expirationDate'] as String,
      amount: (json['amount'] as num).toDouble(),
      qrCodeBase64: json['qrCodeBase64'] as String,
      qrCode: json['qrCode'] as String,
      ticketUrl: json['ticketUrl'] as String,
      paymentId: json['paymentId'] as int,
      status: json['status'] as String,
    );
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';

  Map<String, dynamic> toJson() => {
        'expirationDate': expirationDate,
        'amount': amount,
        'qrCodeBase64': qrCodeBase64,
        'qrCode': qrCode,
        'ticketUrl': ticketUrl,
        'paymentId': paymentId,
        'status': status,
      };
}

/// Modelo de resposta de pagamento com Cartão
class CardPaymentResponse {
  final String status;
  final String statusDetail;
  final int paymentId;
  final double amount;
  final String? dateApproved;

  CardPaymentResponse({
    required this.status,
    required this.statusDetail,
    required this.paymentId,
    required this.amount,
    this.dateApproved,
  });

  factory CardPaymentResponse.fromJson(Map<String, dynamic> json) {
    return CardPaymentResponse(
      status: json['status'] as String,
      statusDetail: json['statusDetail'] as String,
      paymentId: json['paymentId'] as int,
      amount: (json['amount'] as num).toDouble(),
      dateApproved: json['dateApproved'] as String?,
    );
  }

  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRejected => status.toLowerCase() == 'rejected';

  Map<String, dynamic> toJson() => {
        'status': status,
        'statusDetail': statusDetail,
        'paymentId': paymentId,
        'amount': amount,
        'dateApproved': dateApproved,
      };
}

/// Modelo para informações do cartão (sem dados sensíveis para display)
class CardDisplayInfo {
  final String lastFourDigits;
  final String brand;
  final String holderName;

  CardDisplayInfo({
    required this.lastFourDigits,
    required this.brand,
    required this.holderName,
  });

  factory CardDisplayInfo.fromCardNumber(String cardNumber,
      {String? holderName}) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    final lastFour =
        cleaned.length >= 4 ? cleaned.substring(cleaned.length - 4) : cleaned;

    final brand = _detectCardBrand(cleaned);

    return CardDisplayInfo(
      lastFourDigits: lastFour,
      brand: brand,
      holderName: holderName ?? 'CARD HOLDER',
    );
  }

  static String _detectCardBrand(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'Mastercard';
    if (cardNumber.startsWith('3')) return 'American Express';
    if (cardNumber.startsWith('6')) return 'Discover';
    return 'Unknown';
  }

  String get maskedNumber => '**** **** **** $lastFourDigits';
}