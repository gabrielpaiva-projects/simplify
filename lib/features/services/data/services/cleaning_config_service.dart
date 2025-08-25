import '../models/cleaning_config_model.dart';
import '../repositories/cleaning_config_repository.dart';

class CleaningConfigService {
  final CleaningConfigRepository _repository;

  CleaningConfigService({
    CleaningConfigRepository? repository,
  }) : _repository = repository ?? CleaningConfigRepository();

  /// Get the current cleaning configuration
  Future<CleaningConfigModel> getConfig({bool forceRefresh = false}) async {
    return await _repository.getCleaningConfig(forceRefresh: forceRefresh);
  }

  /// Stream for real-time configuration updates
  Stream<CleaningConfigModel> getConfigStream() {
    return _repository.getConfigStream();
  }

  /// Calculate price for a cleaning service
  Future<double> calculatePrice({
    required String residenceType,
    required int rooms,
    required int bathrooms,
    bool includeProducts = false,
    bool includePets = false,
  }) async {
    final config = await getConfig();
    
    return config.calculatePrice(
      residenceType: residenceType,
      rooms: rooms,
      bathrooms: bathrooms,
      includeProducts: includeProducts,
      includePets: includePets,
    );
  }

  /// Calculate estimated time for a cleaning service
  Future<int> calculateEstimatedTime({
    required String residenceType,
    required int rooms,
    required int bathrooms,
    bool includePets = false,
  }) async {
    final config = await getConfig();
    
    return config.calculateEstimatedTime(
      residenceType: residenceType,
      rooms: rooms,
      bathrooms: bathrooms,
      includePets: includePets,
    );
  }

  /// Validate room and bathroom counts
  Future<bool> validateRoomAndBathroomCounts({
    required int rooms,
    required int bathrooms,
  }) async {
    final config = await getConfig();
    
    return rooms >= config.getMinRooms() &&
           rooms <= config.getMaxRooms() &&
           bathrooms >= config.getMinBathrooms() &&
           bathrooms <= config.getMaxBathrooms();
  }

  /// Get limits for rooms and bathrooms
  Future<Map<String, int>> getLimits() async {
    final config = await getConfig();
    
    return {
      'minRooms': config.getMinRooms(),
      'maxRooms': config.getMaxRooms(),
      'minBathrooms': config.getMinBathrooms(),
      'maxBathrooms': config.getMaxBathrooms(),
    };
  }

  /// Initialize configuration with default values if not exists
  Future<void> initializeConfig() async {
    await _repository.getCleaningConfig();
  }

  /// Clear cached configuration
  void clearCache() {
    _repository.clearCache();
  }
}