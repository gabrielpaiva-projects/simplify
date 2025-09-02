import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/service_entity.dart';
import '../repositories/service_repository_interface.dart';

/// Use case for getting services
class GetServicesUseCase extends UseCase<List<ServiceEntity>, GetServicesParams> {
  final ServiceRepositoryInterface repository;

  GetServicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ServiceEntity>>> call(
    GetServicesParams params,
  ) async {
    if (params.category != null) {
      return await repository.getServicesByCategory(params.category!);
    } else if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
      return await repository.searchServices(params.searchQuery!);
    } else {
      return await repository.getAllServices();
    }
  }
}

/// Parameters for get services use case
class GetServicesParams extends Equatable {
  final ServiceCategory? category;
  final String? searchQuery;

  const GetServicesParams({
    this.category,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [category, searchQuery];
}