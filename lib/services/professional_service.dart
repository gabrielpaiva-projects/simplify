import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessionalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ProfessionalData?> getProfessionalById(String professionalId) async {
    try {
      print('🔍 [PROFESSIONAL_SERVICE] Buscando profissional: $professionalId');
      print('🔍 [PROFESSIONAL_SERVICE] Collection: users/$professionalId');
      
      final doc = await _firestore
          .collection('users')
          .doc(professionalId)
          .get();

      print('🔍 [PROFESSIONAL_SERVICE] Document exists: ${doc.exists}');
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        print('🔍 [PROFESSIONAL_SERVICE] Document data: $data');
        
        final userType = data['userType'];
        print('🔍 [PROFESSIONAL_SERVICE] UserType: $userType');
        
        if (userType != 'professional') {
          print('🔍 [PROFESSIONAL_SERVICE] Não é profissional, retornando null');
          return null;
        }

        final professional = ProfessionalData.fromFirestore(data, doc.id);
        print('🔍 [PROFESSIONAL_SERVICE] Profissional criado: ${professional.displayName}');
        return professional;
      }
      
      print('🔍 [PROFESSIONAL_SERVICE] Document não existe ou sem dados');
      return null;
    } catch (e) {
      print('❌ [PROFESSIONAL_SERVICE] Erro ao buscar profissional: $e');
      return null;
    }
  }
}

class ProfessionalData {
  final String id;
  final String fullName;
  final String email;
  final String? rg;
  final bool isVerified;
  final String? photoUrl;
  final double? rating;
  final int? totalJobs;

  ProfessionalData({
    required this.id,
    required this.fullName,
    required this.email,
    this.rg,
    this.isVerified = false,
    this.photoUrl,
    this.rating,
    this.totalJobs,
  });

  factory ProfessionalData.fromFirestore(Map<String, dynamic> data, String documentId) {
    return ProfessionalData(
      id: documentId,
      fullName: (data['fullName'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      rg: data['rg']?.toString(),
      isVerified: (data['isVerified'] is bool) ? data['isVerified'] as bool : false,
      photoUrl: data['photoUrl']?.toString(),
      rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : null,
      totalJobs: (data['totalJobs'] is num) ? (data['totalJobs'] as num).toInt() : null,
    );
  }

  String get displayName => fullName.isNotEmpty ? fullName : 'Profissional';
  
  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty && names[0].isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'P';
  }
}
