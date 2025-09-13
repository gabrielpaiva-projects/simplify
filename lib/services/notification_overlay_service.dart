import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../widgets/notification_badge.dart';

class NotificationOverlayService {
  static final NotificationOverlayService _instance = NotificationOverlayService._internal();
  factory NotificationOverlayService() => _instance;
  NotificationOverlayService._internal();

  OverlayEntry? _currentOverlay;
  BuildContext? _context;
  OverlayState? _overlayState;

  /// Inicializar o serviço com o contexto da aplicação
  void initialize(BuildContext context) {
    _context = context;
    
    // Tentar obter e cachear o OverlayState
    try {
      _overlayState = Overlay.maybeOf(context);
      if (_overlayState != null) {
        debugPrint('NotificationOverlayService: OverlayState cached successfully');
      } else {
        debugPrint('NotificationOverlayService: OverlayState not available during initialization');
      }
    } catch (e) {
      debugPrint('NotificationOverlayService: Error caching OverlayState: $e');
    }
  }

  /// Mostrar badge de notificação como overlay
  void showNotificationBadge(RemoteMessage message) {
    if (_context == null) {
      debugPrint('NotificationOverlayService: Context not initialized, cannot show badge');
      return;
    }

    try {
      // Remover overlay anterior se existir
      _removeCurrentOverlay();

      // Tentar múltiplas estratégias para obter o overlay
      OverlayState? overlay;
      
      // Estratégia 1: Usar o overlay cacheado
      if (_overlayState != null && _overlayState!.mounted) {
        overlay = _overlayState;
        debugPrint('NotificationOverlayService: Using cached OverlayState');
      }
      
      // Estratégia 2: Tentar obter do contexto atual
      if (overlay == null) {
        overlay = Overlay.maybeOf(_context!);
        if (overlay != null) {
          debugPrint('NotificationOverlayService: Using OverlayState from current context');
        }
      }
      
      // Estratégia 3: Usar Navigator.overlay se disponível
      if (overlay == null) {
        try {
          final navigator = Navigator.maybeOf(_context!);
          if (navigator != null) {
            overlay = navigator.overlay;
            debugPrint('NotificationOverlayService: Using OverlayState from Navigator');
          }
        } catch (e) {
          debugPrint('NotificationOverlayService: Error getting overlay from Navigator: $e');
        }
      }

      if (overlay == null) {
        debugPrint('NotificationOverlayService: No overlay available with any strategy');
        return;
      }

      // Criar novo overlay
      _currentOverlay = OverlayEntry(
        builder: (context) => Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: NotificationBadge(
              message: message,
              onTap: () => _handleNotificationTap(message),
              onDismiss: _removeCurrentOverlay,
            ),
          ),
        ),
      );

      // Adicionar overlay à tela
      overlay.insert(_currentOverlay!);
      debugPrint('NotificationOverlayService: Badge overlay inserted successfully');
      
    } catch (e) {
      debugPrint('NotificationOverlayService: Error showing notification badge: $e');
      _currentOverlay = null;
    }
  }

  /// Remover overlay atual
  void _removeCurrentOverlay() {
    if (_currentOverlay != null) {
      try {
        _currentOverlay!.remove();
      } catch (e) {
        debugPrint('NotificationOverlayService: Error removing overlay: $e');
      } finally {
        _currentOverlay = null;
      }
    }
  }

  /// Lidar com tap na notificação
  void _handleNotificationTap(RemoteMessage message) {
    if (_context == null) return;

    final type = message.data['type'] as String?;
    final navigator = Navigator.of(_context!);

    switch (type) {
      case 'payment_confirmed':
        _navigateToPaymentDetails(navigator, message);
        break;
      case 'appointment_reminder':
        _navigateToAppointments(navigator, message);
        break;
      case 'service_completed':
        _navigateToServiceHistory(navigator, message);
        break;
      case 'new_message':
        _navigateToMessages(navigator, message);
        break;
      default:
        // Navegação padrão ou mostrar detalhes da notificação
        _showNotificationDetails(message);
        break;
    }
  }

  /// Navegar para detalhes do pagamento
  void _navigateToPaymentDetails(NavigatorState navigator, RemoteMessage message) {
    try {
      // Implementar navegação para tela de detalhes do pagamento
      // Por exemplo: navigator.pushNamed('/payment-details', arguments: message.data);
      
      // Por enquanto, mostrar um snackbar como exemplo
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text('Pagamento confirmado: ${message.data['amount'] ?? 'N/A'}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Erro ao navegar para detalhes do pagamento: $e');
    }
  }

  /// Navegar para tela de agendamentos
  void _navigateToAppointments(NavigatorState navigator, RemoteMessage message) {
    try {
      // Implementar navegação para tela de agendamentos
      // Por exemplo: navigator.pushNamed('/appointments');
      
      ScaffoldMessenger.of(_context!).showSnackBar(
        const SnackBar(
          content: Text('Redirecionando para agendamentos...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Erro ao navegar para agendamentos: $e');
    }
  }

  /// Navegar para histórico de serviços
  void _navigateToServiceHistory(NavigatorState navigator, RemoteMessage message) {
    try {
      // Implementar navegação para histórico de serviços
      // Por exemplo: navigator.pushNamed('/service-history');
      
      ScaffoldMessenger.of(_context!).showSnackBar(
        const SnackBar(
          content: Text('Serviço concluído com sucesso!'),
          backgroundColor: Colors.purple,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Erro ao navegar para histórico de serviços: $e');
    }
  }

  /// Navegar para mensagens
  void _navigateToMessages(NavigatorState navigator, RemoteMessage message) {
    try {
      // Implementar navegação para tela de mensagens
      // Por exemplo: navigator.pushNamed('/messages');
      
      ScaffoldMessenger.of(_context!).showSnackBar(
        const SnackBar(
          content: Text('Nova mensagem recebida!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Erro ao navegar para mensagens: $e');
    }
  }

  /// Mostrar detalhes da notificação em um dialog
  void _showNotificationDetails(RemoteMessage message) {
    if (_context == null) return;

    showDialog(
      context: _context!,
      builder: (context) => AlertDialog(
        title: Text(message.notification?.title ?? 'Notificação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.notification?.body != null) ...[
              Text(message.notification!.body!),
              const SizedBox(height: 16),
            ],
            if (message.data.isNotEmpty) ...[
              const Text(
                'Dados adicionais:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...message.data.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${entry.key}: ${entry.value}'),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Limpar contexto (chamar quando o app for fechado)
  void dispose() {
    _removeCurrentOverlay();
    _context = null;
  }

  /// Verificar se há overlay ativo
  bool get hasActiveOverlay => _currentOverlay != null;

  /// Verificar se o serviço está inicializado e pronto para uso
  bool get isReady {
    if (_context == null) return false;
    
    // Verificar se pelo menos uma estratégia de overlay está disponível
    if (_overlayState != null && _overlayState!.mounted) return true;
    if (Overlay.maybeOf(_context!) != null) return true;
    
    try {
      final navigator = Navigator.maybeOf(_context!);
      if (navigator?.overlay != null) return true;
    } catch (e) {
      // Ignore erros na verificação
    }
    
    return false;
  }

  /// Forçar remoção de overlay (para casos específicos)
  void forceRemoveOverlay() {
    _removeCurrentOverlay();
  }
}
