import 'package:fyn_bridals/services/auth_service.dart';

class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final String? imageUrl;
  final String? audioUrl;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? sender;
  final Map<String, dynamic>? receiver;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.imageUrl,
    this.audioUrl,
    required this.isRead,
    required this.createdAt,
    this.sender,
    this.receiver,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'] ?? '',
      imageUrl: json['image_url'],
      audioUrl: json['audio_url'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      sender: json['sender'],
      receiver: json['receiver'],
    );
  }

  bool get isMine => senderId == AuthService.user?['id'];
}