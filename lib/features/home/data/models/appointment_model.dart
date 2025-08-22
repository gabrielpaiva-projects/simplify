import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rescheduled,
}

class AppointmentModel {
  final String id;
  final String professionalId;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final String serviceName;
  final String serviceDescription;
  final DateTime scheduledDate;
  final String timeSlot; // Ex: "09:00 - 10:00"
  final double price;
  final AppointmentStatus status;
  final String address;
  final String addressComplement;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final String? cancellationReason;
  final double? rating;
  final String? review;

  AppointmentModel({
    required this.id,
    required this.professionalId,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.serviceName,
    required this.serviceDescription,
    required this.scheduledDate,
    required this.timeSlot,
    required this.price,
    required this.status,
    required this.address,
    required this.addressComplement,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    this.latitude,
    this.longitude,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.cancellationReason,
    this.rating,
    this.review,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      professionalId: json['professionalId'] ?? '',
      clientId: json['clientId'] ?? '',
      clientName: json['clientName'] ?? '',
      clientPhone: json['clientPhone'] ?? '',
      serviceName: json['serviceName'] ?? '',
      serviceDescription: json['serviceDescription'] ?? '',
      scheduledDate: json['scheduledDate'] is Timestamp
          ? (json['scheduledDate'] as Timestamp).toDate()
          : DateTime.parse(json['scheduledDate']),
      timeSlot: json['timeSlot'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == 'AppointmentStatus.${json['status']}',
        orElse: () => AppointmentStatus.scheduled,
      ),
      address: json['address'] ?? '',
      addressComplement: json['addressComplement'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      notes: json['notes'],
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(json['updatedAt']))
          : null,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] is Timestamp
              ? (json['completedAt'] as Timestamp).toDate()
              : DateTime.parse(json['completedAt']))
          : null,
      cancellationReason: json['cancellationReason'],
      rating: json['rating']?.toDouble(),
      review: json['review'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professionalId': professionalId,
      'clientId': clientId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'serviceName': serviceName,
      'serviceDescription': serviceDescription,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'timeSlot': timeSlot,
      'price': price,
      'status': status.toString().split('.').last,
      'address': address,
      'addressComplement': addressComplement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cancellationReason': cancellationReason,
      'rating': rating,
      'review': review,
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? professionalId,
    String? clientId,
    String? clientName,
    String? clientPhone,
    String? serviceName,
    String? serviceDescription,
    DateTime? scheduledDate,
    String? timeSlot,
    double? price,
    AppointmentStatus? status,
    String? address,
    String? addressComplement,
    String? neighborhood,
    String? city,
    String? state,
    String? zipCode,
    double? latitude,
    double? longitude,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? cancellationReason,
    double? rating,
    String? review,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      serviceName: serviceName ?? this.serviceName,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      price: price ?? this.price,
      status: status ?? this.status,
      address: address ?? this.address,
      addressComplement: addressComplement ?? this.addressComplement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      rating: rating ?? this.rating,
      review: review ?? this.review,
    );
  }

  // Helper methods
  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return scheduledDate.year == tomorrow.year &&
        scheduledDate.month == tomorrow.month &&
        scheduledDate.day == tomorrow.day;
  }

  bool get isPast => scheduledDate.isBefore(DateTime.now());

  bool get isFuture => scheduledDate.isAfter(DateTime.now());

  String get fullAddress {
    return '$address${addressComplement.isNotEmpty ? ', $addressComplement' : ''}, $neighborhood - $city/$state';
  }
}