import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment_model.dart';
import 'google_maps_distance_service.dart';

class ProfessionalAvailableServicesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleMapsDistanceService _distanceService = GoogleMapsDistanceService();

  Stream<List<ServiceWithDistance>> getAvailableServicesWithDistance() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('services')
        .where('profissionalId', isEqualTo: null)
        .snapshots()
        .asyncMap((snapshot) async {
      final services = <AppointmentModel>[];
      
      final professionalData = await _getUserData(currentUser.uid);
      if (professionalData == null) {
        return <ServiceWithDistance>[];
      }

      final professionalAddress = _extractAddress(professionalData);
      if (professionalAddress == null) {
        return <ServiceWithDistance>[];
      }

      for (var doc in snapshot.docs) {
        try {
          final service = AppointmentModel.fromFirestore(doc.data(), doc.id);
          services.add(service);
        } catch (e) {
          print('Erro ao converter serviço ${doc.id}: $e');
        }
      }

      final servicesWithDistance = <ServiceWithDistance>[];
      
      for (var service in services) {
        final professionalFullAddress = _formatAddress(professionalAddress);
        final clientFullAddress = _formatAddress(service.endereco);
        
        final distance = await _distanceService.calculateDistance(
          originAddress: professionalFullAddress,
          destinationAddress: clientFullAddress,
        );
        
        servicesWithDistance.add(ServiceWithDistance(
          service: service,
          distance: distance ?? 999.0, // Se falhar, colocar no final da lista
        ));
      }

      servicesWithDistance.sort((a, b) => a.distance.compareTo(b.distance));

      return servicesWithDistance;
    });
  }

  Stream<List<AppointmentModel>> getAvailableServices() {
    return getAvailableServicesWithDistance().map(
      (servicesWithDistance) => servicesWithDistance.map((swd) => swd.service).toList(),
    );
  }

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
      return null;
    }
  }

  AddressModel? _extractAddress(Map<String, dynamic> userData) {
    try {
      return AddressModel(
        cep: userData['cep'] ?? '',
        cidade: userData['city'] ?? '',
        estado: userData['state'] ?? '',
        numero: userData['number'] ?? '',
        rua: userData['street'] ?? '',
      );
    } catch (e) {
      print('Erro ao extrair endereço: $e');
      return null;
    }
  }

  String _formatAddress(AddressModel address) {
    final parts = <String>[];
    
    if (address.rua.isNotEmpty) {
      parts.add(address.rua);
    }
    
    if (address.numero.isNotEmpty) {
      parts.add(address.numero);
    }
    
    if (address.cidade.isNotEmpty) {
      parts.add(address.cidade);
    }
    
    if (address.estado.isNotEmpty) {
      parts.add(address.estado);
    }
    
    if (address.cep.isNotEmpty) {
      parts.add(address.cep);
    }
    
    parts.add('Brasil'); // Sempre adicionar país
    
    return parts.join(', ');
  }


  Future<bool> acceptService(String serviceId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      await _firestore.collection('services').doc(serviceId).update({
        'profissionalId': currentUser.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Erro ao aceitar serviço: $e');
      return false;
    }
  }
}

class ServiceWithDistance {
  final AppointmentModel service;
  final double distance;

  ServiceWithDistance({
    required this.service,
    required this.distance,
  });
}
