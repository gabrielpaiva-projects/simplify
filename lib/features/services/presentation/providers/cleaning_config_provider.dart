import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/cleaning_config_model.dart';
import '../../data/services/cleaning_config_service.dart';

class CleaningConfigProvider extends ChangeNotifier {
  final CleaningConfigService _configService;
  StreamSubscription<CleaningConfigModel>? _configSubscription;
  
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
    // Listen to real-time updates from Firestore
    listenToConfigUpdates();
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
      _config = null;
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
      throw Exception('Configuration not loaded. Cannot calculate price.');
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
      throw Exception('Configuration not loaded. Cannot calculate estimated time.');
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
    if (_config == null) {
      throw Exception('Configuration not loaded');
    }
    return _config!.getBasePrice(residenceType);
  }

  /// Get base time for a residence type
  int getBaseTime(String residenceType) {
    if (_config == null) {
      throw Exception('Configuration not loaded');
    }
    return _config!.getBaseTime(residenceType);
  }

  /// Get room limits
  int getMinRooms() {
    if (_config == null) {
      throw Exception('Configuration not loaded');
    }
    return _config!.getMinRooms();
  }

  int getMaxRooms() {
    if (_config == null) {
      throw Exception('Configuration not loaded');
    }
    return _config!.getMaxRooms();
  }

  /// Get bathroom limits
  int getMinBathrooms() {
    if (_config == null) {
      throw Exception('Configuration not loaded');
    }
    return _config!.getMinBathrooms();
  }

  int getMaxBathrooms() {
    if (_config == null) {
      throw Exception('Configuration not loaded');
    }
    return _config!.getMaxBathrooms();
  }

  /// Get extra service prices
  double getPetsExtraPrice() {
    if (_config == null) {
      throw Exception('Configuration not loaded');
    }
    return _config!.getPetsExtraPrice();
  }

  double getProductsIncludedPrice() {
    if (_config == null) {
      throw Exception('Configuration not loaded');
    }
    return _config!.getProductsIncludedPrice();
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
    _configSubscription?.cancel();
    _configSubscription = _configService.getConfigStream().listen(
      (newConfig) {
        print('Config updated from Firestore: studio price = ${newConfig.basePrices['studio']}');
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
    _configSubscription?.cancel();
    _configService.clearCache();
    super.dispose();
  }
}