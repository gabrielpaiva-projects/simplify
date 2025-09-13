import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/firebase_messaging_service.dart';
import 'services/notification_overlay_service.dart';
import 'core/di/injection_container.dart' as di;

/// Tela de teste para demonstrar a integração com Firebase Cloud Messaging
class TestFCMScreen extends StatefulWidget {
  const TestFCMScreen({super.key});

  @override
  State<TestFCMScreen> createState() => _TestFCMScreenState();
}

class _TestFCMScreenState extends State<TestFCMScreen> {
  late final FirebaseMessagingService _messagingService;
  late final NotificationOverlayService _overlayService;
  String? _currentToken;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messagingService = di.sl<FirebaseMessagingService>();
    _overlayService = di.sl<NotificationOverlayService>();
    _loadCurrentToken();
  }

  void _loadCurrentToken() {
    setState(() {
      _currentToken = _messagingService.currentToken;
    });
  }

  Future<void> _refreshToken() async {
    setState(() => _isLoading = true);
    
    try {
      await _messagingService.initialize();
      _loadCurrentToken();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar token: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _subscribeToTopic() async {
    setState(() => _isLoading = true);
    
    try {
      await _messagingService.subscribeToTopic('general');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscrito no tópico "general"!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao se inscrever no tópico: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _unsubscribeFromTopic() async {
    setState(() => _isLoading = true);
    
    try {
      await _messagingService.unsubscribeFromTopic('general');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Desinscrito do tópico "general"!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao se desinscrever do tópico: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cleanupOldTokens() async {
    setState(() => _isLoading = true);
    
    try {
      await _messagingService.cleanupOldTokens();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tokens antigos limpos!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao limpar tokens: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _simulatePaymentNotification() {
    // Simular notificação de pagamento confirmado com o payload fornecido
    final message = RemoteMessage(
      notification: const RemoteNotification(
        title: '✅ Pagamento Confirmado!',
        body: 'Seu pagamento de R\$ 323,10 via PIX foi confirmado com sucesso.',
      ),
      data: {
        'type': 'payment_confirmed',
        'paymentType': 'pix',
        'amount': '323.1',
        'userId': 'M7KQRlO5ADZCQ3EbpljTeaatPhJ3',
        'timestamp': '2025-09-12T23:46:46.805Z',
      },
    );

    _overlayService.showNotificationBadge(message);
  }

  void _simulateAppointmentNotification() {
    final message = RemoteMessage(
      notification: const RemoteNotification(
        title: '📅 Lembrete de Agendamento',
        body: 'Seu serviço de limpeza está agendado para amanhã às 14:00.',
      ),
      data: {
        'type': 'appointment_reminder',
        'appointmentId': 'apt_123',
        'serviceType': 'cleaning',
        'scheduledTime': '2025-09-13T14:00:00.000Z',
        'userId': 'M7KQRlO5ADZCQ3EbpljTeaatPhJ3',
      },
    );

    _overlayService.showNotificationBadge(message);
  }

  void _simulateServiceCompletedNotification() {
    final message = RemoteMessage(
      notification: const RemoteNotification(
        title: '🎉 Serviço Concluído!',
        body: 'Sua limpeza foi finalizada com sucesso. Avalie nosso serviço!',
      ),
      data: {
        'type': 'service_completed',
        'serviceId': 'srv_456',
        'professionalId': 'prof_789',
        'userId': 'M7KQRlO5ADZCQ3EbpljTeaatPhJ3',
        'completedAt': '2025-09-12T16:30:00.000Z',
      },
    );

    _overlayService.showNotificationBadge(message);
  }

  void _simulateMessageNotification() {
    final message = RemoteMessage(
      notification: const RemoteNotification(
        title: '💬 Nova Mensagem',
        body: 'Você recebeu uma nova mensagem do profissional.',
      ),
      data: {
        'type': 'new_message',
        'messageId': 'msg_321',
        'senderId': 'prof_789',
        'userId': 'M7KQRlO5ADZCQ3EbpljTeaatPhJ3',
        'timestamp': '2025-09-12T23:50:00.000Z',
      },
    );

    _overlayService.showNotificationBadge(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste FCM Integration'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Token FCM Atual:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: SelectableText(
                        _currentToken ?? 'Token não disponível',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Simulações de Notificação:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _simulatePaymentNotification,
              icon: const Icon(Icons.payment),
              label: const Text('Simular Pagamento Confirmado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _simulateAppointmentNotification,
              icon: const Icon(Icons.schedule),
              label: const Text('Simular Lembrete de Agendamento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _simulateServiceCompletedNotification,
              icon: const Icon(Icons.check_circle),
              label: const Text('Simular Serviço Concluído'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _simulateMessageNotification,
              icon: const Icon(Icons.message),
              label: const Text('Simular Nova Mensagem'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ações de FCM:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _refreshToken,
              icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
              label: const Text('Atualizar Token'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _subscribeToTopic,
              icon: const Icon(Icons.notifications_active),
              label: const Text('Inscrever em Tópico "general"'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _unsubscribeFromTopic,
              icon: const Icon(Icons.notifications_off),
              label: const Text('Desinscrever de Tópico "general"'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _cleanupOldTokens,
              icon: const Icon(Icons.cleaning_services),
              label: const Text('Limpar Tokens Antigos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const Spacer(),
            Card(
              color: Colors.yellow[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Informações:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• O token é salvo automaticamente na collection "tokens" do Firestore\n'
                      '• O token é atualizado sempre que o usuário abre o app\n'
                      '• Tokens são invalidados quando o usuário faz logout\n'
                      '• Notificações em foreground aparecem como badge no topo da tela\n'
                      '• Use os botões de simulação para testar diferentes tipos de notificação\n'
                      '• Use o Firebase Console para enviar notificações de teste reais',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


