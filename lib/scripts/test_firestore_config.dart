import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

/// Script to test if Firestore configuration is being read correctly
void main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  
  try {
    // Read the configuration document
    final docSnapshot = await firestore
        .collection('app-config')
        .doc('cleaning_pricing')
        .get();
    
    if (docSnapshot.exists && docSnapshot.data() != null) {
      final data = docSnapshot.data()!;
      
      print('✅ Configuration found in Firestore:');
      print('=====================================');
      
      // Print base prices
      print('\n📊 Base Prices:');
      final basePrices = data['base_prices'] as Map<String, dynamic>?;
      if (basePrices != null) {
        basePrices.forEach((key, value) {
          print('  $key: R\$ $value');
        });
      }
      
      // Print base times
      print('\n⏱️ Base Times:');
      final baseTimes = data['base_times'] as Map<String, dynamic>?;
      if (baseTimes != null) {
        baseTimes.forEach((key, value) {
          print('  $key: $value minutes');
        });
      }
      
      // Print extra services
      print('\n➕ Extra Services:');
      final extraServices = data['extra_services'] as Map<String, dynamic>?;
      if (extraServices != null) {
        extraServices.forEach((key, value) {
          print('  $key: R\$ $value');
        });
      }
      
      // Print limits
      print('\n🔢 Limits:');
      final limits = data['limits'] as Map<String, dynamic>?;
      if (limits != null) {
        limits.forEach((key, value) {
          print('  $key: $value');
        });
      }
      
      // Print multipliers
      print('\n✖️ Multipliers:');
      final multipliers = data['multipliers'] as Map<String, dynamic>?;
      if (multipliers != null) {
        multipliers.forEach((key, value) {
          print('  $key: $value');
        });
      }
      
      // Check for pets_extra_time outside multipliers
      if (data.containsKey('pets_extra_time')) {
        print('\n🐾 Pets Extra Time (outside multipliers): ${data['pets_extra_time']} minutes');
      }
      
      print('\n=====================================');
      print('📝 Raw data from Firestore:');
      print(data);
      
    } else {
      print('❌ Configuration document not found!');
    }
  } catch (e) {
    print('❌ Error reading configuration: $e');
  }
}