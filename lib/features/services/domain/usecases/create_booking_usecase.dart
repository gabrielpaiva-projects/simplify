import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking_entity.dart';
import '../repositories/service_repository_interface.dart';

/// Use case for creating a booking
class CreateBookingUseCase extends UseCase<BookingEntity, CreateBookingParams> {
  final ServiceRepositoryInterface repository;

  CreateBookingUseCase(this.repository);

  @override
  Future<Either<Failure, BookingEntity>> call(
    CreateBookingParams params,
  ) async {
    // Validate scheduling date
    if (params.scheduledDate.isBefore(DateTime.now())) {
      return Left(ValidationFailure('Cannot schedule for past dates'));
    }

    // Validate time slot
    if (params.timeSlot.startTime.isAfter(params.timeSlot.endTime)) {
      return Left(ValidationFailure('Invalid time slot'));
    }

    return await repository.createBooking(
      serviceId: params.serviceId,
      clientId: params.clientId,
      scheduledDate: params.scheduledDate,
      timeSlot: params.timeSlot,
      addressId: params.addressId,
      paymentMethod: params.paymentMethod,
      addonIds: params.addonIds,
      notes: params.notes,
    );
  }
}

/// Parameters for create booking use case
class CreateBookingParams extends Equatable {
  final String serviceId;
  final String clientId;
  final DateTime scheduledDate;
  final TimeSlot timeSlot;
  final String addressId;
  final PaymentMethod paymentMethod;
  final List<String>? addonIds;
  final String? notes;

  const CreateBookingParams({
    required this.serviceId,
    required this.clientId,
    required this.scheduledDate,
    required this.timeSlot,
    required this.addressId,
    required this.paymentMethod,
    this.addonIds,
    this.notes,
  });

  @override
  List<Object?> get props => [
        serviceId,
        clientId,
        scheduledDate,
        timeSlot,
        addressId,
        paymentMethod,
        addonIds,
        notes,
      ];
}