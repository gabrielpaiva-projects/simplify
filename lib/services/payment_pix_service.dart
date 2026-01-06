import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/payment_pix_model.dart';

class PaymentPixService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<PaymentPixModel>> getPendingPixPayments() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('pagamentos')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      final allPayments = snapshot.docs.map((doc) {
        return PaymentPixModel.fromFirestore(doc.data(), doc.id);
      }).toList();
      
      final pendingPayments = allPayments.where((payment) {
        return payment.isPending && !payment.isExpired;
      }).toList();
      
      pendingPayments.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.createdAt);
          final dateB = DateTime.parse(b.createdAt);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });
      
      return pendingPayments;
    });
  }

  Future<PaymentPixModel?> getPixPaymentById(String paymentId) async {
    try {
      final doc = await _firestore
          .collection('pagamentos')
          .doc(paymentId)
          .get();

      if (doc.exists && doc.data() != null) {
        return PaymentPixModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar pagamento PIX: $e');
      return null;
    }
  }

  Future<int> getTotalPendingPaymentsCount() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return 0;

    try {
      final snapshot = await _firestore
          .collection('pagamentos')
          .where('userId', isEqualTo: currentUser.uid)
          .where('lastWebhookEvent', isEqualTo: 'PAYMENT_CREATED')
          .where('status', isEqualTo: 'PENDING')
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      print('Erro ao contar pagamentos pendentes: $e');
      return 0;
    }
  }

  Stream<List<PaymentPixModel>> getAllPixPayments() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('pagamentos')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      final payments = snapshot.docs.map((doc) {
        return PaymentPixModel.fromFirestore(doc.data(), doc.id);
      }).toList();
      
      payments.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.createdAt);
          final dateB = DateTime.parse(b.createdAt);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });
      
      return payments;
    });
  }

  Stream<List<PaymentPixModel>> getUpcomingPixPayments() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('pagamentos')
        .where('userId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'PAYMENT_RECEIVED')
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final upcomingPayments = <PaymentPixModel>[];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final paymentModel = PaymentPixModel.fromFirestore(data, doc.id);
        
        try {
          if (paymentModel.serviceData.data.isNotEmpty) {
            final serviceDate = DateTime.parse(paymentModel.serviceData.data);
            if (serviceDate.isAfter(now)) {
              upcomingPayments.add(paymentModel);
            }
          }
        } catch (e) {
        }
      }
      
      upcomingPayments.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.serviceData.data);
          final dateB = DateTime.parse(b.serviceData.data);
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });
      
      return upcomingPayments;
    });
  }
}
