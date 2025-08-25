class CleaningPricingModel {
  // Base prices for each property type (in double)
  final double apartmentPrice;
  final double housePrice;
  final double studioPrice;
  
  // Base times for each property type (in minutes as int)
  final int apartmentTime;
  final int houseTime;
  final int studioTime;
  
  // Extra services prices
  final double petsPrice;
  final double productsIncludedPrice;
  
  // Multipliers (stored as percentages)
  final double bathroomPriceMultiplier;
  final double roomPriceMultiplier;
  
  // Extra time for pets (in minutes)
  final int petsExtraTime;
  
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
  });
  
  // Factory constructor to create from Firestore document
  factory CleaningPricingModel.fromMap(Map<String, dynamic> map) {
    // Get base_prices map
    final basePrices = map['base_prices'] as Map<String, dynamic>? ?? {};
    
    // Get base_times map
    final baseTimes = map['base_times'] as Map<String, dynamic>? ?? {};
    
    // Get extra_services map
    final extraServices = map['extra_services'] as Map<String, dynamic>? ?? {};
    
    // Get multipliers map
    final multipliers = map['multipliers'] as Map<String, dynamic>? ?? {};
    
    return CleaningPricingModel(
      // Base prices (stored as double in Firestore)
      apartmentPrice: (basePrices['apartment'] ?? 0).toDouble(),
      housePrice: (basePrices['house'] ?? 0).toDouble(),
      studioPrice: (basePrices['studio'] ?? 0).toDouble(),
      
      // Base times (stored as int in Firestore - minutes)
      apartmentTime: (baseTimes['apartment'] ?? 0).toInt(),
      houseTime: (baseTimes['house'] ?? 0).toInt(),
      studioTime: (baseTimes['studio'] ?? 0).toInt(),
      
      // Extra services
      petsPrice: (extraServices['pets'] ?? 0).toDouble(),
      productsIncludedPrice: (extraServices['products_included'] ?? 0).toDouble(),
      
      // Multipliers (percentages)
      bathroomPriceMultiplier: (multipliers['bathroom_price'] ?? 0).toDouble(),
      roomPriceMultiplier: (multipliers['room_price'] ?? 0).toDouble(),
      
      // Pets extra time
      petsExtraTime: (map['pets_extra_time'] ?? 0).toInt(),
    );
  }
  
  // Helper method to get base price by residence type
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
  
  // Helper method to get base time by residence type
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
  
  // Calculate total price based on configuration
  double calculateTotalPrice({
    required String residenceType,
    required int rooms,
    required int bathrooms,
    required bool includeProducts,
    required bool includePets,
  }) {
    // Start with base price
    double totalPrice = getBasePriceForResidence(residenceType);
    
    // Apply room multiplier for each extra room (compound percentage)
    for (int i = 1; i < rooms; i++) {
      totalPrice = totalPrice * (1 + roomPriceMultiplier / 100);
    }
    
    // Apply bathroom multiplier for each extra bathroom (compound percentage)
    for (int i = 1; i < bathrooms; i++) {
      totalPrice = totalPrice * (1 + bathroomPriceMultiplier / 100);
    }
    
    // Add extra services
    if (includeProducts) {
      totalPrice += productsIncludedPrice;
    }
    
    if (includePets) {
      totalPrice += petsPrice;
    }
    
    return totalPrice;
  }
  
  // Calculate total time based on configuration
  int calculateTotalTime({
    required String residenceType,
    required int rooms,
    required int bathrooms,
    required bool includePets,
  }) {
    // Start with base time
    int totalTime = getBaseTimeForResidence(residenceType);
    
    // Add extra time for pets
    if (includePets) {
      totalTime += petsExtraTime;
    }
    
    // Note: The original code added time for rooms and bathrooms,
    // but since this wasn't specified in the Firestore structure,
    // we'll only use the base time and pets extra time
    
    return totalTime;
  }
}