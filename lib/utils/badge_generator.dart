import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

/// Classe principal para geração de badges criptografadas
/// compatível com o backend Node.js usando CryptoJS
class BadgeGenerator {
  /// Chave secreta para criptografia
  /// IMPORTANTE: Em produção, obtenha isso de forma segura!
  static const String _secretKey = '75bdb50d-b14c-4b8e-b196-8576b5b013e0';

  /// Gera uma badge criptografada para pagamento PIX
  static String generatePixBadge({
    required String userId,
    required double amount,
    int? timestamp,
  }) {
    // Formata o amount para evitar problemas de precisão de ponto flutuante
    // Arredonda para 2 casas decimais e converte para double novamente
    final formattedAmount = double.parse(amount.toStringAsFixed(2));
    
    final payload = {
      'userId': userId,
      'amount': formattedAmount,
      'timestamp': timestamp ?? DateTime.now().millisecondsSinceEpoch,
    };

    return _encryptCryptoJSCompatible(jsonEncode(payload));
  }

  /// Gera uma badge criptografada para pagamento com cartão
  static String generateCardBadge({
    required String userId,
    required double amount,
    required String cardNumber,
    required String expirationYear,
    required String expirationMonth,
    required String securityCode,
    int installments = 1,
    int? timestamp,
  }) {
    print('=== BADGE GENERATOR - CARD ===');
    print('UserId: $userId');
    print('Amount: $amount');
    print('Card: ${cardNumber.substring(0, 4)}****${cardNumber.substring(cardNumber.length - 4)}');
    print('Expiry: $expirationMonth/$expirationYear');
    print('CVV: ${securityCode.length} digits');
    print('Installments: $installments');
    
    // Formata o amount para evitar problemas de precisão de ponto flutuante
    // Arredonda para 2 casas decimais e converte para double novamente
    final formattedAmount = double.parse(amount.toStringAsFixed(2));
    
    final payload = {
      'userId': userId,
      'amount': formattedAmount,
      'cardNumber': cardNumber.replaceAll(' ', ''),
      'expirationYear': expirationYear,
      'expirationMonth': expirationMonth,
      'securityCode': securityCode,
      'installments': installments,
      'timestamp': timestamp ?? DateTime.now().millisecondsSinceEpoch,
    };
    
    print('Payload to encrypt: ${jsonEncode(payload)}');
    final encrypted = _encryptCryptoJSCompatible(jsonEncode(payload));
    print('Badge encrypted successfully! Length: ${encrypted.length}');
    print('==============================');

    return encrypted;
  }

  /// Implementação compatível com CryptoJS
  /// CryptoJS usa o formato OpenSSL com salt
  static String _encryptCryptoJSCompatible(String plainText) {
    // Gera um salt aleatório (8 bytes como o CryptoJS)
    final random = Random.secure();
    final salt = Uint8List(8);
    for (int i = 0; i < 8; i++) {
      salt[i] = random.nextInt(256);
    }

    // Deriva a chave e IV usando EVP_BytesToKey (compatível com CryptoJS)
    final keyAndIv = _evpBytesToKey(
      password: _secretKey,
      salt: salt,
      keyLen: 32, // AES-256
      ivLen: 16,  // AES block size
    );

    final key = Key(keyAndIv.sublist(0, 32));
    final iv = IV(keyAndIv.sublist(32, 48));

    // Criptografa usando AES-CBC
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Formato OpenSSL: "Salted__" + salt + encrypted
    final salted = utf8.encode('Salted__');
    final combined = Uint8List.fromList([
      ...salted,
      ...salt,
      ...encrypted.bytes,
    ]);

    return base64.encode(combined);
  }

  /// Implementação do algoritmo EVP_BytesToKey
  /// Este é o algoritmo usado pelo CryptoJS para derivar chave e IV
  static Uint8List _evpBytesToKey({
    required String password,
    required Uint8List salt,
    required int keyLen,
    required int ivLen,
  }) {
    final passwordBytes = utf8.encode(password);
    final totalLen = keyLen + ivLen;
    final derived = <int>[];
    var data = <int>[];

    // Primeira iteração
    data = [...passwordBytes, ...salt];
    
    while (derived.length < totalLen) {
      final hash = md5.convert(data);
      derived.addAll(hash.bytes);
      
      // Próximas iterações usam hash anterior + password + salt
      data = [...hash.bytes, ...passwordBytes, ...salt];
    }

    return Uint8List.fromList(derived.sublist(0, totalLen));
  }

  /// Método alternativo usando uma implementação mais simples
  /// Use este se houver problemas de compatibilidade
  static String generateBadgeSimple(Map<String, dynamic> payload) {
    final jsonString = jsonEncode(payload);
    
    // Prepara a chave (32 bytes para AES-256)
    final key = Key.fromUtf8(_padKey(_secretKey));
    
    // Gera IV aleatório
    final iv = IV.fromSecureRandom(16);
    
    // Criptografa
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(jsonString, iv: iv);
    
    // Combina IV + encrypted e codifica em base64
    final combined = Uint8List.fromList([
      ...iv.bytes,
      ...encrypted.bytes,
    ]);
    
    return base64.encode(combined);
  }

  /// Ajusta o tamanho da chave para 32 bytes
  static String _padKey(String key) {
    if (key.length >= 32) {
      return key.substring(0, 32);
    }
    return key.padRight(32, '0');
  }

  /// Descriptografa dados (útil para testes)
  static Map<String, dynamic>? decryptData(String encryptedData) {
    try {
      // Decodifica do base64
      final encrypted = base64.decode(encryptedData);

      // Verifica o formato OpenSSL
      final salted = utf8.encode('Salted__');
      if (encrypted.length < salted.length + 8) {
        throw Exception('Invalid encrypted data format');
      }

      // Verifica se tem o prefixo "Salted__"
      final prefix = encrypted.sublist(0, 8);
      if (!_listEquals(prefix, salted)) {
        throw Exception('Invalid OpenSSL format');
      }

      // Extrai o salt
      final salt = encrypted.sublist(8, 16);

      // Extrai os dados criptografados
      final cipherText = encrypted.sublist(16);

      // Deriva a chave e IV
      final keyAndIv = _evpBytesToKey(
        password: _secretKey,
        salt: salt,
        keyLen: 32,
        ivLen: 16,
      );

      final key = Key(keyAndIv.sublist(0, 32));
      final iv = IV(keyAndIv.sublist(32, 48));

      // Descriptografa
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final decrypted = encrypter.decrypt(
        Encrypted(cipherText),
        iv: iv,
      );

      // Converte de volta para Map
      return jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (e) {
      print('Erro ao descriptografar: $e');
      return null;
    }
  }

  /// Compara duas listas de bytes
  static bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}