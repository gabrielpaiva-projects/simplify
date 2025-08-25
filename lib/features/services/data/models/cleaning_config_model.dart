/// Model for cleaning service configuration
class CleaningConfigModel {
  final Map<String, double> basePrices;
  final Map<String, int> baseTimes;
  final Map<String, double> extraServices;
  final Map<String, int> limits;
  final Map<String, double> multipliers;

  CleaningConfigModel({
    required this.basePrices,
    required this.baseTimes,
    required this.extraServices,
    required this.limits,
    required this.multipliers,
  });

  factory CleaningConfigModel.fromJson(Map<String, dynamic> json) {
    // Handle pets_extra_time that might be outside multipliers in Firestore
    final multipliers = Map<String, dynamic>.from(json['multipliers'] ?? {});
    if (json['pets_extra_time'] != null && !multipliers.containsKey('pets_extra_time')) {
      multipliers['pets_extra_time'] = json['pets_extra_time'];
    }
    
    // Fix typo in Firestore field name
    final limits = Map<String, dynamic>.from(json['limits'] ?? {});
    if (limits.containsKey('max_bathrroms') && !limits.containsKey('max_bathrooms')) {
      limits['max_bathrooms'] = limits['max_bathrroms'];
      limits.remove('max_bathrroms');
    }
    
    return CleaningConfigModel(
      basePrices: _convertToDoubleMap(json['base_prices']),
      baseTimes: _convertToIntMap(json['base_times']),
      extraServices: _convertToDoubleMap(json['extra_services']),
      limits: _convertToIntMap(limits),
      multipliers: _convertToDoubleMap(multipliers),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_prices': basePrices,
      'base_times': baseTimes,
      'extra_services': extraServices,
      'limits': limits,
      'multipliers': multipliers,
    };
  }

  static Map<String, double> _convertToDoubleMap(Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      return MapEntry(
        key.toString(),
        value is int ? value.toDouble() : (value as num).toDouble(),
      );
    });
  }

  static Map<String, int> _convertToIntMap(Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      return MapEntry(
        key.toString(),
        value is double ? value.toInt() : value as int,
      );
    });
  }

  // Removed default configuration - should only use Firestore data
  // This constructor should not be used in production
  factory CleaningConfigModel.empty() {
    throw Exception('Configuration must be loaded from Firestore. No fallback values allowed.');
  }

  // Helper methods
  double getBasePrice(String residenceType) {
    final price = basePrices[residenceType];
    if (price == null) {
      throw Exception('Base price not found for residence type: $residenceType');
    }
    return price;
  }

  int getBaseTime(String residenceType) {
    final time = baseTimes[residenceType];
    if (time == null) {
      throw Exception('Base time not found for residence type: $residenceType');
    }
    return time;
  }

  double getPetsExtraPrice() {
    final price = extraServices['pets'];
    if (price == null) {
      throw Exception('Pets extra price not configured in Firestore');
    }
    return price;
  }

  double getProductsIncludedPrice() {
    final price = extraServices['products_included'];
    if (price == null) {
      throw Exception('Products included price not configured in Firestore');
    }
    return price;
  }

  double getRoomPriceMultiplier() {
    final price = multipliers['room_price'];
    if (price == null) {
      throw Exception('Room price multiplier not configured in Firestore');
    }
    return price;
  }

  double getBathroomPriceMultiplier() {
    final price = multipliers['bathroom_price'];
    if (price == null) {
      throw Exception('Bathroom price multiplier not configured in Firestore');
    }
    return price;
  }

  double getRoomTimeMultiplier() {
    final time = multipliers['room_time'];
    if (time == null) {
      throw Exception('Room time multiplier not configured in Firestore');
    }
    return time;
  }

  double getBathroomTimeMultiplier() {
    final time = multipliers['bathroom_time'];
    if (time == null) {
      throw Exception('Bathroom time multiplier not configured in Firestore');
    }
    return time;
  }

  double getPetsExtraTime() {
    final time = multipliers['pets_extra_time'];
    if (time == null) {
      throw Exception('Pets extra time not configured in Firestore');
    }
    return time;
  }

  int getMinRooms() {
    final limit = limits['min_rooms'];
    if (limit == null) {
      throw Exception('Min rooms limit not configured in Firestore');
    }
    return limit;
  }

  int getMaxRooms() {
    final limit = limits['max_rooms'];
    if (limit == null) {
      throw Exception('Max rooms limit not configured in Firestore');
    }
    return limit;
  }

  int getMinBathrooms() {
    final limit = limits['min_bathrooms'];
    if (limit == null) {
      throw Exception('Min bathrooms limit not configured in Firestore');
    }
    return limit;
  }

  int getMaxBathrooms() {
    final limit = limits['max_bathrooms'];
    if (limit == null) {
      throw Exception('Max bathrooms limit not configured in Firestore');
    }
    return limit;
  }

  // Calculate price based on configuration
  double calculatePrice({
    required String residenceType,
    required int rooms,
    required int bathrooms,
    bool includeProducts = false,
    bool includePets = false,
  }) {
    double price = getBasePrice(residenceType);
    
    // Add extra rooms cost (first 2 rooms are included in base price for apartment/house)
    int baseRooms = residenceType == 'studio' ? 1 : 2;
    if (rooms > baseRooms) {
      price += (rooms - baseRooms) * getRoomPriceMultiplier();
    }
    
    // Add extra bathrooms cost (first bathroom is included in base price)
    if (bathrooms > 1) {
      price += (bathrooms - 1) * getBathroomPriceMultiplier();
    }
    
    // Add extra services
    if (includeProducts) {
      price += getProductsIncludedPrice();
    }
    
    if (includePets) {
      price += getPetsExtraPrice();
    }
    
    return price;
  }

  // Calculate estimated time based on configuration
  int calculateEstimatedTime({
    required String residenceType,
    required int rooms,
    required int bathrooms,
    bool includePets = false,
  }) {
    int time = getBaseTime(residenceType);
    
    // Add extra rooms time (first 2 rooms are included in base time for apartment/house)
    int baseRooms = residenceType == 'studio' ? 1 : 2;
    if (rooms > baseRooms) {
      time += ((rooms - baseRooms) * getRoomTimeMultiplier()).toInt();
    }
    
    // Add extra bathrooms time (first bathroom is included in base time)
    if (bathrooms > 1) {
      time += ((bathrooms - 1) * getBathroomTimeMultiplier()).toInt();
    }
    
    // Add extra time for pets
    if (includePets) {
      time += getPetsExtraTime().toInt();
    }
    
    return time;
  }
}