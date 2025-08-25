import 'package:flutter/foundation.dart';
import '../../data/models/cleaning_pricing_model.dart';
import '../../data/repositories/cleaning_pricing_repository.dart';

class CleaningPricingProvider extends ChangeNotifier {
  final CleaningPricingRepository _repository;
  
  CleaningPricingModel? _pricing;
  bool _isLoading = false;
  String? _error;
  
  CleaningPricingProvider({
    CleaningPricingRepository? repository,
  }) : _repository = repository ?? CleaningPricingRepository() {
    // Load pricing data when provider is created
    loadPricingData();
  }
  
  // Getters
  CleaningPricingModel? get pricing => _pricing;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _pricing != null;
  
  // Load pricing data from Firestore
  Future<void> loadPricingData() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _pricing = await _repository.getCleaningPricing();
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar dados de preços: ${e.toString()}';
      _pricing = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Reload pricing data (force refresh)
  Future<void> reloadPricingData() async {
    _repository.clearCache();
    await loadPricingData();
  }
  
  // Calculate price based on current configuration
  double calculatePrice({
    required String residenceType,
    required int rooms,
    required int bathrooms,
    required bool includeProducts,
    required bool includePets,
  }) {
    if (_pricing == null) {
      return 0;
    }
    
    return _pricing!.calculateTotalPrice(
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
    if (_pricing == null) {
      return 0;
    }
    
    return _pricing!.calculateTotalTime(
      residenceType: residenceType,
      rooms: rooms,
      bathrooms: bathrooms,
      includePets: includePets,
    );
  }
  
  // Get base price for a specific residence type
  double getBasePriceForResidence(String residenceType) {
    if (_pricing == null) return 0;
    return _pricing!.getBasePriceForResidence(residenceType);
  }
  
  // Get base time for a specific residence type
  int getBaseTimeForResidence(String residenceType) {
    if (_pricing == null) return 0;
    return _pricing!.getBaseTimeForResidence(residenceType);
  }
  
  // Get extra service prices
  double getPetsPrice() {
    return _pricing?.petsPrice ?? 0;
  }
  
  double getProductsPrice() {
    return _pricing?.productsIncludedPrice ?? 0;
  }
  
  // Get multipliers
  double getRoomMultiplier() {
    return _pricing?.roomPriceMultiplier ?? 0;
  }
  
  double getBathroomMultiplier() {
    return _pricing?.bathroomPriceMultiplier ?? 0;
  }
  
  // Get pets extra time
  int getPetsExtraTime() {
    return _pricing?.petsExtraTime ?? 0;
  }
}