import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/google_maps_config.dart';

class GoogleMapsDistanceService {

  /// Calcula a distância entre dois endereços usando a API do Google Maps
  /// Retorna a distância em quilômetros
  Future<double?> calculateDistance({
    required String originAddress,
    required String destinationAddress,
  }) async {
    try {
      // Validar se a API key está configurada
      if (!GoogleMapsConfig.isConfigured) {
        print('⚠️ [GOOGLE_MAPS] API Key não configurada. Configure sua chave do Google Maps.');
        print(GoogleMapsConfig.configurationInstructions);
        return _fallbackDistance(originAddress, destinationAddress);
      }

      final uri = Uri.parse(GoogleMapsConfig.distanceMatrixBaseUrl).replace(queryParameters: {
        'origins': originAddress,
        'destinations': destinationAddress,
        'units': 'metric',
        'mode': 'driving',
        'key': GoogleMapsConfig.apiKey,
      });

      print('🔍 [GOOGLE_MAPS] Calculando distância de "$originAddress" para "$destinationAddress"');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏰ [GOOGLE_MAPS] Timeout na requisição');
          throw Exception('Timeout na requisição para Google Maps API');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && 
            data['rows'] != null && 
            data['rows'].isNotEmpty &&
            data['rows'][0]['elements'] != null &&
            data['rows'][0]['elements'].isNotEmpty) {
          
          final element = data['rows'][0]['elements'][0];
          
          if (element['status'] == 'OK' && element['distance'] != null) {
            final distanceInMeters = element['distance']['value'] as int;
            final distanceInKm = distanceInMeters / 1000.0;
            
            print('✅ [GOOGLE_MAPS] Distância calculada: ${distanceInKm.toStringAsFixed(1)} km');
            return distanceInKm;
          } else {
            print('❌ [GOOGLE_MAPS] Erro no elemento: ${element['status']}');
            return _fallbackDistance(originAddress, destinationAddress);
          }
        } else {
          print('❌ [GOOGLE_MAPS] Erro na resposta: ${data['status']}');
          if (data['error_message'] != null) {
            print('❌ [GOOGLE_MAPS] Mensagem de erro: ${data['error_message']}');
          }
          return _fallbackDistance(originAddress, destinationAddress);
        }
      } else {
        print('❌ [GOOGLE_MAPS] Erro HTTP: ${response.statusCode}');
        return _fallbackDistance(originAddress, destinationAddress);
      }
    } catch (e) {
      print('❌ [GOOGLE_MAPS] Exceção: $e');
      return _fallbackDistance(originAddress, destinationAddress);
    }
  }

  /// Método de fallback para calcular distância aproximada quando a API falha
  /// Usa uma lógica simples baseada em CEP
  double _fallbackDistance(String address1, String address2) {
    print('🔄 [GOOGLE_MAPS] Usando cálculo de fallback');
    
    try {
      // Extrair CEPs dos endereços
      final cep1 = _extractCEP(address1);
      final cep2 = _extractCEP(address2);
      
      if (cep1 != null && cep2 != null) {
        return _calculateDistanceByCEP(cep1, cep2);
      }
      
      // Se não conseguir extrair CEPs, usar distância baseada em texto
      return _calculateDistanceByText(address1, address2);
    } catch (e) {
      print('❌ [GOOGLE_MAPS] Erro no fallback: $e');
      return 10.0; // Distância padrão de 10km
    }
  }

  /// Extrai CEP de um endereço
  String? _extractCEP(String address) {
    final cepRegex = RegExp(r'\d{5}-?\d{3}');
    final match = cepRegex.firstMatch(address);
    return match?.group(0)?.replaceAll('-', '');
  }

  /// Calcula distância aproximada baseada em CEPs
  double _calculateDistanceByCEP(String cep1, String cep2) {
    if (cep1 == cep2) return 0.5; // Mesmo CEP = 500m
    
    // Comparar primeiros dígitos para estimar distância
    final prefix1 = cep1.substring(0, 5);
    final prefix2 = cep2.substring(0, 5);
    
    if (prefix1 == prefix2) return 2.0; // Mesmo bairro = 2km
    
    final area1 = cep1.substring(0, 3);
    final area2 = cep2.substring(0, 3);
    
    if (area1 == area2) return 8.0; // Mesma área = 8km
    
    final city1 = cep1.substring(0, 2);
    final city2 = cep2.substring(0, 2);
    
    if (city1 == city2) return 25.0; // Mesma região = 25km
    
    return 50.0; // Regiões diferentes = 50km
  }

  /// Calcula distância aproximada baseada em texto do endereço
  double _calculateDistanceByText(String address1, String address2) {
    final addr1Lower = address1.toLowerCase();
    final addr2Lower = address2.toLowerCase();
    
    // Extrair cidades
    final cities1 = _extractCities(addr1Lower);
    final cities2 = _extractCities(addr2Lower);
    
    // Se tem cidades em comum
    if (cities1.any((city) => cities2.contains(city))) {
      return 5.0; // Mesma cidade = 5km
    }
    
    // Extrair estados
    final state1 = _extractState(addr1Lower);
    final state2 = _extractState(addr2Lower);
    
    if (state1 == state2 && state1 != null) {
      return 30.0; // Mesmo estado = 30km
    }
    
    return 100.0; // Estados diferentes = 100km
  }

  /// Extrai possíveis nomes de cidades do endereço
  List<String> _extractCities(String address) {
    final commonCities = [
      'são paulo', 'rio de janeiro', 'belo horizonte', 'salvador',
      'fortaleza', 'brasília', 'curitiba', 'recife', 'porto alegre',
      'manaus', 'belém', 'goiânia', 'guarulhos', 'campinas',
      'são luís', 'maceió', 'natal', 'teresina', 'campo grande'
    ];
    
    return commonCities.where((city) => address.contains(city)).toList();
  }

  /// Extrai estado do endereço
  String? _extractState(String address) {
    final stateMap = {
      'sp': ['são paulo', 'sp'],
      'rj': ['rio de janeiro', 'rj'],
      'mg': ['minas gerais', 'mg'],
      'ba': ['bahia', 'ba'],
      'pr': ['paraná', 'pr'],
      'rs': ['rio grande do sul', 'rs'],
      'pe': ['pernambuco', 'pe'],
      'ce': ['ceará', 'ce'],
      'pa': ['pará', 'pa'],
      'sc': ['santa catarina', 'sc'],
      'go': ['goiás', 'go'],
      'ma': ['maranhão', 'ma'],
      'es': ['espírito santo', 'es'],
      'pb': ['paraíba', 'pb'],
      'al': ['alagoas', 'al'],
      'mt': ['mato grosso', 'mt'],
      'ms': ['mato grosso do sul', 'ms'],
      'df': ['distrito federal', 'df', 'brasília'],
      'se': ['sergipe', 'se'],
      'am': ['amazonas', 'am'],
      'ro': ['rondônia', 'ro'],
      'ac': ['acre', 'ac'],
      'ap': ['amapá', 'ap'],
      'rr': ['roraima', 'rr'],
      'to': ['tocantins', 'to'],
      'pi': ['piauí', 'pi'],
      'rn': ['rio grande do norte', 'rn'],
    };

    for (final entry in stateMap.entries) {
      if (entry.value.any((stateName) => address.contains(stateName))) {
        return entry.key;
      }
    }

    return null;
  }

  /// Verifica se a API está configurada corretamente
  static bool isConfigured() {
    return GoogleMapsConfig.isConfigured;
  }

  /// Instrução para configurar a API
  static String getConfigurationInstructions() {
    return GoogleMapsConfig.configurationInstructions;
  }
}
