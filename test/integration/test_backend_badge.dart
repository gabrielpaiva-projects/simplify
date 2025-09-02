import 'utils/badge_generator.dart';
import 'dart:convert';

void main() {
  print('=== TESTE COM BADGES DO BACKEND ===\n');
  
  // Badge PIX do exemplo curl
  final pixBadge = 'U2FsdGVkX1//XevtY46gHOw+K8byHy/mrc257Qky1boBPXs3sShhIVudwi6gWEROHSwAUBNThRf9HLdA3pHCSEWONZkaOP4WctIeBnWE6q6wqDpytMchELgnOtLzYAONy5l65rYxTfopOON+Xey13g==';
  
  // Badge Cartão do exemplo curl  
  final cardBadge = 'U2FsdGVkX1/bc2q787z4GfWdDmJi5g3qPK22J0IRDz/+EOdf+5GVKKyqNCu6OK5+ZqDidk8Aokj6s3Ob2I0c9tTRuEOp7PZBr1OIVNcHNMdEafoCyBMcSr2lsds4U8YdqRyd26aHvIkjKWQUKJ7eKQ4kGPAI1qBH/3v6ODh1+XOWOT/oTnnoa2pkpbML+UGN4WpVyCKkQvFnVRKWHH/50HD+LZI4kHsPPzBcHYmH6tF2FaknYmcNbkpdS0EV59rhGs+mbLcrorxF9XNFPgiabEV48rYeHLPfui4vV4bYLWE=';
  
  print('1. Testando descriptografia da badge PIX do backend:');
  print('Badge: ${pixBadge.substring(0, 50)}...');
  
  final decryptedPix = BadgeGenerator.decryptData(pixBadge);
  if (decryptedPix != null) {
    print('✅ Descriptografado com sucesso:');
    print(jsonEncode(decryptedPix));
  } else {
    print('❌ Falha ao descriptografar badge PIX');
  }
  
  print('\n2. Testando descriptografia da badge de Cartão do backend:');
  print('Badge: ${cardBadge.substring(0, 50)}...');
  
  final decryptedCard = BadgeGenerator.decryptData(cardBadge);
  if (decryptedCard != null) {
    print('✅ Descriptografado com sucesso:');
    print(jsonEncode(decryptedCard));
  } else {
    print('❌ Falha ao descriptografar badge de Cartão');
  }
  
  print('\n3. Gerando nossa própria badge e comparando formato:');
  
  final ourBadge = BadgeGenerator.generatePixBadge(
    userId: 'M7KQRlO5ADZCQ3EbpljTeaatPhJ3',
    amount: 100.0,
  );
  
  print('Nossa badge: ${ourBadge.substring(0, 50)}...');
  print('Tamanho nossa: ${ourBadge.length}');
  print('Tamanho backend PIX: ${pixBadge.length}');
  
  // Verifica se nossa badge começa com o formato OpenSSL
  final ourDecoded = base64.decode(ourBadge);
  final backendDecoded = base64.decode(pixBadge);
  
  print('\nPrimeiros bytes da nossa badge: ${ourDecoded.take(16).toList()}');
  print('Primeiros bytes da badge backend: ${backendDecoded.take(16).toList()}');
  
  // Verifica "Salted__"
  final saltedPrefix = utf8.encode('Salted__');
  print('\nNossa badge tem prefixo "Salted__": ${ourDecoded.take(8).toList().toString() == saltedPrefix.toString()}');
  print('Badge backend tem prefixo "Salted__": ${backendDecoded.take(8).toList().toString() == saltedPrefix.toString()}');
}