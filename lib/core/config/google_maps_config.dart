class GoogleMapsConfig {
  static const String apiKey = 'AIzaSyC72_9C47-lZR6G1UuX0ZTvrLtbBDDUGlI';
  
  static const String distanceMatrixBaseUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json';
  
  static bool get isConfigured => apiKey.isNotEmpty;
  
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
