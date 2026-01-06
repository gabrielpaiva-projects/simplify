import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final DateTime receivedAt;
  final bool isRead;
  final String? type;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.data,
    required this.receivedAt,
    this.isRead = false,
    this.type,
  });

  factory NotificationModel.fromRemoteMessage(RemoteMessage message) {
    return NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notificação',
      body: message.notification?.body ?? '',
      imageUrl: message.notification?.android?.imageUrl ?? message.notification?.apple?.imageUrl,
      data: message.data,
      receivedAt: DateTime.now(),
      isRead: false,
      type: message.data['type'] as String?,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? imageUrl,
    Map<String, dynamic>? data,
    DateTime? receivedAt,
    bool? isRead,
    String? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      receivedAt: receivedAt ?? this.receivedAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'receivedAt': receivedAt.millisecondsSinceEpoch,
      'isRead': isRead,
      'type': type,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      imageUrl: map['imageUrl'] as String?,
      data: Map<String, dynamic>.from(map['data'] as Map),
      receivedAt: DateTime.fromMillisecondsSinceEpoch(map['receivedAt'] as int),
      isRead: map['isRead'] as bool? ?? false,
      type: map['type'] as String?,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, body: $body, isRead: $isRead, receivedAt: $receivedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
