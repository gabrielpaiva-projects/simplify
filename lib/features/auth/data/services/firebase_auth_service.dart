import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> createClientAccount({
    required ClientModel client,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: client.email,
        password: client.password,
      );

      if (credential.user != null) {
        final clientData = client.toJson();
        clientData['isBlocked'] = false;
        
        await _saveUserToFirestore(
          uid: credential.user!.uid,
          userData: clientData,
        );

        await credential.user!.updateDisplayName(client.fullName);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erro ao criar conta: $e');
    }
  }

  Future<UserCredential?> createProfessionalAccount({
    required ProfessionalModel professional,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: professional.email,
        password: professional.password,
      );

      if (credential.user != null) {
        final professionalData = professional.toJson();
        professionalData['isVerified'] = false; // Sempre false na criação
        professionalData['isBlocked'] = false; // Sempre false na criação
        
        await _saveUserToFirestore(
          uid: credential.user!.uid,
          userData: professionalData,
        );

        await credential.user!.updateDisplayName(professional.fullName);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erro ao criar conta: $e');
    }
  }

  Future<UserCredential?> createAdminAccount({
    required String email,
    required String password,
    required String fullName,
    required Map<String, dynamic> additionalData,
  }) async {
    try {
      final currentUserData = await getUserData(currentUser?.uid ?? '');
      if (currentUserData?['userType'] != 'admin') {
        throw Exception('Apenas administradores podem criar contas de admin');
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final adminData = {
          ...additionalData,
          'email': email,
          'fullName': fullName,
          'userType': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _saveUserToFirestore(
          uid: credential.user!.uid,
          userData: adminData,
        );

        await credential.user!.updateDisplayName(fullName);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erro ao criar conta de admin: $e');
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erro ao enviar email de redefinição: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar dados do usuário: $e');
    }
  }

  Future<UserType?> getUserType(String uid) async {
    try {
      final userData = await getUserData(uid);
      if (userData != null) {
        final typeString = userData['userType'] as String?;
        switch (typeString) {
          case 'client':
            return UserType.client;
          case 'professional':
            return UserType.professional;
          case 'admin':
            return UserType.admin;
          default:
            return null;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao obter tipo de usuário: $e');
    }
  }

  Future<void> updateUserData({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar dados do usuário: $e');
    }
  }

  Future<bool> isEmailInUse(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isCpfInUse(String cpf) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('cpf', isEqualTo: cpf)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveUserToFirestore({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final dataToSave = Map<String, dynamic>.from(userData);
      dataToSave.remove('password');
      
      dataToSave['uid'] = uid;
      dataToSave['createdAt'] = FieldValue.serverTimestamp();
      dataToSave['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(uid).set(dataToSave);
    } catch (e) {
      throw Exception('Erro ao salvar dados do usuário: $e');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'A senha fornecida é muito fraca.';
      case 'email-already-in-use':
        return 'Este email já está cadastrado.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'user-disabled':
        return 'Esta conta foi desabilitada.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'operation-not-allowed':
        return 'Operação não permitida.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }

  bool get isAuthenticated => currentUser != null;

  String? get currentUserId => currentUser?.uid;

  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } catch (e) {
      throw Exception('Erro ao enviar email de verificação: $e');
    }
  }

  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
    } catch (e) {
      throw Exception('Erro ao recarregar usuário: $e');
    }
  }

  Future<bool> isProfessionalVerified(String uid) async {
    try {
      final userData = await getUserData(uid);
      if (userData != null && userData['userType'] == 'professional') {
        return userData['isVerified'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> verifyProfessional(String professionalUid, bool verified) async {
    try {
      final currentUserData = await getUserData(currentUser?.uid ?? '');
      if (currentUserData?['userType'] != 'admin') {
        throw Exception('Apenas administradores podem verificar profissionais');
      }

      final professionalData = await getUserData(professionalUid);
      if (professionalData?['userType'] != 'professional') {
        throw Exception('Apenas profissionais podem ser verificados');
      }

      await _firestore.collection('users').doc(professionalUid).update({
        'isVerified': verified,
        'verifiedAt': verified ? FieldValue.serverTimestamp() : null,
        'verifiedBy': verified ? currentUser?.uid : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao verificar profissional: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUnverifiedProfessionals() async {
    try {
      final currentUserData = await getUserData(currentUser?.uid ?? '');
      if (currentUserData?['userType'] != 'admin') {
        throw Exception('Apenas administradores podem acessar esta lista');
      }

      final query = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'professional')
          .where('isVerified', isEqualTo: false)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar profissionais não verificados: $e');
    }
  }

  Future<bool> isUserBlocked(String uid) async {
    try {
      final userData = await getUserData(uid);
      if (userData != null) {
        return userData['isBlocked'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> blockUser(String userUid, bool blocked) async {
    try {
      final currentUserData = await getUserData(currentUser?.uid ?? '');
      if (currentUserData?['userType'] != 'admin') {
        throw Exception('Apenas administradores podem bloquear/desbloquear usuários');
      }

      await _firestore.collection('users').doc(userUid).update({
        'isBlocked': blocked,
        'blockedAt': blocked ? FieldValue.serverTimestamp() : null,
        'blockedBy': blocked ? currentUser?.uid : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao bloquear/desbloquear usuário: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBlockedUsers() async {
    try {
      final currentUserData = await getUserData(currentUser?.uid ?? '');
      if (currentUserData?['userType'] != 'admin') {
        throw Exception('Apenas administradores podem acessar esta lista');
      }

      final query = await _firestore
          .collection('users')
          .where('isBlocked', isEqualTo: true)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar usuários bloqueados: $e');
    }
  }
}