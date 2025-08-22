import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream para observar mudanças no estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obter usuário atual
  User? get currentUser => _auth.currentUser;

  // Criar conta para Cliente
  Future<UserCredential?> createClientAccount({
    required ClientModel client,
  }) async {
    try {
      // Criar conta no Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: client.email,
        password: client.password,
      );

      // Salvar dados adicionais no Firestore
      if (credential.user != null) {
        await _saveUserToFirestore(
          uid: credential.user!.uid,
          userData: client.toJson(),
        );

        // Atualizar nome do usuário no Firebase Auth
        await credential.user!.updateDisplayName(client.fullName);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erro ao criar conta: $e');
    }
  }

  // Criar conta para Profissional
  Future<UserCredential?> createProfessionalAccount({
    required ProfessionalModel professional,
  }) async {
    try {
      // Criar conta no Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: professional.email,
        password: professional.password,
      );

      // Salvar dados adicionais no Firestore
      if (credential.user != null) {
        // Garantir que isVerified seja false ao criar a conta
        final professionalData = professional.toJson();
        professionalData['isVerified'] = false; // Sempre false na criação
        
        await _saveUserToFirestore(
          uid: credential.user!.uid,
          userData: professionalData,
        );

        // Atualizar nome do usuário no Firebase Auth
        await credential.user!.updateDisplayName(professional.fullName);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erro ao criar conta: $e');
    }
  }

  // Criar conta para Admin (método protegido)
  Future<UserCredential?> createAdminAccount({
    required String email,
    required String password,
    required String fullName,
    required Map<String, dynamic> additionalData,
  }) async {
    try {
      // Verificar se o usuário atual é admin
      final currentUserData = await getUserData(currentUser?.uid ?? '');
      if (currentUserData?['userType'] != 'admin') {
        throw Exception('Apenas administradores podem criar contas de admin');
      }

      // Criar conta no Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Salvar dados adicionais no Firestore
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

        // Atualizar nome do usuário no Firebase Auth
        await credential.user!.updateDisplayName(fullName);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erro ao criar conta de admin: $e');
    }
  }

  // Login com email e senha
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

  // Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  // Resetar senha
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Erro ao enviar email de redefinição: $e');
    }
  }

  // Obter dados do usuário do Firestore
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

  // Obter tipo de usuário
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

  // Atualizar dados do usuário
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

  // Verificar se email já está em uso
  Future<bool> isEmailInUse(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Verificar se CPF já está cadastrado
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

  // Salvar dados do usuário no Firestore
  Future<void> _saveUserToFirestore({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // Remover a senha dos dados antes de salvar
      final dataToSave = Map<String, dynamic>.from(userData);
      dataToSave.remove('password');
      
      // Adicionar timestamps
      dataToSave['uid'] = uid;
      dataToSave['createdAt'] = FieldValue.serverTimestamp();
      dataToSave['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(uid).set(dataToSave);
    } catch (e) {
      throw Exception('Erro ao salvar dados do usuário: $e');
    }
  }

  // Tratamento de exceções do Firebase Auth
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

  // Verificar se o usuário está autenticado
  bool get isAuthenticated => currentUser != null;

  // Obter o UID do usuário atual
  String? get currentUserId => currentUser?.uid;

  // Verificar email do usuário
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } catch (e) {
      throw Exception('Erro ao enviar email de verificação: $e');
    }
  }

  // Verificar se o email foi verificado
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // Recarregar dados do usuário
  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
    } catch (e) {
      throw Exception('Erro ao recarregar usuário: $e');
    }
  }

  // Verificar se o profissional está verificado
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

  // Atualizar status de verificação do profissional (apenas admin pode fazer isso)
  Future<void> verifyProfessional(String professionalUid, bool verified) async {
    try {
      // Verificar se o usuário atual é admin
      final currentUserData = await getUserData(currentUser?.uid ?? '');
      if (currentUserData?['userType'] != 'admin') {
        throw Exception('Apenas administradores podem verificar profissionais');
      }

      // Verificar se o usuário a ser verificado é um profissional
      final professionalData = await getUserData(professionalUid);
      if (professionalData?['userType'] != 'professional') {
        throw Exception('Apenas profissionais podem ser verificados');
      }

      // Atualizar status de verificação
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

  // Obter lista de profissionais não verificados (para admin)
  Future<List<Map<String, dynamic>>> getUnverifiedProfessionals() async {
    try {
      // Verificar se o usuário atual é admin
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
}