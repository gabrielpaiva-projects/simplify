import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cleaning_config_model.dart';

class CleaningConfigRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'app-config';
  static const String _documentId = 'cleaning_pricing';
  
  // Cache for configuration
  CleaningConfigModel? _cachedConfig;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(hours: 1);

  /// Fetch cleaning configuration from Firestore
  Future<CleaningConfigModel> getCleaningConfig({bool forceRefresh = false}) async {
    // Check if we have a valid cached configuration
    if (!forceRefresh && 
        _cachedConfig != null && 
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration) {
      return _cachedConfig!;
    }

    try {
      final docSnapshot = await _firestore
          .collection(_collectionName)
          .doc(_documentId)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        _cachedConfig = CleaningConfigModel.fromJson(docSnapshot.data()!);
        _lastFetchTime = DateTime.now();
        return _cachedConfig!;
      } else {
        // If document doesn't exist, create it with default values
        final defaultConfig = CleaningConfigModel.defaultConfig();
        await createDefaultConfig(defaultConfig);
        _cachedConfig = defaultConfig;
        _lastFetchTime = DateTime.now();
        return defaultConfig;
      }
    } catch (e) {
      print('Error fetching cleaning config: $e');
      // Return default configuration if there's an error
      return CleaningConfigModel.defaultConfig();
    }
  }

  /// Create default configuration in Firestore
  Future<void> createDefaultConfig(CleaningConfigModel config) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(_documentId)
          .set(config.toJson());
      print('Default cleaning configuration created successfully');
    } catch (e) {
      print('Error creating default config: $e');
    }
  }

  /// Update cleaning configuration in Firestore
  Future<void> updateCleaningConfig(CleaningConfigModel config) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(_documentId)
          .update(config.toJson());
      
      // Update cache
      _cachedConfig = config;
      _lastFetchTime = DateTime.now();
      
      print('Cleaning configuration updated successfully');
    } catch (e) {
      print('Error updating cleaning config: $e');
      throw Exception('Failed to update cleaning configuration');
    }
  }

  /// Update specific field in the configuration
  Future<void> updateConfigField(String fieldPath, dynamic value) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(_documentId)
          .update({fieldPath: value});
      
      // Invalidate cache to force refresh on next fetch
      _cachedConfig = null;
      _lastFetchTime = null;
      
      print('Configuration field $fieldPath updated successfully');
    } catch (e) {
      print('Error updating config field: $e');
      throw Exception('Failed to update configuration field');
    }
  }

  /// Stream for real-time configuration updates
  Stream<CleaningConfigModel> getConfigStream() {
    return _firestore
        .collection(_collectionName)
        .doc(_documentId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            final config = CleaningConfigModel.fromJson(snapshot.data()!);
            // Update cache when we receive new data
            _cachedConfig = config;
            _lastFetchTime = DateTime.now();
            return config;
          } else {
            return CleaningConfigModel.defaultConfig();
          }
        });
  }

  /// Clear cached configuration
  void clearCache() {
    _cachedConfig = null;
    _lastFetchTime = null;
  }
}