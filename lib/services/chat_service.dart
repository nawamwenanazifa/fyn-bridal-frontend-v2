import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../models/message.dart';
import 'auth_service.dart';
import 'api_service.dart';

class ChatService {
  // ─────────────────────────────────────────────
  // Shared headers helper
  // ─────────────────────────────────────────────
  static Map<String, String> get _headers {
    final token = AuthService.token;
    print('🔑 ChatService Token: ${token != null && token.isNotEmpty ? "Token exists (${token.substring(0, token.length > 20 ? 20 : token.length)}...)" : "NO TOKEN!"}');
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  static Map<String, String> get _jsonHeaders {
    final token = AuthService.token;
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  // ─────────────────────────────────────────────
  // CONVERSATIONS
  // ─────────────────────────────────────────────

  /// Get all conversations for the logged-in user
  static Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      print('📡 Fetching conversations from: ${ApiService.BASE_URL}/messages/conversations');
      
      final response = await http.get(
        Uri.parse('${ApiService.BASE_URL}/messages/conversations'),
        headers: _headers,
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['conversations'] != null) {
          return List<Map<String, dynamic>>.from(data['conversations']);
        } else if (data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        return [];
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else {
        throw Exception('Failed to load conversations: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ GetConversations Error: $e');
      throw Exception('Failed to load conversations: $e');
    }
  }

  /// Get or create a conversation with another user.
  /// Returns the conversation_id to use for WebSocket subscription.
  static Future<Map<String, dynamic>> getOrCreateConversation(
      int userId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.BASE_URL}/messages/conversations'),
        headers: _jsonHeaders,
        body: jsonEncode({'user_id': userId}),
      );

      print('📡 GetOrCreateConversation status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to get/create conversation: ${response.statusCode}');
    } catch (e) {
      print('❌ GetOrCreateConversation Error: $e');
      rethrow;
    }
  }

  /// Load messages by conversation_id (used with real-time / Reverb)
  static Future<List<Message>> getConversationMessages(
      int conversationId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiService.BASE_URL}/messages/conversations/$conversationId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final messagesList = data['messages'] ?? data['data'] ?? [];
        return (messagesList as List)
            .map((m) => Message.fromJson(m))
            .toList();
      }
      throw Exception('Failed to load conversation messages: ${response.statusCode}');
    } catch (e) {
      print('❌ GetConversationMessages Error: $e');
      rethrow;
    }
  }

  /// Mark all messages in a conversation as read
  static Future<void> markConversationAsRead(int conversationId) async {
    try {
      await http.post(
        Uri.parse(
            '${ApiService.BASE_URL}/messages/conversations/$conversationId/read'),
        headers: _headers,
      );
    } catch (e) {
      print('❌ MarkConversationAsRead Error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // MESSAGES (legacy — load by userId)
  // ─────────────────────────────────────────────

  /// Load messages between auth user and another user (legacy route)
  static Future<List<Message>> getMessages(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.BASE_URL}/messages/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final messagesList = data['messages'] ?? data['data'] ?? [];
        return (messagesList as List)
            .map((m) => Message.fromJson(m))
            .toList();
      }
      throw Exception('Failed to load messages: ${response.statusCode}');
    } catch (e) {
      print('❌ GetMessages Error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // SEND TEXT
  // ─────────────────────────────────────────────

  /// Send a plain text message (broadcasts via Reverb on the server)
  static Future<void> sendMessage(int receiverId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.BASE_URL}/messages/send'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'receiver_id': receiverId,
          'message': message,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ SendMessage Error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // SEND IMAGE
  // ─────────────────────────────────────────────

  /// Send image — automatically picks the right method for web vs mobile.
  static Future<void> sendImage(int receiverId, File imageFile) async {
    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      await sendImageWeb(receiverId, base64Image, 'jpg');
    } else {
      final bytes = await imageFile.readAsBytes();
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      await sendImageBytes(
          receiverId, bytes, imageFile.path.split('/').last, mimeType);
    }
  }

  /// Send image bytes as multipart (mobile / desktop)
  static Future<void> sendImageBytes(
    int receiverId,
    Uint8List bytes,
    String filename,
    String mimeType,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.BASE_URL}/messages/send-image'),
      )
        ..headers.addAll(_headers)
        ..fields['receiver_id'] = receiverId.toString()
        ..files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: filename,
          contentType: MediaType.parse(mimeType),
        ));

      final response = await request.send();
      if (response.statusCode != 201) {
        throw Exception('Failed to send image: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ SendImageBytes Error: $e');
      rethrow;
    }
  }

  /// Send image as base64 (Flutter Web — avoids _Namespace error)
  static Future<void> sendImageWeb(
    int receiverId,
    String base64Data,
    String extension,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.BASE_URL}/messages/send-image-web'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'receiver_id': receiverId,
          'image_base64': base64Data,
          'extension': extension,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send image (web): ${response.statusCode}');
      }
    } catch (e) {
      print('❌ SendImageWeb Error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // SEND AUDIO
  // ─────────────────────────────────────────────

  /// Send audio — automatically picks the right method for web vs mobile.
  static Future<void> sendAudio(int receiverId, File audioFile) async {
    if (kIsWeb) {
      final bytes = await audioFile.readAsBytes();
      final base64Audio = base64Encode(bytes);
      await sendAudioWeb(receiverId, base64Audio, 'ogg');
    } else {
      final bytes = await audioFile.readAsBytes();
      await sendAudioBytes(receiverId, bytes, audioFile.path.split('/').last);
    }
  }

  /// Send audio bytes as multipart (mobile / desktop)
  static Future<void> sendAudioBytes(
    int receiverId,
    Uint8List bytes,
    String filename,
  ) async {
    try {
      final ext = filename.split('.').last;
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.BASE_URL}/messages/send-audio'),
      )
        ..headers.addAll(_headers)
        ..fields['receiver_id'] = receiverId.toString()
        ..files.add(http.MultipartFile.fromBytes(
          'audio',
          bytes,
          filename: filename,
          contentType: MediaType('audio', ext),
        ));

      final response = await request.send();
      if (response.statusCode != 201) {
        throw Exception('Failed to send audio: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ SendAudioBytes Error: $e');
      rethrow;
    }
  }

  /// Send audio as base64 (Flutter Web)
  static Future<void> sendAudioWeb(
    int receiverId,
    String base64Data,
    String extension,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.BASE_URL}/messages/send-audio-web'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'receiver_id': receiverId,
          'audio_base64': base64Data,
          'extension': extension,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send audio (web): ${response.statusCode}');
      }
    } catch (e) {
      print('❌ SendAudioWeb Error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // READ RECEIPTS
  // ─────────────────────────────────────────────

  /// Mark a single message as read
  static Future<void> markAsRead(int messageId) async {
    try {
      await http.put(
        Uri.parse('${ApiService.BASE_URL}/messages/$messageId/read'),
        headers: _headers,
      );
    } catch (e) {
      print('❌ MarkAsRead Error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────

  static Future<void> deleteMessage(int messageId) async {
    try {
      await http.delete(
        Uri.parse('${ApiService.BASE_URL}/messages/$messageId'),
        headers: _headers,
      );
    } catch (e) {
      print('❌ DeleteMessage Error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // TYPING INDICATORS
  // ─────────────────────────────────────────────

  static Future<void> sendTypingStatus(int receiverId, bool isTyping) async {
    try {
      await http.post(
        Uri.parse('${ApiService.BASE_URL}/messages/typing'),
        headers: _jsonHeaders,
        body: jsonEncode({
          'receiver_id': receiverId,
          'is_typing': isTyping,
        }),
      );
    } catch (e) {
      // Silent fail for typing indicators
      print('⚠️ SendTypingStatus Error: $e');
    }
  }

  static Future<bool> getTypingStatus(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.BASE_URL}/messages/typing/$userId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['is_typing'] ?? false;
      }
    } catch (_) {}
    return false;
  }

  // ─────────────────────────────────────────────
  // UNREAD COUNT
  // ─────────────────────────────────────────────

  static Future<int> getUnreadCount() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.BASE_URL}/messages/unread-count'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['unread_count'] ?? 0;
      }
    } catch (_) {}
    return 0;
  }
}