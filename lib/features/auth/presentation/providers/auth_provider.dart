import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository {
    _init();
  }

  // Estados
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  UserType? _userType;
  Map<String, dynamic>? _userData;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  UserType? get userType => _userType;
  Map<String, dynamic>? get userData => _userData;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get currentUserId => _user?.uid;

  // Inicializar provider
  void _init() {
    _authRepository.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserData();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
        _userData = null;
        _userType = null;
      }
      notifyListeners();
    });
  }

  // Carregar dados do usuário
  Future<void> _loadUserData() async {
    if (_user == null) return;

    final result = await _authRepository.getUserData(_user!.uid);
    result.fold(
      (error) {
        _errorMessage = error;
      },
      (data) {
        _userData = data;
        if (data != null) {
          final typeString = data['userType'] as String?;
          switch (typeString) {
            case 'client':
              _userType = UserType.client;
              break;
            case 'professional':
              _userType = UserType.professional;
              break;
            case 'admin':
              _userType = UserType.admin;
              break;
          }
        }
      },
    );
  }

  // Login
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authRepository.signIn(
      email: email,
      password: password,
    );

    return result.fold(
      (error) {
        _setError(error);
        _setLoading(false);
        return false;
      },
      (credential) {
        _user = credential?.user;
        _setLoading(false);
        return true;
      },
    );
  }

  // Cadastro de Cliente
  Future<bool> signUpClient({
    required ClientModel client,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authRepository.signUpClient(client: client);

    return result.fold(
      (error) {
        _setError(error);
        _setLoading(false);
        return false;
      },
      (credential) {
        _user = credential?.user;
        _userType = UserType.client;
        _setLoading(false);
        return true;
      },
    );
  }

  // Cadastro de Profissional
  Future<bool> signUpProfessional({
    required ProfessionalModel professional,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _authRepository.signUpProfessional(
      professional: professional,
    );

    return result.fold(
      (error) {
        _setError(error);
        _setLoading(false);
        return false;
      },
      (credential) {
        _user = credential?.user;
        _userType = UserType.professional;
        _setLoading(false);
        return true;
      },
    );
  }

  // Logout
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    final result = await _authRepository.signOut();

    result.fold(
      (error) {
        _setError(error);
      },
      (_) {
        _user = null;
        _userData = null;
        _userType = null;
        _status = AuthStatus.unauthenticated;
      },
    );

    _setLoading(false);
  }

  // Resetar senha
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    final result = await _authRepository.resetPassword(email);

    return result.fold(
      (error) {
        _setError(error);
        _setLoading(false);
        return false;
      },
      (_) {
        _setLoading(false);
        return true;
      },
    );
  }

  // Verificar se email está em uso
  Future<bool> isEmailInUse(String email) async {
    final result = await _authRepository.isEmailInUse(email);

    return result.fold(
      (error) => false,
      (inUse) => inUse,
    );
  }

  // Verificar se CPF está em uso
  Future<bool> isCpfInUse(String cpf) async {
    final result = await _authRepository.isCpfInUse(cpf);

    return result.fold(
      (error) => false,
      (inUse) => inUse,
    );
  }

  // Recarregar dados do usuário
  Future<void> reloadUserData() async {
    if (_user != null) {
      await _loadUserData();
      notifyListeners();
    }
  }

  // Métodos auxiliares
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = AuthStatus.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    }
  }

  // Limpar provider
  @override
  void dispose() {
    super.dispose();
  }
}