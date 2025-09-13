/// Configuração para Google Maps API
/// 
/// IMPORTANTE: Este arquivo contém configurações sensíveis.
/// Em produção, use variáveis de ambiente ou Firebase Remote Config.
class GoogleMapsConfig {
  /// Chave da API do Google Maps (reutilizada do projeto existente)
  /// Esta chave já está sendo usada para Static Maps API
  /// Agora também será usada para Distance Matrix API
  static const String apiKey = 'AIzaSyC72_9C47-lZR6G1UuX0ZTvrLtbBDDUGlI';
  
  /// URL base da API Distance Matrix
  static const String distanceMatrixBaseUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json';
  
  /// Verifica se a API está configurada
  static bool get isConfigured => apiKey.isNotEmpty;
  
  /// Mensagem de instrução para configuração
  static String get configurationInstructions => '''
✅ GOOGLE MAPS API CONFIGURADA

A API está usando a chave existente do projeto.

⚠️ IMPORTANTE: Verifique se a Distance Matrix API está ativada:

1. Acesse: https://console.cloud.google.com/
2. Vá para "APIs e Serviços" > "Biblioteca"
3. Procure por "Distance Matrix API"
4. Clique em "ATIVAR" se não estiver ativada

💰 CUSTOS:
- Distance Matrix API: \$5 por 1000 requisições
- Primeiras 200 requisições por mês são gratuitas
- Configure alertas de billing no Google Cloud Console

🔧 Se houver erros de permissão:
- Verifique se a chave tem acesso à Distance Matrix API
- Configure restrições de segurança apropriadas
  ''';
}
