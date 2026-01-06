import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureConfig {
  static const _storage = FlutterSecureStorage();
  
  static const String _cryptoKeyKey = 'crypto_secret_key';
  static const String _apiBaseUrlKey = 'api_base_url';
  static const String _environmentKey = 'environment';
  
  static const String _defaultCryptoKey = '75bdb50d-b14c-4b8e-b196-8576b5b013e0';
  static const String _defaultApiBaseUrl = 'https://simplify-backend-paas.onrender.com';
  
  static Future<String> get environment async {
    return await _storage.read(key: _environmentKey) ?? 'production';
  }
  
  static Future<void> setEnvironment(String env) async {
    await _storage.write(key: _environmentKey, value: env);
  }
  
  static Future<String> getCryptoKey() async {
    final storedKey = await _storage.read(key: _cryptoKeyKey);
    if (storedKey != null) {
      return storedKey;
    }
    
    final env = await environment;
    if (env == 'production') {
      return _defaultCryptoKey;
    }
    
    return _defaultCryptoKey;
  }
  
  static Future<void> setCryptoKey(String key) async {
    await _storage.write(key: _cryptoKeyKey, value: key);
  }
  
  static Future<String> getApiBaseUrl() async {
    final storedUrl = await _storage.read(key: _apiBaseUrlKey);
    if (storedUrl != null) {
      return storedUrl;
    }
    
    return _defaultApiBaseUrl;
  }
  
  static Future<void> setApiBaseUrl(String url) async {
    await _storage.write(key: _apiBaseUrlKey, value: url);
  }
  
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  
  static Future<bool> isConfigured() async {
    final key = await _storage.read(key: _cryptoKeyKey);
    final url = await _storage.read(key: _apiBaseUrlKey);
    return key != null && url != null;
  }
  
  static Future<void> initialize({
    String? cryptoKey,
    String? apiBaseUrl,
    String? environment,
  }) async {
    if (environment != null) {
      await setEnvironment(environment);
    }
    
    if (cryptoKey != null) {
      await setCryptoKey(cryptoKey);
    } else {
      final storedKey = await _storage.read(key: _cryptoKeyKey);
      if (storedKey == null) {
        await setCryptoKey(_defaultCryptoKey);
      }
    }
    
    if (apiBaseUrl != null) {
      await setApiBaseUrl(apiBaseUrl);
    } else {
      final storedUrl = await _storage.read(key: _apiBaseUrlKey);
      if (storedUrl == null) {
        await setApiBaseUrl(_defaultApiBaseUrl);
      }
    }
  }
  
  static Future<Map<String, String>> getAllConfigs() async {
    return {
      'environment': await environment,
      'apiBaseUrl': await getApiBaseUrl(),
      'cryptoKeyConfigured': (await _storage.read(key: _cryptoKeyKey)) != null ? 'Yes' : 'No',
    };
  }
}

class SecureBadgeGenerator {
  static Future<String> generatePixBadge({
    required String userId,
    required double amount,
    int? timestamp,
  }) async {
    final cryptoKey = await SecureConfig.getCryptoKey();
    
    
    return 'encrypted_pix_badge_${userId}_${amount}';
  }
  
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
    
    
    return 'encrypted_card_badge_${userId}_${amount}';
  }
}