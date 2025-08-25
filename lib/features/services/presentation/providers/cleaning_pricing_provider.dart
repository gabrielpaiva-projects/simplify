import 'package:flutter/foundation.dart';
import '../../data/models/cleaning_pricing_model.dart';
import '../../data/repositories/cleaning_pricing_repository.dart';
import '../../data/enums/cleaning_type.dart';

class CleaningPricingProvider extends ChangeNotifier {
  final CleaningPricingRepository _repository;
  
  // Store pricing for each cleaning type
  final Map<CleaningType, CleaningPricingModel> _pricingMap = {};
  CleaningType _currentType = CleaningType.standard;
  bool _isLoading = false;
  String? _error;
  
  CleaningPricingProvider({
    CleaningPricingRepository? repository,
    CleaningType initialType = CleaningType.standard,
  }) : _repository = repository ?? CleaningPricingRepository(),
       _currentType = initialType {
    // Load pricing data when provider is created
    loadPricingData(type: initialType);
  }
  
  // Getters
  CleaningPricingModel? get pricing => _pricingMap[_currentType];
  CleaningType get currentType => _currentType;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _pricingMap[_currentType] != null;
  
  // Get pricing for a specific type
  CleaningPricingModel? getPricingForType(CleaningType type) => _pricingMap[type];
  
  // Load pricing data from Firestore for a specific type
  Future<void> loadPricingData({CleaningType? type}) async {
    final targetType = type ?? _currentType;
    
    // If we already have data for this type, don't reload unless forced
    if (_pricingMap.containsKey(targetType) && type == null) {
      return;
    }
    
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final pricingData = await _repository.getCleaningPricing(type: targetType);
      _pricingMap[targetType] = pricingData;
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar dados de preços para ${targetType.displayName}: ${e.toString()}';
      _pricingMap.remove(targetType);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Switch cleaning type and load data if needed
  Future<void> switchCleaningType(CleaningType type) async {
    if (_currentType == type && _pricingMap.containsKey(type)) {
      return; // Already on this type with data loaded
    }
    
    _currentType = type;
    notifyListeners();
    
    // Load data for the new type if not already loaded
    if (!_pricingMap.containsKey(type)) {
      await loadPricingData(type: type);
    }
  }
  
  // Reload pricing data (force refresh)
  Future<void> reloadPricingData({CleaningType? type}) async {
    final targetType = type ?? _currentType;
    _repository.clearCache(type: targetType);
    await loadPricingData(type: targetType);
  }
  
  // Calculate price based on current configuration
  double calculatePrice({
    required String residenceType,
    required int rooms,
    required int bathrooms,
    required bool includeProducts,
    required bool includePets,
  }) {
    final pricingData = _pricingMap[_currentType];
    if (pricingData == null) {
      return 0;
    }
    
    return pricingData.calculateTotalPrice(
      residenceType: residenceType,
      rooms: rooms,
      bathrooms: bathrooms,
      includeProducts: includeProducts,
      includePets: includePets,
    );
  }
  
  // Calculate time based on current configuration
  int calculateTime({
    required String residenceType,
    required int rooms,
    required int bathrooms,
    required bool includePets,
  }) {
    final pricingData = _pricingMap[_currentType];
    if (pricingData == null) {
      return 0;
    }
    
    return pricingData.calculateTotalTime(
      residenceType: residenceType,
      rooms: rooms,
      bathrooms: bathrooms,
      includePets: includePets,
    );
  }
  
  // Get base price for a specific residence type
  double getBasePriceForResidence(String residenceType) {
    final pricingData = _pricingMap[_currentType];
    if (pricingData == null) return 0;
    return pricingData.getBasePriceForResidence(residenceType);
  }
  
  // Get base time for a specific residence type
  int getBaseTimeForResidence(String residenceType) {
    final pricingData = _pricingMap[_currentType];
    if (pricingData == null) return 0;
    return pricingData.getBaseTimeForResidence(residenceType);
  }
  
  // Get extra service prices
  double getPetsPrice() {
    return _pricingMap[_currentType]?.petsPrice ?? 0;
  }
  
  double getProductsPrice() {
    return _pricingMap[_currentType]?.productsIncludedPrice ?? 0;
  }
  
  // Get multipliers
  double getRoomMultiplier() {
    return _pricingMap[_currentType]?.roomPriceMultiplier ?? 0;
  }
  
  double getBathroomMultiplier() {
    return _pricingMap[_currentType]?.bathroomPriceMultiplier ?? 0;
  }
  
  // Get pets extra time
  int getPetsExtraTime() {
    return _pricingMap[_currentType]?.petsExtraTime ?? 0;
  }
}