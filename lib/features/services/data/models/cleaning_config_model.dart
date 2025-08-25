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
    return CleaningConfigModel(
      basePrices: _convertToDoubleMap(json['base_prices'] ?? {}),
      baseTimes: _convertToIntMap(json['base_times'] ?? {}),
      extraServices: _convertToDoubleMap(json['extra_services'] ?? {}),
      limits: _convertToIntMap(json['limits'] ?? {}),
      multipliers: _convertToDoubleMap(json['multipliers'] ?? {}),
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

  // Default configuration
  factory CleaningConfigModel.defaultConfig() {
    return CleaningConfigModel(
      basePrices: {
        'apartment': 149.0,
        'house': 180.0,
        'studio': 90.0,
      },
      baseTimes: {
        'apartment': 120,
        'house': 180,
        'studio': 90,
      },
      extraServices: {
        'pets': 25.0,
        'products_included': 40.0,
      },
      limits: {
        'max_bathrooms': 5,
        'max_rooms': 10,
        'min_bathrooms': 1,
        'min_rooms': 1,
      },
      multipliers: {
        'bathroom_price': 25.0,
        'bathroom_time': 20.0,
        'room_price': 30.0,
        'room_time': 20.0,
        'pets_extra_time': 30.0,
      },
    );
  }

  // Helper methods
  double getBasePrice(String residenceType) {
    return basePrices[residenceType] ?? basePrices['apartment']!;
  }

  int getBaseTime(String residenceType) {
    return baseTimes[residenceType] ?? baseTimes['apartment']!;
  }

  double getPetsExtraPrice() {
    return extraServices['pets'] ?? 25.0;
  }

  double getProductsIncludedPrice() {
    return extraServices['products_included'] ?? 40.0;
  }

  double getRoomPriceMultiplier() {
    return multipliers['room_price'] ?? 30.0;
  }

  double getBathroomPriceMultiplier() {
    return multipliers['bathroom_price'] ?? 25.0;
  }

  double getRoomTimeMultiplier() {
    return multipliers['room_time'] ?? 20.0;
  }

  double getBathroomTimeMultiplier() {
    return multipliers['bathroom_time'] ?? 20.0;
  }

  double getPetsExtraTime() {
    return multipliers['pets_extra_time'] ?? 30.0;
  }

  int getMinRooms() {
    return limits['min_rooms'] ?? 1;
  }

  int getMaxRooms() {
    return limits['max_rooms'] ?? 10;
  }

  int getMinBathrooms() {
    return limits['min_bathrooms'] ?? 1;
  }

  int getMaxBathrooms() {
    return limits['max_bathrooms'] ?? 5;
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