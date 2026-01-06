import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cleaning_pricing_model.dart';
import '../enums/cleaning_type.dart';

class CleaningPricingRepository {
  final FirebaseFirestore _firestore;
  
  CleaningPricingRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;
  
  static const String _collectionName = 'app-config';
  
  final Map<CleaningType, CleaningPricingModel> _cachedPricing = {};
  final Map<CleaningType, DateTime> _lastFetchTime = {};
  static const Duration _cacheValidDuration = Duration(minutes: 30);
  
  Future<CleaningPricingModel> getCleaningPricing({CleaningType type = CleaningType.standard}) async {
    try {
      if (_cachedPricing.containsKey(type) && _lastFetchTime.containsKey(type)) {
        final now = DateTime.now();
        if (now.difference(_lastFetchTime[type]!) < _cacheValidDuration) {
          return _cachedPricing[type]!;
        }
      }
      
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
      
      _cachedPricing[type] = CleaningPricingModel.fromMap(data, type: type);
      _lastFetchTime[type] = DateTime.now();
      
      return _cachedPricing[type]!;
    } catch (e) {
      print('Error fetching cleaning pricing for ${type.displayName}: $e');
      rethrow;
    }
  }
  
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
          
          _cachedPricing[type] = pricing;
          _lastFetchTime[type] = DateTime.now();
          
          return pricing;
        });
  }
  
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