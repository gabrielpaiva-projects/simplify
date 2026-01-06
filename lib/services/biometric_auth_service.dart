import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricAuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (!canCheckBiometrics || !isDeviceSupported) {
        return false;
      }
      
      final List<BiometricType> availableBiometrics = 
          await _localAuth.getAvailableBiometrics();
      
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar disponibilidade de biometria: $e');
      return false;
    }
  }

  static Future<BiometricAuthResult> authenticate({
    String reason = 'Por favor, autentique-se para continuar',
  }) async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      
      if (!isAvailable) {
        return BiometricAuthResult(
          isAuthenticated: false,
          error: BiometricError.notAvailable,
          message: 'Biometria não está disponível neste dispositivo',
        );
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // Permite PIN/senha como fallback
          stickyAuth: true, // Mantém a autenticação ativa se o app for minimizado
        ),
      );

      if (didAuthenticate) {
        return BiometricAuthResult(
          isAuthenticated: true,
          message: 'Autenticação bem-sucedida',
        );
      } else {
        return BiometricAuthResult(
          isAuthenticated: false,
          error: BiometricError.failed,
          message: 'Autenticação falhou',
        );
      }
    } on PlatformException catch (e) {
      print('Erro de plataforma na autenticação biométrica: ${e.code} - ${e.message}');
      
      BiometricError error;
      String message;
      
      switch (e.code) {
        case auth_error.notEnrolled:
          error = BiometricError.notEnrolled;
          message = 'Nenhuma biometria cadastrada no dispositivo';
          break;
        case auth_error.lockedOut:
          error = BiometricError.lockedOut;
          message = 'Muitas tentativas. Biometria temporariamente bloqueada';
          break;
        case auth_error.permanentlyLockedOut:
          error = BiometricError.permanentlyLockedOut;
          message = 'Biometria permanentemente bloqueada. Use PIN/senha';
          break;
        case auth_error.notAvailable:
          error = BiometricError.notAvailable;
          message = 'Biometria não disponível';
          break;
        case auth_error.passcodeNotSet:
          error = BiometricError.passcodeNotSet;
          message = 'Nenhum PIN/senha configurado no dispositivo';
          break;
        case auth_error.otherOperatingSystem:
          error = BiometricError.unsupportedOS;
          message = 'Sistema operacional não suportado';
          break;
        default:
          error = BiometricError.unknown;
          message = 'Erro desconhecido: ${e.message}';
      }
      
      return BiometricAuthResult(
        isAuthenticated: false,
        error: error,
        message: message,
      );
    } catch (e) {
      print('Erro inesperado na autenticação biométrica: $e');
      return BiometricAuthResult(
        isAuthenticated: false,
        error: BiometricError.unknown,
        message: 'Erro inesperado: $e',
      );
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Erro ao obter tipos de biometria disponíveis: $e');
      return [];
    }
  }

  static Future<bool> cancelAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } catch (e) {
      print('Erro ao cancelar autenticação: $e');
      return false;
    }
  }
}

class BiometricAuthResult {
  final bool isAuthenticated;
  final BiometricError? error;
  final String message;

  BiometricAuthResult({
    required this.isAuthenticated,
    this.error,
    required this.message,
  });
}

enum BiometricError {
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut,
  passcodeNotSet,
  unsupportedOS,
  failed,
  unknown,
}