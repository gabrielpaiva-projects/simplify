import 'package:flutter/material.dart';
import 'services/google_maps_distance_service.dart';

class TestDistanceApiScreen extends StatefulWidget {
  const TestDistanceApiScreen({Key? key}) : super(key: key);

  @override
  State<TestDistanceApiScreen> createState() => _TestDistanceApiScreenState();
}

class _TestDistanceApiScreenState extends State<TestDistanceApiScreen> {
  final GoogleMapsDistanceService _distanceService = GoogleMapsDistanceService();
  String _result = 'Clique no botão para testar a API';
  bool _isLoading = false;

  Future<void> _testApi() async {
    setState(() {
      _isLoading = true;
      _result = 'Calculando distância...';
    });

    try {
      final distance = await _distanceService.calculateDistance(
        originAddress: 'Avenida Paulista, 1000, São Paulo, SP, Brasil',
        destinationAddress: 'Rua Augusta, 500, São Paulo, SP, Brasil',
      );

      setState(() {
        if (distance != null) {
          _result = '✅ API funcionando!\n\n'
              'Distância calculada: ${distance.toStringAsFixed(1)} km\n\n'
              'Origem: Av. Paulista, 1000\n'
              'Destino: Rua Augusta, 500';
        } else {
          _result = '❌ API retornou null\n\n'
              'Possíveis causas:\n'
              '- Distance Matrix API não está ativada\n'
              '- Chave de API sem permissões\n'
              '- Endereços não encontrados\n\n'
              'Usando cálculo de fallback';
        }
      });
    } catch (e) {
      setState(() {
        _result = '❌ Erro na API:\n\n$e\n\n'
            'Verifique:\n'
            '- Conexão com internet\n'
            '- Configuração da API key\n'
            '- Status da Distance Matrix API';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste Distance Matrix API'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status da Configuração:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      GoogleMapsDistanceService.isConfigured()
                          ? '✅ API Key configurada'
                          : '❌ API Key não configurada',
                      style: TextStyle(
                        color: GoogleMapsDistanceService.isConfigured()
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testApi,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Testando...'),
                      ],
                    )
                  : const Text('Testar API Distance Matrix'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Text(
                      _result,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  GoogleMapsDistanceService.getConfigurationInstructions(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
