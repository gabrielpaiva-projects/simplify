import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

/// Serviço para gerenciar notificações em memória e armazenamento local
class NotificationStorageService extends ChangeNotifier {
  static const String _notificationsKey = 'stored_notifications';
  static const int _maxNotifications = 100; // Limite máximo de notificações armazenadas

  final List<NotificationModel> _notifications = [];
  SharedPreferences? _prefs;

  /// Lista de notificações (mais recentes primeiro)
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  /// Número total de notificações
  int get totalCount => _notifications.length;

  /// Número de notificações não lidas
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Se há notificações não lidas
  bool get hasUnreadNotifications => unreadCount > 0;

  /// Inicializar o serviço e carregar notificações salvas
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadNotificationsFromStorage();
      debugPrint('NotificationStorageService initialized with ${_notifications.length} notifications');
    } catch (e) {
      debugPrint('Error initializing NotificationStorageService: $e');
    }
  }

  /// Carregar notificações do armazenamento local
  Future<void> _loadNotificationsFromStorage() async {
    try {
      final notificationsJson = _prefs?.getStringList(_notificationsKey) ?? [];
      _notifications.clear();
      
      for (final jsonString in notificationsJson) {
        try {
          final map = jsonDecode(jsonString) as Map<String, dynamic>;
          final notification = NotificationModel.fromMap(map);
          _notifications.add(notification);
        } catch (e) {
          debugPrint('Error parsing notification from storage: $e');
        }
      }
      
      // Ordenar por data (mais recentes primeiro)
      _notifications.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
      
    } catch (e) {
      debugPrint('Error loading notifications from storage: $e');
    }
  }

  /// Salvar notificações no armazenamento local
  Future<void> _saveNotificationsToStorage() async {
    try {
      final notificationsJson = _notifications
          .map((notification) => jsonEncode(notification.toMap()))
          .toList();
      
      await _prefs?.setStringList(_notificationsKey, notificationsJson);
    } catch (e) {
      debugPrint('Error saving notifications to storage: $e');
    }
  }

  /// Adicionar nova notificação
  Future<void> addNotification(NotificationModel notification) async {
    try {
      // Verificar se já existe uma notificação com o mesmo ID
      final existingIndex = _notifications.indexWhere((n) => n.id == notification.id);
      if (existingIndex != -1) {
        debugPrint('Notification with ID ${notification.id} already exists, skipping');
        return;
      }

      // Adicionar no início da lista (mais recente)
      _notifications.insert(0, notification);

      // Limitar o número de notificações
      if (_notifications.length > _maxNotifications) {
        _notifications.removeRange(_maxNotifications, _notifications.length);
      }

      // Salvar e notificar listeners
      await _saveNotificationsToStorage();
      notifyListeners();
      
      debugPrint('Notification added: ${notification.title} (Total: ${_notifications.length}, Unread: $unreadCount)');
    } catch (e) {
      debugPrint('Error adding notification: $e');
    }
  }

  /// Marcar notificação como lida
  Future<void> markAsRead(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = _notifications[index];
        if (!notification.isRead) {
          _notifications[index] = notification.copyWith(isRead: true);
          await _saveNotificationsToStorage();
          notifyListeners();
          debugPrint('Notification marked as read: $notificationId');
        }
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Marcar todas as notificações como lidas
  Future<void> markAllAsRead() async {
    try {
      bool hasChanges = false;
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
          hasChanges = true;
        }
      }
      
      if (hasChanges) {
        await _saveNotificationsToStorage();
        notifyListeners();
        debugPrint('All notifications marked as read');
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  /// Remover notificação
  Future<void> removeNotification(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications.removeAt(index);
        await _saveNotificationsToStorage();
        notifyListeners();
        debugPrint('Notification removed: $notificationId');
      }
    } catch (e) {
      debugPrint('Error removing notification: $e');
    }
  }

  /// Limpar todas as notificações
  Future<void> clearAllNotifications() async {
    try {
      _notifications.clear();
      await _saveNotificationsToStorage();
      notifyListeners();
      debugPrint('All notifications cleared');
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  /// Obter notificação por ID
  NotificationModel? getNotificationById(String id) {
    try {
      return _notifications.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obter notificações por tipo
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Obter notificações não lidas
  List<NotificationModel> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  /// Limpar notificações antigas (mais de 30 dias)
  Future<void> cleanupOldNotifications() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      final initialCount = _notifications.length;
      
      _notifications.removeWhere((n) => n.receivedAt.isBefore(cutoffDate));
      
      if (_notifications.length != initialCount) {
        await _saveNotificationsToStorage();
        notifyListeners();
        debugPrint('Cleaned up ${initialCount - _notifications.length} old notifications');
      }
    } catch (e) {
      debugPrint('Error cleaning up old notifications: $e');
    }
  }
}
