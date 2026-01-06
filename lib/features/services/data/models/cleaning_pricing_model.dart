import '../enums/cleaning_type.dart';

class CleaningPricingModel {
  final double apartmentPrice;
  final double housePrice;
  final double studioPrice;
  
  final int apartmentTime;
  final int houseTime;
  final int studioTime;
  
  final double petsPrice;
  final double productsIncludedPrice;
  
  final double bathroomPriceMultiplier;
  final double roomPriceMultiplier;
  
  final int petsExtraTime;
  
  final CleaningType cleaningType;
  
  CleaningPricingModel({
    required this.apartmentPrice,
    required this.housePrice,
    required this.studioPrice,
    required this.apartmentTime,
    required this.houseTime,
    required this.studioTime,
    required this.petsPrice,
    required this.productsIncludedPrice,
    required this.bathroomPriceMultiplier,
    required this.roomPriceMultiplier,
    required this.petsExtraTime,
    this.cleaningType = CleaningType.standard,
  });
  
  factory CleaningPricingModel.fromMap(Map<String, dynamic> map, {CleaningType? type}) {
    final basePrices = map['base_prices'] as Map<String, dynamic>? ?? {};
    
    final baseTimes = map['base_times'] as Map<String, dynamic>? ?? {};
    
    final extraServices = map['extra_services'] as Map<String, dynamic>? ?? {};
    
    final multipliers = map['multipliers'] as Map<String, dynamic>? ?? {};
    
    return CleaningPricingModel(
      apartmentPrice: (basePrices['apartment'] ?? 0).toDouble(),
      housePrice: (basePrices['house'] ?? 0).toDouble(),
      studioPrice: (basePrices['studio'] ?? 0).toDouble(),
      
      apartmentTime: (baseTimes['apartment'] ?? 0).toInt(),
      houseTime: (baseTimes['house'] ?? 0).toInt(),
      studioTime: (baseTimes['studio'] ?? 0).toInt(),
      
      petsPrice: (extraServices['pets'] ?? 0).toDouble(),
      productsIncludedPrice: (extraServices['products_included'] ?? 0).toDouble(),
      
      bathroomPriceMultiplier: (multipliers['bathroom_price'] ?? 0).toDouble(),
      roomPriceMultiplier: (multipliers['room_price'] ?? 0).toDouble(),
      
      petsExtraTime: (map['pets_extra_time'] ?? 0).toInt(),
      
      cleaningType: type ?? CleaningType.standard,
    );
  }
  
  double getBasePriceForResidence(String residenceType) {
    switch (residenceType) {
      case 'apartment':
        return apartmentPrice;
      case 'house':
        return housePrice;
      case 'studio':
        return studioPrice;
      default:
        return apartmentPrice;
    }
  }
  
  int getBaseTimeForResidence(String residenceType) {
    switch (residenceType) {
      case 'apartment':
        return apartmentTime;
      case 'house':
        return houseTime;
      case 'studio':
        return studioTime;
      default:
        return apartmentTime;
    }
  }
  
  double calculateTotalPrice({
    required String residenceType,
    required int rooms,
    required int bathrooms,
    required bool includeProducts,
    required bool includePets,
  }) {
    double totalPrice = getBasePriceForResidence(residenceType);
    
    for (int i = 1; i < rooms; i++) {
      totalPrice = totalPrice * (1 + roomPriceMultiplier / 100);
    }
    
    for (int i = 1; i < bathrooms; i++) {
      totalPrice = totalPrice * (1 + bathroomPriceMultiplier / 100);
    }
    
    if (includeProducts) {
      totalPrice += productsIncludedPrice;
    }
    
    if (includePets) {
      totalPrice += petsPrice;
    }
    
    return totalPrice;
  }
  
  int calculateTotalTime({
    required String residenceType,
    required int rooms,
    required int bathrooms,
    required bool includePets,
  }) {
    int totalTime = getBaseTimeForResidence(residenceType);
    
    if (includePets) {
      totalTime += petsExtraTime;
    }
    
    
    return totalTime;
  }
}