import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../core/di/injection_container.dart' as di;
import 'notification_overlay_service.dart';
import 'notification_storage_service.dart';
import '../models/notification_model.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  String? _currentToken;
  NotificationOverlayService? _overlayService;
  NotificationStorageService? _storageService;

  /// Inicializar o serviço de mensagens
  Future<void> initialize() async {
    try {
      // Inicializar referência aos serviços
      _overlayService = di.sl<NotificationOverlayService>();
      _storageService = di.sl<NotificationStorageService>();
      
      // Inicializar o storage service
      await _storageService!.initialize();
      
      // Solicitar permissões para notificações
      await _requestPermissions();
      
      // Obter e salvar o token FCM
      await _getAndSaveToken();
      
      // Configurar listeners
      _setupTokenRefreshListener();
      _setupMessageListeners();
      
      _logger.i('Firebase Messaging Service initialized successfully');
    } catch (e) {
      _logger.e('Error initializing Firebase Messaging Service: $e');
    }
  }

  /// Solicitar permissões para notificações
  Future<void> _requestPermissions() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.i('User granted permission for notifications');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        _logger.i('User granted provisional permission for notifications');
      } else {
        _logger.w('User declined or has not accepted permission for notifications');
      }
    } catch (e) {
      _logger.e('Error requesting permissions: $e');
    }
  }

  /// Obter o token FCM e salvá-lo no Firestore
  Future<void> _getAndSaveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        _currentToken = token;
        await _saveTokenToFirestore(token);
        _logger.i('FCM Token obtained and saved: ${token.substring(0, 20)}...');
      }
    } catch (e) {
      _logger.e('Error getting FCM token: $e');
    }
  }

  /// Salvar o token no Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _logger.w('No authenticated user, token not saved');
        return;
      }

      final tokenData = {
        'token': token,
        'userId': user.uid,
        'userEmail': user.email,
        'platform': _getPlatform(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      // Salvar na collection 'tokens' usando o token como ID do documento
      // Isso evita duplicatas do mesmo token
      await _firestore.collection('tokens').doc(token).set(
        tokenData,
        SetOptions(merge: true),
      );

      _logger.i('Token saved to Firestore for user: ${user.uid}');
    } catch (e) {
      _logger.e('Error saving token to Firestore: $e');
    }
  }

  /// Configurar listener para refresh do token
  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) async {
      _logger.i('FCM Token refreshed');
      _currentToken = newToken;
      await _saveTokenToFirestore(newToken);
    });
  }

  /// Configurar listeners para mensagens
  void _setupMessageListeners() {
    // Mensagens em foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i('Received message in foreground: ${message.messageId}');
      _handleMessage(message);
    });

    // Mensagens quando o app é aberto via notificação
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.i('App opened from notification: ${message.messageId}');
      _handleMessage(message);
    });

    // Verificar se o app foi aberto via notificação quando estava fechado
    _checkInitialMessage();
  }

  /// Verificar mensagem inicial (quando o app foi aberto via notificação)
  Future<void> _checkInitialMessage() async {
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _logger.i('App opened from terminated state via notification: ${initialMessage.messageId}');
        _handleMessage(initialMessage);
      }
    } catch (e) {
      _logger.e('Error checking initial message: $e');
    }
  }

  /// Tratar mensagens recebidas
  void _handleMessage(RemoteMessage message) {
    _logger.i('Handling message: ${message.notification?.title}');
    
    if (message.data.isNotEmpty) {
      _logger.i('Message data: ${message.data}');
    }
    
    // Salvar notificação no storage
    _saveNotificationToStorage(message);
    
    // Mostrar badge de notificação quando o app estiver em foreground
    if (_overlayService != null) {
      if (_overlayService!.isReady) {
        _overlayService!.showNotificationBadge(message);
      } else {
        // Aguardar um pouco para garantir que o contexto esteja disponível
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_overlayService!.isReady) {
            _overlayService!.showNotificationBadge(message);
          } else {
            _logger.w('Overlay service context not ready after delay');
          }
        });
      }
    } else {
      _logger.w('Overlay service not initialized, cannot show notification badge');
    }
  }

  /// Salvar notificação recebida no storage
  void _saveNotificationToStorage(RemoteMessage message) {
    try {
      if (_storageService != null) {
        final notification = NotificationModel.fromRemoteMessage(message);
        _storageService!.addNotification(notification);
        _logger.i('Notification saved to storage: ${notification.title}');
      } else {
        _logger.w('Storage service not initialized, cannot save notification');
      }
    } catch (e) {
      _logger.e('Error saving notification to storage: $e');
    }
  }

  /// Obter o token atual
  String? get currentToken => _currentToken;

  /// Invalidar token (quando o usuário faz logout)
  Future<void> invalidateToken() async {
    try {
      if (_currentToken != null) {
        // Marcar o token como inativo no Firestore
        await _firestore.collection('tokens').doc(_currentToken!).update({
          'isActive': false,
          'invalidatedAt': FieldValue.serverTimestamp(),
        });
        
        _logger.i('Token invalidated');
      }
      
      _currentToken = null;
    } catch (e) {
      _logger.e('Error invalidating token: $e');
    }
  }

  /// Limpar tokens antigos/inativos do usuário atual
  Future<void> cleanupOldTokens() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Buscar todos os tokens do usuário
      final query = await _firestore
          .collection('tokens')
          .where('userId', isEqualTo: user.uid)
          .get();

      final batch = _firestore.batch();
      
      for (final doc in query.docs) {
        final data = doc.data();
        final tokenCreatedAt = data['createdAt'] as Timestamp?;
        
        // Remover tokens com mais de 30 dias ou inativos
        if (tokenCreatedAt != null) {
          final tokenAge = DateTime.now().difference(tokenCreatedAt.toDate());
          if (tokenAge.inDays > 30 || data['isActive'] == false) {
            batch.delete(doc.reference);
          }
        }
      }

      await batch.commit();
      _logger.i('Old tokens cleaned up for user: ${user.uid}');
    } catch (e) {
      _logger.e('Error cleaning up old tokens: $e');
    }
  }

  /// Obter plataforma atual
  String _getPlatform() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'android';
    } else {
      return 'unknown';
    }
  }

  /// Subscrever a um tópico
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _logger.i('Subscribed to topic: $topic');
    } catch (e) {
      _logger.e('Error subscribing to topic $topic: $e');
    }
  }

  /// Desinscrever de um tópico
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _logger.i('Unsubscribed from topic: $topic');
    } catch (e) {
      _logger.e('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Deletar token completamente (para casos específicos)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      if (_currentToken != null) {
        await _firestore.collection('tokens').doc(_currentToken!).delete();
      }
      _currentToken = null;
      _logger.i('FCM token deleted');
    } catch (e) {
      _logger.e('Error deleting FCM token: $e');
    }
  }
}

// Handler para mensagens em background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final logger = Logger();
  logger.i('Handling background message: ${message.messageId}');
  
  // Aqui você pode implementar lógica específica para mensagens em background
  // Por exemplo, salvar dados localmente, mostrar notificação personalizada, etc.
}


