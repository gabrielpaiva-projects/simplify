import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cleaning_pricing_model.dart';
import '../enums/cleaning_type.dart';

class CleaningPricingRepository {
  final FirebaseFirestore _firestore;
  
  CleaningPricingRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;
  
  // Collection reference
  static const String _collectionName = 'app-confia';
  
  // Cache the pricing data to avoid unnecessary reads (one cache per cleaning type)
  final Map<CleaningType, CleaningPricingModel> _cachedPricing = {};
  final Map<CleaningType, DateTime> _lastFetchTime = {};
  static const Duration _cacheValidDuration = Duration(minutes: 30);
  
  // Get cleaning pricing data from Firestore based on cleaning type
  Future<CleaningPricingModel> getCleaningPricing({CleaningType type = CleaningType.standard}) async {
    try {
      // Check if we have valid cached data for this type
      if (_cachedPricing.containsKey(type) && _lastFetchTime.containsKey(type)) {
        final now = DateTime.now();
        if (now.difference(_lastFetchTime[type]!) < _cacheValidDuration) {
          return _cachedPricing[type]!;
        }
      }
      
      // Fetch from Firestore using the document name from the enum
      final docSnapshot = await _firestore
          .collection(_collectionName)
          .doc(type.documentName)
          .get();
      
      if (!docSnapshot.exists) {
        throw Exception('Pricing document ${type.documentName} not found in Firestore');
      }
      
      final data = docSnapshot.data();
      if (data == null) {
        throw Exception('Pricing document is empty');
      }
      
      // Parse and cache the data
      _cachedPricing[type] = CleaningPricingModel.fromMap(data, type: type);
      _lastFetchTime[type] = DateTime.now();
      
      return _cachedPricing[type]!;
    } catch (e) {
      // Log error and rethrow
      print('Error fetching cleaning pricing for ${type.displayName}: $e');
      rethrow;
    }
  }
  
  // Stream for real-time updates based on cleaning type
  Stream<CleaningPricingModel> watchCleaningPricing({CleaningType type = CleaningType.standard}) {
    return _firestore
        .collection(_collectionName)
        .doc(type.documentName)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            throw Exception('Pricing document ${type.documentName} not found or empty');
          }
          
          final pricing = CleaningPricingModel.fromMap(snapshot.data()!, type: type);
          
          // Update cache when we get new data
          _cachedPricing[type] = pricing;
          _lastFetchTime[type] = DateTime.now();
          
          return pricing;
        });
  }
  
  // Clear cache for a specific type or all types
  void clearCache({CleaningType? type}) {
    if (type != null) {
      _cachedPricing.remove(type);
      _lastFetchTime.remove(type);
    } else {
      _cachedPricing.clear();
      _lastFetchTime.clear();
    }
  }
}