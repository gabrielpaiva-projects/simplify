import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import 'auth_state.dart';

// part 'auth_provider.g.dart'; // Will be generated

@riverpod
class Auth extends Notifier<AuthState> {
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final LogoutUseCase _logoutUseCase;
  
  @override
  AuthState build() {
    _loginUseCase = getIt<LoginUseCase>();
    _registerUseCase = getIt<RegisterUseCase>();
    _logoutUseCase = getIt<LogoutUseCase>();
    
    return const AuthState.initial();
  }
  
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    
    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );
    
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }
  
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AuthState.loading();
    
    final result = await _registerUseCase(
      RegisterParams(
        email: email,
        password: password,
        name: name,
      ),
    );
    
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }
  
  Future<void> logout() async {
    state = const AuthState.loading();
    
    final result = await _logoutUseCase(NoParams());
    
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (_) => state = const AuthState.unauthenticated(),
    );
  }
  
  void clearError() {
    if (state is AuthStateError) {
      state = const AuthState.initial();
    }
  }
}