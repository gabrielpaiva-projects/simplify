import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cleaning_pricing_model.dart';

class CleaningPricingRepository {
  final FirebaseFirestore _firestore;
  
  CleaningPricingRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;
  
  // Collection and document references
  static const String _collectionName = 'app-confia';
  static const String _documentName = 'cleaning_pricing';
  
  // Cache the pricing data to avoid unnecessary reads
  CleaningPricingModel? _cachedPricing;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 30);
  
  // Get cleaning pricing data from Firestore
  Future<CleaningPricingModel> getCleaningPricing() async {
    try {
      // Check if we have valid cached data
      if (_cachedPricing != null && _lastFetchTime != null) {
        final now = DateTime.now();
        if (now.difference(_lastFetchTime!) < _cacheValidDuration) {
          return _cachedPricing!;
        }
      }
      
      // Fetch from Firestore
      final docSnapshot = await _firestore
          .collection(_collectionName)
          .doc(_documentName)
          .get();
      
      if (!docSnapshot.exists) {
        throw Exception('Pricing document not found in Firestore');
      }
      
      final data = docSnapshot.data();
      if (data == null) {
        throw Exception('Pricing document is empty');
      }
      
      // Parse and cache the data
      _cachedPricing = CleaningPricingModel.fromMap(data);
      _lastFetchTime = DateTime.now();
      
      return _cachedPricing!;
    } catch (e) {
      // Log error and rethrow
      print('Error fetching cleaning pricing: $e');
      rethrow;
    }
  }
  
  // Stream for real-time updates (optional)
  Stream<CleaningPricingModel> watchCleaningPricing() {
    return _firestore
        .collection(_collectionName)
        .doc(_documentName)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            throw Exception('Pricing document not found or empty');
          }
          
          final pricing = CleaningPricingModel.fromMap(snapshot.data()!);
          
          // Update cache when we get new data
          _cachedPricing = pricing;
          _lastFetchTime = DateTime.now();
          
          return pricing;
        });
  }
  
  // Clear cache (useful for testing or forcing refresh)
  void clearCache() {
    _cachedPricing = null;
    _lastFetchTime = null;
  }
}