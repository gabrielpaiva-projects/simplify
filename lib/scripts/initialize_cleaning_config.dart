import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

/// Script to initialize the cleaning configuration in Firestore
/// Run this script once to create the default configuration document
void main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  
  // Configuration data matching EXACTLY the Firestore structure
  // Note: There's a typo in Firestore (max_bathrroms), but we handle it in the model
  final configData = {
    'base_prices': {
      'apartment': 149,
      'house': 180,
      'studio': 90,
    },
    'base_times': {
      'apartment': 120,
      'house': 180,
      'studio': 90,
    },
    'extra_services': {
      'pets': 25,
      'products_included': 40,
    },
    'limits': {
      'min_rooms': 1,
      'max_rooms': 10,
      'min_bathrooms': 1,
      'max_bathrroms': 5,  // Note: typo exists in Firestore
    },
    'multipliers': {
      'room_price': 30,
      'room_time': 20,
      'bathroom_price': 25,
      'bathroom_time': 20,
    },
    'pets_extra_time': 30,  // This is outside multipliers in Firestore
  };

  try {
    // Create or update the configuration document
    await firestore
        .collection('app-config')
        .doc('cleaning_pricing')
        .set(configData);
    
    print('✅ Cleaning configuration initialized successfully!');
    print('Collection: app-config');
    print('Document: cleaning_pricing');
    print('\nConfiguration data:');
    print(configData);
  } catch (e) {
    print('❌ Error initializing configuration: $e');
  }
}