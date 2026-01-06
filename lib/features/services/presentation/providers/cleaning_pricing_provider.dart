import 'package:flutter/foundation.dart';
import '../../data/models/cleaning_pricing_model.dart';
import '../../data/repositories/cleaning_pricing_repository.dart';
import '../../data/enums/cleaning_type.dart';

class CleaningPricingProvider extends ChangeNotifier {
  final CleaningPricingRepository _repository;
  
  final Map<CleaningType, CleaningPricingModel> _pricingMap = {};
  CleaningType _currentType = CleaningType.standard;
  bool _isLoading = false;
  String? _error;
  
  CleaningPricingProvider({
    CleaningPricingRepository? repository,
    CleaningType initialType = CleaningType.standard,
  }) : _repository = repository ?? CleaningPricingRepository(),
       _currentType = initialType {
    loadPricingData(type: initialType);
  }
  
  CleaningPricingModel? get pricing => _pricingMap[_currentType];
  CleaningType get currentType => _currentType;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _pricingMap[_currentType] != null;
  
  CleaningPricingModel? getPricingForType(CleaningType type) => _pricingMap[type];
  
  Future<void> loadPricingData({CleaningType? type}) async {
    final targetType = type ?? _currentType;
    
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
  
  Future<void> switchCleaningType(CleaningType type) async {
    if (_currentType == type && _pricingMap.containsKey(type)) {
      return; // Already on this type with data loaded
    }
    
    _currentType = type;
    notifyListeners();
    
    if (!_pricingMap.containsKey(type)) {
      await loadPricingData(type: type);
    }
  }
  
  Future<void> reloadPricingData({CleaningType? type}) async {
    final targetType = type ?? _currentType;
    _repository.clearCache(type: targetType);
    await loadPricingData(type: targetType);
  }
  
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
  
  double getBasePriceForResidence(String residenceType) {
    final pricingData = _pricingMap[_currentType];
    if (pricingData == null) return 0;
    return pricingData.getBasePriceForResidence(residenceType);
  }
  
  int getBaseTimeForResidence(String residenceType) {
    final pricingData = _pricingMap[_currentType];
    if (pricingData == null) return 0;
    return pricingData.getBaseTimeForResidence(residenceType);
  }
  
  double getPetsPrice() {
    return _pricingMap[_currentType]?.petsPrice ?? 0;
  }
  
  double getProductsPrice() {
    return _pricingMap[_currentType]?.productsIncludedPrice ?? 0;
  }
  
  double getRoomMultiplier() {
    return _pricingMap[_currentType]?.roomPriceMultiplier ?? 0;
  }
  
  double getBathroomMultiplier() {
    return _pricingMap[_currentType]?.bathroomPriceMultiplier ?? 0;
  }
  
  int getPetsExtraTime() {
    return _pricingMap[_currentType]?.petsExtraTime ?? 0;
  }
}