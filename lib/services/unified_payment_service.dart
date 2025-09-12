import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/payment_pix_model.dart';
import '../models/appointment_model.dart';

class UnifiedPaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Busca todos os documentos da collection pagamentos do usuário atual
  Stream<List<Map<String, dynamic>>> getAllUserPayments() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('pagamentos')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    });
  }

  /// Método de debug para verificar todas as collections
  Future<void> debugAllCollections() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('🔍 [DEBUG] debugAllCollections: Usuário não autenticado');
      return;
    }

    print('🔍 [DEBUG] debugAllCollections: Verificando collections para userId: ${currentUser.uid}');

    // Verificar collection pagamentos
    try {
      final pagamentosSnapshot = await _firestore
          .collection('pagamentos')
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      
      print('🔍 [DEBUG] debugAllCollections: Collection pagamentos - ${pagamentosSnapshot.docs.length} documentos');
      
      for (var doc in pagamentosSnapshot.docs) {
        final data = doc.data();
        print('🔍 [DEBUG] debugAllCollections: Pagamento ${doc.id}: status=${data['status']}, amount=${data['amount']}');
      }
    } catch (e) {
      print('🔍 [DEBUG] debugAllCollections: Erro ao buscar pagamentos: $e');
    }

    // Verificar collection services
    try {
      final servicesSnapshot = await _firestore
          .collection('services')
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      
      print('🔍 [DEBUG] debugAllCollections: Collection services - ${servicesSnapshot.docs.length} documentos');
      
      for (var doc in servicesSnapshot.docs) {
        final data = doc.data();
        print('🔍 [DEBUG] debugAllCollections: Service ${doc.id}: paymentStatus=${data['paymentStatus']}, data=${data['data']}');
      }
    } catch (e) {
      print('🔍 [DEBUG] debugAllCollections: Erro ao buscar services: $e');
    }

    // Verificar collection services sem filtro de userId
    try {
      final allServicesSnapshot = await _firestore
          .collection('services')
          .limit(5)
          .get();
      
      print('🔍 [DEBUG] debugAllCollections: Collection services (sem filtro) - ${allServicesSnapshot.docs.length} documentos');
      
      for (var doc in allServicesSnapshot.docs) {
        final data = doc.data();
        print('🔍 [DEBUG] debugAllCollections: Service geral ${doc.id}: userId=${data['userId']}, paymentStatus=${data['paymentStatus']}');
      }
    } catch (e) {
      print('🔍 [DEBUG] debugAllCollections: Erro ao buscar services sem filtro: $e');
    }
  }

  /// Busca pagamentos pendentes (status PENDING) da collection pagamentos
  Stream<List<Map<String, dynamic>>> getPendingPayments() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('🔍 [DEBUG] getPendingPayments: Usuário não autenticado');
      return Stream.value([]);
    }

    print('🔍 [DEBUG] getPendingPayments: Buscando pagamentos PENDING para userId: ${currentUser.uid}');
    
    return _firestore
        .collection('pagamentos')
        .where('userId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'PENDING')
        .snapshots()
        .map((snapshot) {
      print('🔍 [DEBUG] getPendingPayments: Encontrados ${snapshot.docs.length} documentos');
      
      final result = snapshot.docs.map((doc) {
        final data = doc.data();
        print('🔍 [DEBUG] getPendingPayments: Documento ${doc.id}: status=${data['status']}, amount=${data['amount']}');
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
      
      print('🔍 [DEBUG] getPendingPayments: Retornando ${result.length} pagamentos pendentes');
      return result;
    });
  }

  /// Busca todos os serviços com data futura da collection services
  Stream<List<Map<String, dynamic>>> getUpcomingPayments() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('🔍 [DEBUG] getUpcomingPayments: Usuário não autenticado');
      return Stream.value([]);
    }

    print('🔍 [DEBUG] getUpcomingPayments: Buscando todos os serviços para userId: ${currentUser.uid}');
    
    return _firestore
        .collection('services')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      print('🔍 [DEBUG] getUpcomingPayments: Encontrados ${snapshot.docs.length} documentos na collection services');
      
      final now = DateTime.now();
      final upcomingPayments = <Map<String, dynamic>>[];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('🔍 [DEBUG] getUpcomingPayments: Processando documento ${doc.id}: paymentStatus=${data['paymentStatus']}, data=${data['data']}');
        
        try {
          // Verificar se tem data de serviço e se é futura
          String? serviceDate;
          
          if (data['data'] != null) {
            serviceDate = data['data'].toString();
          }
          
          if (serviceDate != null && serviceDate.isNotEmpty) {
            final parsedDate = DateTime.parse(serviceDate);
            print('🔍 [DEBUG] getUpcomingPayments: Data parseada: $parsedDate, é futura: ${parsedDate.isAfter(now)}');
            
            if (parsedDate.isAfter(now)) {
              upcomingPayments.add({
                'id': doc.id,
                ...data,
              });
              print('🔍 [DEBUG] getUpcomingPayments: Adicionado aos próximos: ${doc.id}');
            }
          } else {
            print('🔍 [DEBUG] getUpcomingPayments: Documento ${doc.id} sem data válida');
          }
        } catch (e) {
          // Data inválida, ignora o documento
          print('🔍 [DEBUG] getUpcomingPayments: Erro ao processar data do documento ${doc.id}: $e');
        }
      }
      
      print('🔍 [DEBUG] getUpcomingPayments: Total de serviços futuros encontrados: ${upcomingPayments.length}');
      
      // Ordenar por data de serviço (próximo primeiro)
      upcomingPayments.sort((a, b) {
        try {
          final dateA = a['data']?.toString();
          final dateB = b['data']?.toString();
          
          if (dateA != null && dateB != null) {
            return DateTime.parse(dateA).compareTo(DateTime.parse(dateB));
          }
          return 0;
        } catch (e) {
          return 0;
        }
      });
      
      return upcomingPayments;
    });
  }

  /// Busca histórico de todos os serviços da collection services
  Stream<List<Map<String, dynamic>>> getPaymentHistory() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('🔍 [DEBUG] getPaymentHistory: Usuário não autenticado');
      return Stream.value([]);
    }

    print('🔍 [DEBUG] getPaymentHistory: Buscando histórico para userId: ${currentUser.uid}');
    
    return _firestore
        .collection('services')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      print('🔍 [DEBUG] getPaymentHistory: Encontrados ${snapshot.docs.length} documentos na collection services');
      
      final now = DateTime.now();
      final historyPayments = <Map<String, dynamic>>[];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('🔍 [DEBUG] getPaymentHistory: Processando documento ${doc.id}: paymentStatus=${data['paymentStatus']}, data=${data['data']}');
        
        try {
          // Verificar se tem data de serviço e se é passada
          String? serviceDate;
          
          if (data['data'] != null) {
            serviceDate = data['data'].toString();
          }
          
          if (serviceDate != null && serviceDate.isNotEmpty) {
            final parsedDate = DateTime.parse(serviceDate);
            print('🔍 [DEBUG] getPaymentHistory: Data parseada: $parsedDate, é passada: ${parsedDate.isBefore(now)}');
            
            if (parsedDate.isBefore(now)) {
              historyPayments.add({
                'id': doc.id,
                ...data,
              });
              print('🔍 [DEBUG] getPaymentHistory: Adicionado ao histórico: ${doc.id}');
            }
          } else {
            print('🔍 [DEBUG] getPaymentHistory: Documento ${doc.id} sem data válida');
          }
        } catch (e) {
          // Data inválida, ignora o documento
          print('🔍 [DEBUG] getPaymentHistory: Erro ao processar data do documento ${doc.id}: $e');
        }
      }
      
      print('🔍 [DEBUG] getPaymentHistory: Total de serviços históricos encontrados: ${historyPayments.length}');
      
      // Ordenar por data de serviço (mais recente primeiro)
      historyPayments.sort((a, b) {
        try {
          final dateA = a['data']?.toString();
          final dateB = b['data']?.toString();
          
          if (dateA != null && dateB != null) {
            return DateTime.parse(dateB).compareTo(DateTime.parse(dateA));
          }
          return 0;
        } catch (e) {
          return 0;
        }
      });
      
      return historyPayments;
    });
  }

  /// Determina se um documento é um PaymentPixModel ou AppointmentModel
  bool isPaymentPixModel(Map<String, dynamic> data) {
    // Verifica se tem campos específicos do PaymentPixModel
    final isPix = data.containsKey('asaasId') || 
           data.containsKey('qrCode') || 
           data.containsKey('lastWebhookEvent') ||
           data.containsKey('serviceData');
    
    print('🔍 [DEBUG] isPaymentPixModel: ${data['id']} -> $isPix (asaasId: ${data.containsKey('asaasId')}, qrCode: ${data.containsKey('qrCode')}, lastWebhookEvent: ${data.containsKey('lastWebhookEvent')}, serviceData: ${data.containsKey('serviceData')})');
    
    return isPix;
  }

  /// Converte dados para PaymentPixModel se possível
  PaymentPixModel? toPaymentPixModel(Map<String, dynamic> data) {
    try {
      print('🔍 [DEBUG] toPaymentPixModel: Tentando converter ${data['id']}');
      
      if (isPaymentPixModel(data)) {
        final result = PaymentPixModel.fromFirestore(data, data['id'] ?? '');
        print('🔍 [DEBUG] toPaymentPixModel: Conversão bem-sucedida para ${data['id']}');
        return result;
      }
      
      print('🔍 [DEBUG] toPaymentPixModel: ${data['id']} não é um PaymentPixModel');
      return null;
    } catch (e) {
      print('🔍 [DEBUG] toPaymentPixModel: Erro ao converter ${data['id']} para PaymentPixModel: $e');
      return null;
    }
  }

  /// Converte dados para AppointmentModel se possível
  AppointmentModel? toAppointmentModel(Map<String, dynamic> data) {
    try {
      print('🔍 [DEBUG] toAppointmentModel: Tentando converter ${data['id']}');
      
      if (!isPaymentPixModel(data)) {
        final result = AppointmentModel.fromFirestore(data, data['id'] ?? '');
        print('🔍 [DEBUG] toAppointmentModel: Conversão bem-sucedida para ${data['id']}');
        return result;
      }
      
      print('🔍 [DEBUG] toAppointmentModel: ${data['id']} não é um AppointmentModel');
      return null;
    } catch (e) {
      print('🔍 [DEBUG] toAppointmentModel: Erro ao converter ${data['id']} para AppointmentModel: $e');
      return null;
    }
  }
}
