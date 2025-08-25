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
  
  // Configuration data as specified
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
      'max_bathrooms': 5,
      'max_rooms': 10,
      'min_bathrooms': 1,
      'min_rooms': 1,
    },
    'multipliers': {
      'bathroom_price': 25,
      'bathroom_time': 20,
      'room_price': 30,
      'room_time': 20,
      'pets_extra_time': 30,
    },
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