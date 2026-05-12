import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/message.dart';
import 'auth_service.dart';
import 'api_service.dart';

class ChatService {
  static Future<List<Map<String, dynamic>>> getConversations() async {
    final token = AuthService.token;
    final response = await http.get(
      Uri.parse('${ApiService.BASE_URL}/messages/conversations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['conversations']);
    }
    throw Exception('Failed to load conversations');
  }
  
  static Future<List<Message>> getMessages(int userId) async {
    final token = AuthService.token;
    final response = await http.get(
      Uri.parse('${ApiService.BASE_URL}/messages/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List messages = data['messages'];
      return messages.map((m) => Message.fromJson(m)).toList();
    }
    throw Exception('Failed to load messages');
  }
  
  static Future<void> sendMessage(int receiverId, String message) async {
    final token = AuthService.token;
    final response = await http.post(
      Uri.parse('${ApiService.BASE_URL}/messages/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'receiver_id': receiverId,
        'message': message,
      }),
    );
    
    if (response.statusCode != 201) {
      throw Exception('Failed to send message');
    }
  }
  
  static Future<void> sendImage(int receiverId, File imageFile) async {
    final token = AuthService.token;
    
    try {
      if (kIsWeb) {
        // Web platform - use base64 encoding
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        final response = await http.post(
          Uri.parse('${ApiService.BASE_URL}/messages/send-image-web'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'receiver_id': receiverId,
            'image_base64': base64Image,
            'image_name': 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          }),
        );
        
        if (response.statusCode != 201) {
          throw Exception('Failed to send image: ${response.statusCode}');
        }
      } else {
        // Mobile/Desktop platform - use MultipartFile
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiService.BASE_URL}/messages/send-image'),
        );
        
        request.headers['Authorization'] = 'Bearer $token';
        request.fields['receiver_id'] = receiverId.toString();
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
        
        var response = await request.send();
        if (response.statusCode != 201) {
          throw Exception('Failed to send image');
        }
      }
    } catch (e) {
      print('Error sending image: $e');
      rethrow;
    }
  }
  
  static Future<void> sendAudio(int receiverId, File audioFile) async {
    final token = AuthService.token;
    
    try {
      if (kIsWeb) {
        // Web platform - use base64 encoding
        final bytes = await audioFile.readAsBytes();
        final base64Audio = base64Encode(bytes);
        
        final response = await http.post(
          Uri.parse('${ApiService.BASE_URL}/messages/send-audio-web'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'receiver_id': receiverId,
            'audio_base64': base64Audio,
            'audio_name': 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
          }),
        );
        
        if (response.statusCode != 201) {
          throw Exception('Failed to send audio: ${response.statusCode}');
        }
      } else {
        // Mobile/Desktop platform - use MultipartFile
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiService.BASE_URL}/messages/send-audio'),
        );
        
        request.headers['Authorization'] = 'Bearer $token';
        request.fields['receiver_id'] = receiverId.toString();
        request.files.add(await http.MultipartFile.fromPath('audio', audioFile.path));
        
        var response = await request.send();
        if (response.statusCode != 201) {
          throw Exception('Failed to send audio');
        }
      }
    } catch (e) {
      print('Error sending audio: $e');
      rethrow;
    }
  }
  
  static Future<void> markAsRead(int messageId) async {
    final token = AuthService.token;
    await http.put(
      Uri.parse('${ApiService.BASE_URL}/messages/$messageId/read'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
  
  static Future<void> deleteMessage(int messageId) async {
    final token = AuthService.token;
    await http.delete(
      Uri.parse('${ApiService.BASE_URL}/messages/$messageId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
  
  static Future<void> sendTypingStatus(int receiverId, bool isTyping) async {
    final token = AuthService.token;
    await http.post(
      Uri.parse('${ApiService.BASE_URL}/messages/typing'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'receiver_id': receiverId,
        'is_typing': isTyping,
      }),
    );
  }
  
  static Future<bool> getTypingStatus(int userId) async {
    final token = AuthService.token;
    try {
      final response = await http.get(
        Uri.parse('${ApiService.BASE_URL}/messages/typing/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['is_typing'];
      }
    } catch (e) {
      // Ignore errors
    }
    return false;
  }
  
  static Future<int> getUnreadCount() async {
    final token = AuthService.token;
    final response = await http.get(
      Uri.parse('${ApiService.BASE_URL}/messages/unread-count'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['unread_count'];
    }
    return 0;
  }
}