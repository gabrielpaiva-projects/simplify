import 'lib/utils/card_validator.dart';
import 'lib/features/badge/data/models/badge_models.dart';

void main() {
  // Testa a detecção de bandeiras
  final testCards = {
    '5031433215406351': 'Mastercard (5031)',
    '5155901222222222': 'Mastercard (51)',
    '5555555555554444': 'Mastercard (55)',
    '5067123456789012': 'Elo (5067)',
    '4111111111111111': 'Visa',
    '4011123456789012': 'Elo (4011)',
    '371449635398431': 'Amex',
    '6062821234567890': 'Hipercard',
  };

  print('=== TESTE DE DETECÇÃO DE BANDEIRAS ===\n');
  
  for (var entry in testCards.entries) {
    final detected = CardValidator.detectCardBrand(entry.key);
    final expected = entry.value;
    final status = detected.name == expected.split(' ')[0].toLowerCase() ? '✅' : '❌';
    
    print('$status Cartão: ${entry.key.substring(0, 4)}****');
    print('   Esperado: $expected');
    print('   Detectado: ${detected.name} (${detected.paymentMethodId})');
    print('');
  }
  
  // Teste específico para o cartão do usuário
  print('=== TESTE DO CARTÃO DO USUÁRIO ===');
  final userCard = '5031433215406351';
  final brand = CardValidator.detectCardBrand(userCard);
  print('Cartão: $userCard');
  print('Bandeira detectada: ${brand.name}');
  print('Payment Method ID: ${brand.paymentMethodId}');
  print('Deveria ser: Mastercard (master)');
}