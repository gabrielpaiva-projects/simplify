import 'utils/badge_generator.dart';
import 'dart:convert';

void main() {
  // Teste 1: Gerar badge PIX
  print('=== TESTE DE BADGE ===');
  
  final userId = 'M7KQRlO5ADZCQ3EbpljTeaatPhJ3';
  final amount = 100.0;
  
  print('Dados de entrada:');
  print('UserId: $userId');
  print('Amount: $amount');
  
  // Gera a badge
  final badge = BadgeGenerator.generatePixBadge(
    userId: userId,
    amount: amount,
  );
  
  print('\nBadge gerada:');
  print(badge);
  print('Tamanho: ${badge.length} caracteres');
  
  // Tenta descriptografar para verificar
  print('\nTentando descriptografar...');
  final decrypted = BadgeGenerator.decryptData(badge);
  if (decrypted != null) {
    print('Descriptografado com sucesso:');
    print(jsonEncode(decrypted));
  } else {
    print('Falha ao descriptografar');
  }
  
  // Teste 2: Badge de exemplo do backend (se você tiver uma)
  print('\n=== TESTE COM BADGE DO BACKEND ===');
  print('Cole aqui uma badge válida do backend para testar a descriptografia');
  
  // Se você tiver uma badge de exemplo do backend que funciona, teste aqui:
  // final backendBadge = 'U2FsdGVkX1//XevtY46gHOw+K8byHy/mrc257Qky1boBPXs3sShhIVudwi6gWEROHSwAUBNThRf9HLdA3pHCSEWONZkaOP4WctIeBnWE6q6wqDpytMchELgnOtLzYAONy5l65rYxTfopOON+Xey13g==';
  // final decryptedBackend = BadgeGenerator.decryptData(backendBadge);
  // print('Resultado: ${decryptedBackend != null ? jsonEncode(decryptedBackend) : "Falha"}');
}