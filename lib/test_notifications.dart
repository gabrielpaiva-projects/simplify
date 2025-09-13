import 'package:flutter/material.dart';
import 'services/notification_storage_service.dart';
import 'models/notification_model.dart';
import 'core/di/injection_container.dart' as di;

/// Função para testar o sistema de notificações com bottomsheet
Future<void> addTestNotifications() async {
  final service = di.sl<NotificationStorageService>();
  
  final notifications = [
    NotificationModel(
      id: 'test_1',
      title: 'Agendamento Confirmado ✅',
      body: 'Sua limpeza padrão foi agendada para amanhã às 14h00. Prepare o ambiente!',
      data: {'type': 'appointment'},
      receivedAt: DateTime.now().subtract(const Duration(minutes: 2)),
      type: 'appointment',
    ),
    NotificationModel(
      id: 'test_2',
      title: 'Pagamento Aprovado 💳',
      body: 'Pagamento de R\$ 85,00 processado com sucesso via PIX.',
      data: {'type': 'payment'},
      receivedAt: DateTime.now().subtract(const Duration(hours: 1)),
      type: 'payment',
    ),
    NotificationModel(
      id: 'test_3',
      title: 'Oferta Especial 🎉',
      body: '20% OFF na primeira limpeza pesada! Oferta válida até domingo.',
      data: {'type': 'promotion'},
      receivedAt: DateTime.now().subtract(const Duration(hours: 3)),
      type: 'promotion',
    ),
    NotificationModel(
      id: 'test_4',
      title: 'Serviço Concluído ⭐',
      body: 'Limpeza finalizada! Que tal avaliar nosso trabalho?',
      data: {'type': 'service'},
      receivedAt: DateTime.now().subtract(const Duration(days: 1)),
      type: 'service',
    ),
  ];
  
  for (final notification in notifications) {
    await service.addNotification(notification);
  }
  
  debugPrint('🎯 ${notifications.length} notificações de teste adicionadas!');
}

/// Widget para adicionar botão de teste em qualquer tela
class TestNotificationsButton extends StatelessWidget {
  const TestNotificationsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton(
        mini: true,
        onPressed: () async {
          await addTestNotifications();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notificações de teste adicionadas! 🔔'),
              backgroundColor: Colors.green,
            ),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add_alert, size: 20),
      ),
    );
  }
}
