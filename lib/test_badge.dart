import 'utils/badge_generator.dart';
import 'dart:convert';

void main() {
  print('=== TESTE DE BADGE ===');
  
  final userId = 'M7KQRlO5ADZCQ3EbpljTeaatPhJ3';
  final amount = 100.0;
  
  print('Dados de entrada:');
  print('UserId: $userId');
  print('Amount: $amount');
  
  final badge = BadgeGenerator.generatePixBadge(
    userId: userId,
    amount: amount,
  );
  
  print('\nBadge gerada:');
  print(badge);
  print('Tamanho: ${badge.length} caracteres');
  
  print('\nTentando descriptografar...');
  final decrypted = BadgeGenerator.decryptData(badge);
  if (decrypted != null) {
    print('Descriptografado com sucesso:');
    print(jsonEncode(decrypted));
  } else {
    print('Falha ao descriptografar');
  }
  
  print('\n=== TESTE COM BADGE DO BACKEND ===');
  print('Cole aqui uma badge válida do backend para testar a descriptografia');
  
}