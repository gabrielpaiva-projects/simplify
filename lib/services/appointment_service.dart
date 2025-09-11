import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Busca todos os agendamentos do usuário atual
  Stream<List<AppointmentModel>> getUserAppointments() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('services')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      final appointments = snapshot.docs.map((doc) {
        return AppointmentModel.fromFirestore(doc.data(), doc.id);
      }).toList();
      
      // Ordenar por data no cliente
      appointments.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.data);
          final dateB = DateTime.parse(b.data);
          return dateB.compareTo(dateA); // Mais recente primeiro
        } catch (e) {
          return 0;
        }
      });
      
      return appointments;
    });
  }

  /// Busca agendamentos futuros do usuário
  Stream<List<AppointmentModel>> getUpcomingAppointments() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('services')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final upcomingAppointments = <AppointmentModel>[];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final appointmentModel = AppointmentModel.fromFirestore(data, doc.id);
        
        try {
          final appointmentDate = DateTime.parse(data['data']);
          if (appointmentDate.isAfter(now)) {
            upcomingAppointments.add(appointmentModel);
          }
        } catch (e) {
          // Data inválida, ignora o documento
        }
      }
      
      // Ordenar por data (próximo primeiro)
      upcomingAppointments.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.data);
          final dateB = DateTime.parse(b.data);
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });
      
      return upcomingAppointments;
    });
  }

  /// Busca histórico de agendamentos (passados)
  Stream<List<AppointmentModel>> getAppointmentHistory() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('services')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final pastAppointments = <AppointmentModel>[];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final appointmentModel = AppointmentModel.fromFirestore(data, doc.id);
        
        try {
          final appointmentDate = DateTime.parse(data['data']);
          if (appointmentDate.isBefore(now)) {
            pastAppointments.add(appointmentModel);
          }
        } catch (e) {
          // Data inválida, ignora o documento
        }
      }
      
      // Ordenar por data (mais recente primeiro)
      pastAppointments.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.data);
          final dateB = DateTime.parse(b.data);
          return dateB.compareTo(dateA); // Ordem decrescente
        } catch (e) {
          return 0;
        }
      });
      
      return pastAppointments;
    });
  }

  /// Busca um agendamento específico por ID
  Future<AppointmentModel?> getAppointmentById(String appointmentId) async {
    try {
      final doc = await _firestore
          .collection('services')
          .doc(appointmentId)
          .get();

      if (doc.exists && doc.data() != null) {
        return AppointmentModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar agendamento: $e');
      return null;
    }
  }

  /// Cancela um agendamento (atualiza o status)
  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      await _firestore
          .collection('services')
          .doc(appointmentId)
          .update({
        'paymentStatus': 'CANCELLED',
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Erro ao cancelar agendamento: $e');
      return false;
    }
  }

  /// Conta total de agendamentos do usuário
  Future<int> getTotalAppointmentsCount() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return 0;

    try {
      final snapshot = await _firestore
          .collection('services')
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      print('Erro ao contar agendamentos: $e');
      return 0;
    }
  }

  /// Busca agendamentos por status de pagamento
  Stream<List<AppointmentModel>> getAppointmentsByPaymentStatus(String status) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('services')
        .where('userId', isEqualTo: currentUser.uid)
        .where('paymentStatus', isEqualTo: status)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppointmentModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }
}
