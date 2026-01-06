import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import '../models/badge_payload_models.dart';

class BadgeGenerator {
  static const String _secretKey = '75bdb50d-b14c-4b8e-b196-8576b5b013e0';

  static String generatePixBadge({
    required String userId,
    required double amount,
    ServiceSchedulingData? serviceData,
    int? timestamp,
  }) {
    final formattedAmount = double.parse(amount.toStringAsFixed(2));
    
    final badgePayload = BadgePayload(
      userId: userId,
      amount: formattedAmount,
      timestamp: timestamp ?? DateTime.now().millisecondsSinceEpoch,
      serviceData: serviceData,
    );

    return _encryptCryptoJSCompatible(badgePayload.toJsonString());
  }

  static String generateCardBadge({
    required String userId,
    required double amount,
    required String cardNumber,
    required String expirationYear,
    required String expirationMonth,
    required String securityCode,
    int installments = 1,
    ServiceSchedulingData? serviceData,
    int? timestamp,
  }) {
    print('=== BADGE GENERATOR - CARD ===');
    print('UserId: $userId');
    print('Amount: $amount');
    print('Card: ${cardNumber.substring(0, 4)}****${cardNumber.substring(cardNumber.length - 4)}');
    print('Expiry: $expirationMonth/$expirationYear');
    print('CVV: ${securityCode.length} digits');
    print('Installments: $installments');
    if (serviceData != null) {
      print('Service Data: Included');
    }
    
    final formattedAmount = double.parse(amount.toStringAsFixed(2));
    
    final cardBadgePayload = CardBadgePayload(
      userId: userId,
      amount: formattedAmount,
      cardNumber: cardNumber.replaceAll(' ', ''),
      expirationYear: expirationYear,
      expirationMonth: expirationMonth,
      securityCode: securityCode,
      installments: installments,
      timestamp: timestamp ?? DateTime.now().millisecondsSinceEpoch,
      serviceData: serviceData,
    );
    
    print('Payload to encrypt: ${cardBadgePayload.toJsonString()}');
    final encrypted = _encryptCryptoJSCompatible(cardBadgePayload.toJsonString());
    print('Badge encrypted successfully! Length: ${encrypted.length}');
    print('==============================');

    return encrypted;
  }

  static String _encryptCryptoJSCompatible(String plainText) {
    final random = Random.secure();
    final salt = Uint8List(8);
    for (int i = 0; i < 8; i++) {
      salt[i] = random.nextInt(256);
    }

    final keyAndIv = _evpBytesToKey(
      password: _secretKey,
      salt: salt,
      keyLen: 32, // AES-256
      ivLen: 16,  // AES block size
    );

    final key = Key(keyAndIv.sublist(0, 32));
    final iv = IV(keyAndIv.sublist(32, 48));

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    final salted = utf8.encode('Salted__');
    final combined = Uint8List.fromList([
      ...salted,
      ...salt,
      ...encrypted.bytes,
    ]);

    return base64.encode(combined);
  }

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

    data = [...passwordBytes, ...salt];
    
    while (derived.length < totalLen) {
      final hash = md5.convert(data);
      derived.addAll(hash.bytes);
      
      data = [...hash.bytes, ...passwordBytes, ...salt];
    }

    return Uint8List.fromList(derived.sublist(0, totalLen));
  }

  static String generateBadgeSimple(Map<String, dynamic> payload) {
    final jsonString = jsonEncode(payload);
    
    final key = Key.fromUtf8(_padKey(_secretKey));
    
    final iv = IV.fromSecureRandom(16);
    
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(jsonString, iv: iv);
    
    final combined = Uint8List.fromList([
      ...iv.bytes,
      ...encrypted.bytes,
    ]);
    
    return base64.encode(combined);
  }

  static String _padKey(String key) {
    if (key.length >= 32) {
      return key.substring(0, 32);
    }
    return key.padRight(32, '0');
  }

  static Map<String, dynamic>? decryptData(String encryptedData) {
    try {
      final encrypted = base64.decode(encryptedData);

      final salted = utf8.encode('Salted__');
      if (encrypted.length < salted.length + 8) {
        throw Exception('Invalid encrypted data format');
      }

      final prefix = encrypted.sublist(0, 8);
      if (!_listEquals(prefix, salted)) {
        throw Exception('Invalid OpenSSL format');
      }

      final salt = encrypted.sublist(8, 16);

      final cipherText = encrypted.sublist(16);

      final keyAndIv = _evpBytesToKey(
        password: _secretKey,
        salt: salt,
        keyLen: 32,
        ivLen: 16,
      );

      final key = Key(keyAndIv.sublist(0, 32));
      final iv = IV(keyAndIv.sublist(32, 48));

      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final decrypted = encrypter.decrypt(
        Encrypted(cipherText),
        iv: iv,
      );

      return jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (e) {
      print('Erro ao descriptografar: $e');
      return null;
    }
  }

  static bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}