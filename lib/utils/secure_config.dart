import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Classe para gerenciar configurações seguras
class SecureConfig {
  static const _storage = FlutterSecureStorage();
  
  // Chaves para armazenamento seguro
  static const String _cryptoKeyKey = 'crypto_secret_key';
  static const String _apiBaseUrlKey = 'api_base_url';
  static const String _environmentKey = 'environment';
  
  // Valores padrão
  static const String _defaultCryptoKey = '75bdb50d-b14c-4b8e-b196-8576b5b013e0';
  static const String _defaultApiBaseUrl = 'https://simplify-backend-paas.onrender.com';
  
  /// Ambiente atual (dev, staging, production)
  static Future<String> get environment async {
    return await _storage.read(key: _environmentKey) ?? 'production';
  }
  
  /// Define o ambiente
  static Future<void> setEnvironment(String env) async {
    await _storage.write(key: _environmentKey, value: env);
  }
  
  /// Obtém a chave de criptografia
  static Future<String> getCryptoKey() async {
    // Primeiro tenta obter do armazenamento seguro
    final storedKey = await _storage.read(key: _cryptoKeyKey);
    if (storedKey != null) {
      return storedKey;
    }
    
    // Se não encontrar, usa a chave padrão baseada no ambiente
    final env = await environment;
    if (env == 'production') {
      // Em produção, você deve configurar isso adequadamente
      // Pode vir de um servidor de configuração remoto, por exemplo
      return _defaultCryptoKey;
    }
    
    return _defaultCryptoKey;
  }
  
  /// Define a chave de criptografia
  static Future<void> setCryptoKey(String key) async {
    await _storage.write(key: _cryptoKeyKey, value: key);
  }
  
  /// Obtém a URL base da API
  static Future<String> getApiBaseUrl() async {
    final storedUrl = await _storage.read(key: _apiBaseUrlKey);
    if (storedUrl != null) {
      return storedUrl;
    }
    
    return _defaultApiBaseUrl;
  }
  
  /// Define a URL base da API
  static Future<void> setApiBaseUrl(String url) async {
    await _storage.write(key: _apiBaseUrlKey, value: url);
  }
  
  /// Limpa todas as configurações armazenadas
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  
  /// Verifica se as configurações estão prontas
  static Future<bool> isConfigured() async {
    final key = await _storage.read(key: _cryptoKeyKey);
    final url = await _storage.read(key: _apiBaseUrlKey);
    return key != null && url != null;
  }
  
  /// Inicializa as configurações com valores padrão se necessário
  static Future<void> initialize({
    String? cryptoKey,
    String? apiBaseUrl,
    String? environment,
  }) async {
    // Define o ambiente se fornecido
    if (environment != null) {
      await setEnvironment(environment);
    }
    
    // Define a chave de criptografia se fornecida
    if (cryptoKey != null) {
      await setCryptoKey(cryptoKey);
    } else {
      // Se não tiver chave armazenada, usa a padrão
      final storedKey = await _storage.read(key: _cryptoKeyKey);
      if (storedKey == null) {
        await setCryptoKey(_defaultCryptoKey);
      }
    }
    
    // Define a URL da API se fornecida
    if (apiBaseUrl != null) {
      await setApiBaseUrl(apiBaseUrl);
    } else {
      // Se não tiver URL armazenada, usa a padrão
      final storedUrl = await _storage.read(key: _apiBaseUrlKey);
      if (storedUrl == null) {
        await setApiBaseUrl(_defaultApiBaseUrl);
      }
    }
  }
  
  /// Obtém todas as configurações atuais (para debug)
  static Future<Map<String, String>> getAllConfigs() async {
    return {
      'environment': await environment,
      'apiBaseUrl': await getApiBaseUrl(),
      'cryptoKeyConfigured': (await _storage.read(key: _cryptoKeyKey)) != null ? 'Yes' : 'No',
    };
  }
}

/// Classe auxiliar para gerenciar badges com configuração segura
class SecureBadgeGenerator {
  /// Gera uma badge PIX usando a chave armazenada de forma segura
  static Future<String> generatePixBadge({
    required String userId,
    required double amount,
    int? timestamp,
  }) async {
    final cryptoKey = await SecureConfig.getCryptoKey();
    
    // Aqui você usaria o BadgeGenerator com a chave segura
    // Por enquanto, retornamos uma string de exemplo
    // Na implementação real, você modificaria o BadgeGenerator para aceitar a chave como parâmetro
    
    return 'encrypted_pix_badge_${userId}_${amount}';
  }
  
  /// Gera uma badge de cartão usando a chave armazenada de forma segura
  static Future<String> generateCardBadge({
    required String userId,
    required double amount,
    required String cardNumber,
    required String expirationYear,
    required String expirationMonth,
    required String securityCode,
    int installments = 1,
    int? timestamp,
  }) async {
    final cryptoKey = await SecureConfig.getCryptoKey();
    
    // Aqui você usaria o BadgeGenerator com a chave segura
    // Por enquanto, retornamos uma string de exemplo
    // Na implementação real, você modificaria o BadgeGenerator para aceitar a chave como parâmetro
    
    return 'encrypted_card_badge_${userId}_${amount}';
  }
}