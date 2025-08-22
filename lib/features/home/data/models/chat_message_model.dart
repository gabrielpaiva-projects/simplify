import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  audio,
  document,
  location,
}

class ChatMessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? audioUrl;
  final String? documentUrl;
  final String? documentName;
  final double? latitude;
  final double? longitude;
  final String? locationAddress;
  final DateTime? editedAt;
  final bool isDeleted;

  ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isRead,
    this.imageUrl,
    this.audioUrl,
    this.documentUrl,
    this.documentName,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.editedAt,
    this.isDeleted = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      receiverId: json['receiverId'] ?? '',
      receiverName: json['receiverName'] ?? '',
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      documentUrl: json['documentUrl'],
      documentName: json['documentName'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      locationAddress: json['locationAddress'],
      editedAt: json['editedAt'] != null
          ? (json['editedAt'] is Timestamp
              ? (json['editedAt'] as Timestamp).toDate()
              : DateTime.parse(json['editedAt']))
          : null,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'documentUrl': documentUrl,
      'documentName': documentName,
      'latitude': latitude,
      'longitude': longitude,
      'locationAddress': locationAddress,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'isDeleted': isDeleted,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? receiverName,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
    String? audioUrl,
    String? documentUrl,
    String? documentName,
    double? latitude,
    double? longitude,
    String? locationAddress,
    DateTime? editedAt,
    bool? isDeleted,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      documentName: documentName ?? this.documentName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAddress: locationAddress ?? this.locationAddress,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

class ChatModel {
  final String id;
  final String professionalId;
  final String professionalName;
  final String clientId;
  final String clientName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isProfessionalTyping;
  final bool isClientTyping;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? appointmentId; // Referência ao agendamento relacionado

  ChatModel({
    required this.id,
    required this.professionalId,
    required this.professionalName,
    required this.clientId,
    required this.clientName,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isProfessionalTyping = false,
    this.isClientTyping = false,
    required this.createdAt,
    this.updatedAt,
    this.appointmentId,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      professionalId: json['professionalId'] ?? '',
      professionalName: json['professionalName'] ?? '',
      clientId: json['clientId'] ?? '',
      clientName: json['clientName'] ?? '',
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? (json['lastMessageTime'] is Timestamp
              ? (json['lastMessageTime'] as Timestamp).toDate()
              : DateTime.parse(json['lastMessageTime']))
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isProfessionalTyping: json['isProfessionalTyping'] ?? false,
      isClientTyping: json['isClientTyping'] ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(json['updatedAt']))
          : null,
      appointmentId: json['appointmentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professionalId': professionalId,
      'professionalName': professionalName,
      'clientId': clientId,
      'clientName': clientName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null 
          ? Timestamp.fromDate(lastMessageTime!) 
          : null,
      'unreadCount': unreadCount,
      'isProfessionalTyping': isProfessionalTyping,
      'isClientTyping': isClientTyping,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'appointmentId': appointmentId,
    };
  }
}