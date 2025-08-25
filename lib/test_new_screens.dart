// Arquivo de teste para verificar se as novas telas compilam corretamente
import 'package:flutter/material.dart';
import 'features/services/presentation/screens/date_time_selection_screen.dart';
import 'features/services/presentation/screens/payment_screen.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test New Screens',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste das Novas Telas'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DateTimeSelectionScreen(
                      onDateTimeSelected: (date, time) {
                        print('Data: $date, Hora: $time');
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
              child: const Text('Testar Seleção de Data/Hora'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      totalAmount: 149.90,
                      serviceDetails: const {
                        'service': 'Limpeza Teste',
                        'date': '15 de Janeiro',
                        'time': '14:00',
                        'duration': '2 horas',
                      },
                      onPaymentConfirmed: (method, data) {
                        print('Pagamento confirmado: $method');
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
              child: const Text('Testar Tela de Pagamento'),
            ),
          ],
        ),
      ),
    );
  }
}