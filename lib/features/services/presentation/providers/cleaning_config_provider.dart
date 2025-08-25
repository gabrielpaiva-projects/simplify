import 'package:flutter/foundation.dart';
import '../../data/models/cleaning_config_model.dart';
import '../../data/services/cleaning_config_service.dart';

class CleaningConfigProvider extends ChangeNotifier {
  final CleaningConfigService _configService;
  
  CleaningConfigModel? _config;
  bool _isLoading = false;
  String? _error;

  // Getters
  CleaningConfigModel? get config => _config;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasConfig => _config != null;

  CleaningConfigProvider({
    CleaningConfigService? configService,
  }) : _configService = configService ?? CleaningConfigService() {
    // Initialize configuration on provider creation
    loadConfiguration();
  }

  /// Load configuration from Firestore
  Future<void> loadConfiguration({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _config = await _configService.getConfig(forceRefresh: forceRefresh);
      _error = null;
    } catch (e) {
      _error = 'Failed to load configuration: $e';
      // Use default configuration as fallback
      _config = CleaningConfigModel.defaultConfig();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Calculate price based on current configuration
  double calculatePrice({
    required String residenceType,
    required int rooms,
    required int bathrooms,
    bool includeProducts = false,
    bool includePets = false,
  }) {
    if (_config == null) {
      // Use default configuration if not loaded
      return CleaningConfigModel.defaultConfig().calculatePrice(
        residenceType: residenceType,
        rooms: rooms,
        bathrooms: bathrooms,
        includeProducts: includeProducts,
        includePets: includePets,
      );
    }

    return _config!.calculatePrice(
      residenceType: residenceType,
      rooms: rooms,
      bathrooms: bathrooms,
      includeProducts: includeProducts,
      includePets: includePets,
    );
  }

  /// Calculate estimated time based on current configuration
  int calculateEstimatedTime({
    required String residenceType,
    required int rooms,
    required int bathrooms,
    bool includePets = false,
  }) {
    if (_config == null) {
      // Use default configuration if not loaded
      return CleaningConfigModel.defaultConfig().calculateEstimatedTime(
        residenceType: residenceType,
        rooms: rooms,
        bathrooms: bathrooms,
        includePets: includePets,
      );
    }

    return _config!.calculateEstimatedTime(
      residenceType: residenceType,
      rooms: rooms,
      bathrooms: bathrooms,
      includePets: includePets,
    );
  }

  /// Get base price for a residence type
  double getBasePrice(String residenceType) {
    return _config?.getBasePrice(residenceType) ?? 
           CleaningConfigModel.defaultConfig().getBasePrice(residenceType);
  }

  /// Get base time for a residence type
  int getBaseTime(String residenceType) {
    return _config?.getBaseTime(residenceType) ?? 
           CleaningConfigModel.defaultConfig().getBaseTime(residenceType);
  }

  /// Get room limits
  int getMinRooms() {
    return _config?.getMinRooms() ?? 1;
  }

  int getMaxRooms() {
    return _config?.getMaxRooms() ?? 10;
  }

  /// Get bathroom limits
  int getMinBathrooms() {
    return _config?.getMinBathrooms() ?? 1;
  }

  int getMaxBathrooms() {
    return _config?.getMaxBathrooms() ?? 5;
  }

  /// Get extra service prices
  double getPetsExtraPrice() {
    return _config?.getPetsExtraPrice() ?? 25.0;
  }

  double getProductsIncludedPrice() {
    return _config?.getProductsIncludedPrice() ?? 40.0;
  }

  /// Validate room and bathroom counts
  bool validateCounts({required int rooms, required int bathrooms}) {
    return rooms >= getMinRooms() &&
           rooms <= getMaxRooms() &&
           bathrooms >= getMinBathrooms() &&
           bathrooms <= getMaxBathrooms();
  }

  /// Clear cache and reload configuration
  Future<void> refreshConfiguration() async {
    await loadConfiguration(forceRefresh: true);
  }

  /// Listen to real-time configuration updates
  void listenToConfigUpdates() {
    _configService.getConfigStream().listen(
      (newConfig) {
        _config = newConfig;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Error listening to config updates: $error';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _configService.clearCache();
    super.dispose();
  }
}