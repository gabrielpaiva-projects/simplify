import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';
import 'service_entity.dart';

/// Booking entity representing a service booking
class BookingEntity extends Equatable {
  final String id;
  final ServiceEntity service;
  final String clientId;
  final String? professionalId;
  final DateTime scheduledDate;
  final TimeSlot timeSlot;
  final BookingStatus status;
  final AddressEntity serviceAddress;
  final double totalPrice;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final List<ServiceAddon> selectedAddons;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final Rating? rating;

  const BookingEntity({
    required this.id,
    required this.service,
    required this.clientId,
    this.professionalId,
    required this.scheduledDate,
    required this.timeSlot,
    required this.status,
    required this.serviceAddress,
    required this.totalPrice,
    required this.paymentMethod,
    required this.paymentStatus,
    this.selectedAddons = const [],
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.rating,
  });

  @override
  List<Object?> get props => [
        id,
        service,
        clientId,
        professionalId,
        scheduledDate,
        timeSlot,
        status,
        serviceAddress,
        totalPrice,
        paymentMethod,
        paymentStatus,
        selectedAddons,
        notes,
        createdAt,
        updatedAt,
        completedAt,
        cancelledAt,
        cancellationReason,
        rating,
      ];
}

/// Time slot for service scheduling
class TimeSlot extends Equatable {
  final DateTime startTime;
  final DateTime endTime;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);

  @override
  List<Object> get props => [startTime, endTime];
}

/// Booking status enumeration
enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rescheduled,
}

/// Payment method enumeration
enum PaymentMethod {
  creditCard,
  debitCard,
  pix,
  cash,
  bankTransfer,
}

/// Payment status enumeration
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  partiallyRefunded,
}

/// Rating for completed services
class Rating extends Equatable {
  final int stars;
  final String? comment;
  final DateTime ratedAt;
  final String ratedBy;

  const Rating({
    required this.stars,
    this.comment,
    required this.ratedAt,
    required this.ratedBy,
  });

  @override
  List<Object?> get props => [stars, comment, ratedAt, ratedBy];
}