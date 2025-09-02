import 'package:equatable/equatable.dart';

/// Service entity representing a service offered in the app
class ServiceEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final ServiceCategory category;
  final double basePrice;
  final String currency;
  final Duration estimatedDuration;
  final List<String> includedItems;
  final bool isActive;
  final String? imageUrl;
  final ServicePricing pricing;
  final List<ServiceAddon>? addons;

  const ServiceEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.basePrice,
    this.currency = 'BRL',
    required this.estimatedDuration,
    required this.includedItems,
    this.isActive = true,
    this.imageUrl,
    required this.pricing,
    this.addons,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        basePrice,
        currency,
        estimatedDuration,
        includedItems,
        isActive,
        imageUrl,
        pricing,
        addons,
      ];
}

/// Service category enumeration
enum ServiceCategory {
  cleaning,
  maintenance,
  repair,
  installation,
  consultation,
  other,
}

/// Service pricing model
class ServicePricing extends Equatable {
  final PricingType type;
  final double basePrice;
  final Map<String, double>? tieredPricing;
  final double? discountPercentage;
  final DateTime? discountValidUntil;

  const ServicePricing({
    required this.type,
    required this.basePrice,
    this.tieredPricing,
    this.discountPercentage,
    this.discountValidUntil,
  });

  double get finalPrice {
    if (discountPercentage != null &&
        discountValidUntil != null &&
        DateTime.now().isBefore(discountValidUntil!)) {
      return basePrice * (1 - discountPercentage! / 100);
    }
    return basePrice;
  }

  @override
  List<Object?> get props => [
        type,
        basePrice,
        tieredPricing,
        discountPercentage,
        discountValidUntil,
      ];
}

/// Pricing type enumeration
enum PricingType {
  fixed,
  hourly,
  perSquareMeter,
  custom,
}

/// Service addon for additional services
class ServiceAddon extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isRequired;

  const ServiceAddon({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.isRequired = false,
  });

  @override
  List<Object> get props => [
        id,
        name,
        description,
        price,
        isRequired,
      ];
}