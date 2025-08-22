import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus {
  pending,
  processing,
  paid,
  failed,
  cancelled,
  refunded,
}

enum PaymentMethod {
  cash,
  pix,
  creditCard,
  debitCard,
  bankTransfer,
}

class PaymentModel {
  final String id;
  final String professionalId;
  final String appointmentId;
  final String clientId;
  final String clientName;
  final String serviceName;
  final double amount;
  final double? serviceFee; // Taxa da plataforma
  final double? netAmount; // Valor líquido para o profissional
  final PaymentStatus status;
  final PaymentMethod? paymentMethod;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String? transactionId;
  final String? receiptUrl;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PaymentModel({
    required this.id,
    required this.professionalId,
    required this.appointmentId,
    required this.clientId,
    required this.clientName,
    required this.serviceName,
    required this.amount,
    this.serviceFee,
    this.netAmount,
    required this.status,
    this.paymentMethod,
    required this.dueDate,
    this.paidDate,
    this.transactionId,
    this.receiptUrl,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      professionalId: json['professionalId'] ?? '',
      appointmentId: json['appointmentId'] ?? '',
      clientId: json['clientId'] ?? '',
      clientName: json['clientName'] ?? '',
      serviceName: json['serviceName'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      serviceFee: json['serviceFee']?.toDouble(),
      netAmount: json['netAmount']?.toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['status']}',
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.toString() == 'PaymentMethod.${json['paymentMethod']}',
              orElse: () => PaymentMethod.cash,
            )
          : null,
      dueDate: json['dueDate'] is Timestamp
          ? (json['dueDate'] as Timestamp).toDate()
          : DateTime.parse(json['dueDate']),
      paidDate: json['paidDate'] != null
          ? (json['paidDate'] is Timestamp
              ? (json['paidDate'] as Timestamp).toDate()
              : DateTime.parse(json['paidDate']))
          : null,
      transactionId: json['transactionId'],
      receiptUrl: json['receiptUrl'],
      notes: json['notes'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(json['updatedAt']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professionalId': professionalId,
      'appointmentId': appointmentId,
      'clientId': clientId,
      'clientName': clientName,
      'serviceName': serviceName,
      'amount': amount,
      'serviceFee': serviceFee,
      'netAmount': netAmount,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod?.toString().split('.').last,
      'dueDate': Timestamp.fromDate(dueDate),
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'transactionId': transactionId,
      'receiptUrl': receiptUrl,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  PaymentModel copyWith({
    String? id,
    String? professionalId,
    String? appointmentId,
    String? clientId,
    String? clientName,
    String? serviceName,
    double? amount,
    double? serviceFee,
    double? netAmount,
    PaymentStatus? status,
    PaymentMethod? paymentMethod,
    DateTime? dueDate,
    DateTime? paidDate,
    String? transactionId,
    String? receiptUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      appointmentId: appointmentId ?? this.appointmentId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      serviceName: serviceName ?? this.serviceName,
      amount: amount ?? this.amount,
      serviceFee: serviceFee ?? this.serviceFee,
      netAmount: netAmount ?? this.netAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      transactionId: transactionId ?? this.transactionId,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isPending => status == PaymentStatus.pending;
  bool get isPaid => status == PaymentStatus.paid;
  bool get isOverdue => isPending && dueDate.isBefore(DateTime.now());
  
  double get calculatedNetAmount {
    if (netAmount != null) return netAmount!;
    if (serviceFee != null) return amount - serviceFee!;
    return amount * 0.9; // Default 10% fee
  }

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Dinheiro';
      case PaymentMethod.pix:
        return 'PIX';
      case PaymentMethod.creditCard:
        return 'Cartão de Crédito';
      case PaymentMethod.debitCard:
        return 'Cartão de Débito';
      case PaymentMethod.bankTransfer:
        return 'Transferência Bancária';
      default:
        return 'Não definido';
    }
  }

  String get statusLabel {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pendente';
      case PaymentStatus.processing:
        return 'Processando';
      case PaymentStatus.paid:
        return 'Pago';
      case PaymentStatus.failed:
        return 'Falhou';
      case PaymentStatus.cancelled:
        return 'Cancelado';
      case PaymentStatus.refunded:
        return 'Reembolsado';
    }
  }
}