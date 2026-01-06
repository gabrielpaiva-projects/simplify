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

  Future<void> initialize() async {
    try {
      _overlayService = di.sl<NotificationOverlayService>();
      _storageService = di.sl<NotificationStorageService>();
      
      await _storageService!.initialize();
      
      await _requestPermissions();
      
      await _getAndSaveToken();
      
      _setupTokenRefreshListener();
      _setupMessageListeners();
      
      _logger.i('Firebase Messaging Service initialized successfully');
    } catch (e) {
      _logger.e('Error initializing Firebase Messaging Service: $e');
    }
  }

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

      await _firestore.collection('tokens').doc(token).set(
        tokenData,
        SetOptions(merge: true),
      );

      _logger.i('Token saved to Firestore for user: ${user.uid}');
    } catch (e) {
      _logger.e('Error saving token to Firestore: $e');
    }
  }

  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) async {
      _logger.i('FCM Token refreshed');
      _currentToken = newToken;
      await _saveTokenToFirestore(newToken);
    });
  }

  void _setupMessageListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i('Received message in foreground: ${message.messageId}');
      _handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.i('App opened from notification: ${message.messageId}');
      _handleMessage(message);
    });

    _checkInitialMessage();
  }

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

  void _handleMessage(RemoteMessage message) {
    _logger.i('Handling message: ${message.notification?.title}');
    
    if (message.data.isNotEmpty) {
      _logger.i('Message data: ${message.data}');
    }
    
    _saveNotificationToStorage(message);
    
    if (_overlayService != null) {
      if (_overlayService!.isReady) {
        _overlayService!.showNotificationBadge(message);
      } else {
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

  String? get currentToken => _currentToken;

  Future<void> invalidateToken() async {
    try {
      if (_currentToken != null) {
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

  Future<void> cleanupOldTokens() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final query = await _firestore
          .collection('tokens')
          .where('userId', isEqualTo: user.uid)
          .get();

      final batch = _firestore.batch();
      
      for (final doc in query.docs) {
        final data = doc.data();
        final tokenCreatedAt = data['createdAt'] as Timestamp?;
        
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

  String _getPlatform() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'android';
    } else {
      return 'unknown';
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _logger.i('Subscribed to topic: $topic');
    } catch (e) {
      _logger.e('Error subscribing to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _logger.i('Unsubscribed from topic: $topic');
    } catch (e) {
      _logger.e('Error unsubscribing from topic $topic: $e');
    }
  }

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

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final logger = Logger();
  logger.i('Handling background message: ${message.messageId}');
  
}


