import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/booking_entity.dart';
import '../entities/service_entity.dart';

/// Service repository interface defining the contract for service operations
abstract class ServiceRepositoryInterface {
  /// Get all available services
  Future<Either<Failure, List<ServiceEntity>>> getAllServices();

  /// Get services by category
  Future<Either<Failure, List<ServiceEntity>>> getServicesByCategory(
    ServiceCategory category,
  );

  /// Get service by ID
  Future<Either<Failure, ServiceEntity>> getServiceById(String serviceId);

  /// Search services
  Future<Either<Failure, List<ServiceEntity>>> searchServices(String query);

  /// Create a new booking
  Future<Either<Failure, BookingEntity>> createBooking({
    required String serviceId,
    required String clientId,
    required DateTime scheduledDate,
    required TimeSlot timeSlot,
    required String addressId,
    required PaymentMethod paymentMethod,
    List<String>? addonIds,
    String? notes,
  });

  /// Get user bookings
  Future<Either<Failure, List<BookingEntity>>> getUserBookings(String userId);

  /// Get booking by ID
  Future<Either<Failure, BookingEntity>> getBookingById(String bookingId);

  /// Update booking status
  Future<Either<Failure, BookingEntity>> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
    String? reason,
  });

  /// Cancel booking
  Future<Either<Failure, void>> cancelBooking({
    required String bookingId,
    required String reason,
  });

  /// Reschedule booking
  Future<Either<Failure, BookingEntity>> rescheduleBooking({
    required String bookingId,
    required DateTime newDate,
    required TimeSlot newTimeSlot,
  });

  /// Rate a completed service
  Future<Either<Failure, void>> rateService({
    required String bookingId,
    required int rating,
    String? comment,
  });

  /// Get available time slots for a service
  Future<Either<Failure, List<TimeSlot>>> getAvailableTimeSlots({
    required String serviceId,
    required DateTime date,
  });

  /// Calculate service price with addons
  Future<Either<Failure, double>> calculateServicePrice({
    required String serviceId,
    List<String>? addonIds,
  });
}