import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../core/theme.dart';
import '../extensions/map_extensions.dart';

// ─────────────────────────────────────────────
// CONFIG — Updated with localhost
// ─────────────────────────────────────────────
const String _kBaseUrl      = 'http://127.0.0.1:8000';
const String _kReverbHost   = '127.0.0.1';
const int    _kReverbPort   = 8080;
const String _kReverbAppKey = 'qjqotchy0lqsd1u3e445';

class ChatScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic>? user;

  const ChatScreen({super.key, required this.userId, this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // ── State ──────────────────────────────────
  List<Message> _messages   = [];
  bool _isLoading           = true;
  int? _conversationId;

  // ── Controllers ────────────────────────────
  final TextEditingController _messageController = TextEditingController();
  final ScrollController       _scrollController  = ScrollController();

  // ── Typing ─────────────────────────────────
  bool   _isOtherUserTyping = false;
  bool   _isTyping          = false;
  Timer? _typingTimer;
  Timer? _typingCheckTimer;

  // ── WebSocket (Reverb) ─────────────────────
  WebSocketChannel? _wsChannel;
  String?           _socketId;
  StreamSubscription? _wsSub;

  // ── Audio ──────────────────────────────────
  final AudioRecorder _recorder      = AudioRecorder();
  bool                _isRecording   = false;
  AudioPlayer?        _audioPlayer;
  String?             _currentPlayingUrl;

  // ── Image picker ───────────────────────────
  final ImagePicker _picker = ImagePicker();

  // ───────────────────────────────────────────
  // Lifecycle
  // ───────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupTypingListener();
    _startTypingCheck();
    _initChat();
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _wsChannel?.sink.close();
    _typingTimer?.cancel();
    _typingCheckTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _recorder.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────
  // Init: get/create conversation then connect
  // ───────────────────────────────────────────
  Future<void> _initChat() async {
    try {
      // 1. Get or create conversation
      final token = AuthService.token;
      final res   = await http.post(
        Uri.parse('$_kBaseUrl/api/messages/conversations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type':  'application/json',
          'Accept':        'application/json',
        },
        body: jsonEncode({'user_id': widget.userId}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        _conversationId = data['conversation_id'];
      }

      // 2. Load existing messages
      await _loadMessages();

      // 3. Connect WebSocket
      if (_conversationId != null) {
        _connectWebSocket();
      }
    } catch (e) {
      debugPrint('initChat error: $e');
      setState(() => _isLoading = false);
    }
  }

  // ───────────────────────────────────────────
  // WebSocket connection to Reverb
  // ───────────────────────────────────────────
  void _connectWebSocket() {
    final wsUri = Uri.parse(
      'ws://$_kReverbHost:$_kReverbPort/app/$_kReverbAppKey'
      '?protocol=7&client=flutter&version=1.0',
    );

    _wsChannel = WebSocketChannel.connect(wsUri);

    _wsSub = _wsChannel!.stream.listen(
      (data) => _handleWsMessage(data),
      onError: (e) {
        debugPrint('WebSocket error: $e');
        // Auto-reconnect after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _connectWebSocket();
        });
      },
      onDone: () {
        debugPrint('WebSocket closed');
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _connectWebSocket();
        });
      },
    );
  }

  void _handleWsMessage(dynamic raw) {
    try {
      final json  = jsonDecode(raw as String) as Map<String, dynamic>;
      final event = json['event'] as String?;

      if (event == 'pusher:connection_established') {
        final connData = jsonDecode(json['data'] as String);
        _socketId = connData['socket_id'] as String?;
        _subscribeToChannel();
        return;
      }

      if (event == 'pusher:subscription_succeeded') {
        debugPrint('Subscribed to conversation channel');
        return;
      }

      // New message from Reverb
      if (event == 'App\\Events\\MessageSent') {
        final payload = jsonDecode(json['data'] as String) as Map<String, dynamic>;
        final newMsg  = Message.fromJson(payload);
        if (mounted) {
          setState(() => _messages.add(newMsg));
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint('WS parse error: $e');
    }
  }

  Future<void> _subscribeToChannel() async {
    if (_conversationId == null || _socketId == null) return;

    final channelName = 'private-conversation.$_conversationId';
    final token       = AuthService.token;

    // Authenticate with Laravel broadcasting/auth
    final authRes = await http.post(
      Uri.parse('$_kBaseUrl/broadcasting/auth'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type':  'application/json',
        'Accept':        'application/json',
      },
      body: jsonEncode({
        'socket_id':    _socketId,
        'channel_name': channelName,
      }),
    );

    if (authRes.statusCode == 200) {
      final auth = jsonDecode(authRes.body);
      _wsChannel?.sink.add(jsonEncode({
        'event': 'pusher:subscribe',
        'data': {
          'channel': channelName,
          'auth':    auth['auth'],
        },
      }));
    } else {
      debugPrint('Channel auth failed: ${authRes.body}');
    }
  }

  // ───────────────────────────────────────────
  // Load messages
  // ───────────────────────────────────────────
  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      List<Message> messages;
      if (_conversationId != null) {
        messages = await ChatService.getConversationMessages(_conversationId!);
      } else {
        messages = await ChatService.getMessages(widget.userId);
      }
      if (mounted) {
        setState(() {
          _messages  = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('loadMessages error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ───────────────────────────────────────────
  // Typing
  // ───────────────────────────────────────────
  void _setupTypingListener() {
    _messageController.addListener(() {
      final hasText = _messageController.text.isNotEmpty;
      if (hasText && !_isTyping) {
        _sendTypingStatus(true);
        _isTyping = true;
      } else if (!hasText && _isTyping) {
        _sendTypingStatus(false);
        _isTyping = false;
      }
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (_isTyping) {
          _sendTypingStatus(false);
          _isTyping = false;
        }
      });
    });
  }

  void _startTypingCheck() {
    _typingCheckTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final isTyping = await ChatService.getTypingStatus(widget.userId);
        if (mounted && _isOtherUserTyping != isTyping) {
          setState(() => _isOtherUserTyping = isTyping);
        }
      } catch (_) {}
    });
  }

  void _sendTypingStatus(bool isTyping) async {
    try {
      await ChatService.sendTypingStatus(widget.userId, isTyping);
    } catch (_) {}
  }

  // ───────────────────────────────────────────
  // Send text
  // ───────────────────────────────────────────
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _sendTypingStatus(false);
    _isTyping = false;

    // Optimistic UI
    final optimistic = Message(
      id:         0,
      senderId:   AuthService.user.getInt('id') ?? 0,
      receiverId: widget.userId,
      message:    text,
      isRead:     false,
      createdAt:  DateTime.now(),
    );
    setState(() => _messages.add(optimistic));
    _scrollToBottom();

    try {
      await ChatService.sendMessage(widget.userId, text);
    } catch (e) {
      // Remove optimistic message on failure
      setState(() => _messages.remove(optimistic));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    }
  }

  // ───────────────────────────────────────────
  // Send image (web-compatible)
  // ───────────────────────────────────────────
  Future<void> _pickAndSendImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source:    ImageSource.gallery,
        maxWidth:  1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (file == null) return;

      setState(() => _isLoading = true);

      if (kIsWeb) {
        // Flutter Web: use base64
        final bytes  = await file.readAsBytes();
        final base64 = base64Encode(bytes);
        final ext    = file.name.split('.').last;
        await ChatService.sendImageWeb(widget.userId, base64, ext);
      } else {
        // Mobile/Desktop: multipart
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final bytes    = await file.readAsBytes();
        await ChatService.sendImageBytes(
          widget.userId,
          bytes,
          file.name,
          mimeType,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image sent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ───────────────────────────────────────────
  // Voice recording (web + mobile)
  // ───────────────────────────────────────────
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopAndSendAudio();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.opus),
          path: '', // ignored on web
        );
        setState(() => _isRecording = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission denied')),
          );
        }
      }
    } catch (e) {
      debugPrint('startRecording error: $e');
    }
  }

  Future<void> _stopAndSendAudio() async {
    final path = await _recorder.stop();
    setState(() => _isRecording = false);
    if (path == null) return;

    setState(() => _isLoading = true);
    try {
      if (kIsWeb) {
        // Flutter Web: fetch blob URL → bytes → base64
        final client   = http.Client();
        final response = await client.get(Uri.parse(path));
        final bytes    = response.bodyBytes;
        final base64   = base64Encode(bytes);
        await ChatService.sendAudioWeb(widget.userId, base64, 'ogg');
      } else {
        // Mobile: send file bytes
        // ignore: avoid_slow_async_io
        final bytes = await _readFileBytes(path);
        await ChatService.sendAudioBytes(widget.userId, bytes, 'recording.ogg');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice message sent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send audio: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Uint8List> _readFileBytes(String path) async {
    // Only called on non-web platforms
    final file = await http.get(Uri.file(path));
    return file.bodyBytes;
  }

  // ───────────────────────────────────────────
  // Audio playback
  // ───────────────────────────────────────────
  Future<void> _playAudio(String audioUrl) async {
    final fullUrl = '$_kBaseUrl$audioUrl';
    if (_currentPlayingUrl == audioUrl &&
        _audioPlayer?.state == PlayerState.playing) {
      await _audioPlayer?.pause();
      setState(() => _currentPlayingUrl = null);
    } else {
      await _audioPlayer?.play(UrlSource(fullUrl));
      setState(() => _currentPlayingUrl = audioUrl);
      _audioPlayer?.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _currentPlayingUrl = null);
      });
    }
  }

  // ───────────────────────────────────────────
  // Delete message
  // ───────────────────────────────────────────
  void _showMessageOptions(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.message.isNotEmpty &&
                message.message != '📷 Sent an image' &&
                message.message != '🎤 Sent a voice message')
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Text'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await ChatService.deleteMessage(message.id);
                setState(() => _messages.removeWhere((m) => m.id == message.id));
              },
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────
  // Build
  // ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService.user.getInt('id');
    final userAvatar    = widget.user.getString('profile_image');
    final userName      = widget.user.getString('name') ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: userAvatar != null
                  ? NetworkImage('$_kBaseUrl$userAvatar')
                  : null,
              child: userAvatar == null
                  ? const Icon(Icons.person, size: 18, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName, style: const TextStyle(fontSize: 16)),
                  if (_isOtherUserTyping)
                    const Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 4),
                        Text('typing...', style: TextStyle(fontSize: 10)),
                      ],
                    )
                  else
                    const Text(
                      'Online',
                      style: TextStyle(fontSize: 10, color: Colors.green),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _buildEmptyChat()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMine  = message.senderId == currentUserId;
                          return GestureDetector(
                            onLongPress: () => _showMessageOptions(message),
                            child: _buildMessageBubble(message, isMine),
                          );
                        },
                      ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No messages yet'),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with ${widget.user.getString('name') ?? 'user'}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMine) {
    final String? senderAvatar = isMine
        ? AuthService.user.getString('profile_image')
        : widget.user.getString('profile_image');

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMine)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: senderAvatar != null
                  ? NetworkImage('$_kBaseUrl$senderAvatar')
                  : null,
              child: senderAvatar == null
                  ? const Icon(Icons.person, size: 16, color: AppColors.primary)
                  : null,
            ),
          if (!isMine) const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMine ? AppColors.primary : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                if (message.imageUrl != null)
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        child: Image.network(
                            '$_kBaseUrl${message.imageUrl}'),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '$_kBaseUrl${message.imageUrl}',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    ),
                  ),
                // Audio
                if (message.audioUrl != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _currentPlayingUrl == message.audioUrl
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: isMine ? Colors.white : AppColors.primary,
                        ),
                        onPressed: () => _playAudio(message.audioUrl!),
                      ),
                      Expanded(
                        child: Text(
                          'Voice message',
                          style: TextStyle(
                              color: isMine ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                // Text
                if (message.message.isNotEmpty &&
                    message.message != '📷 Sent an image' &&
                    message.message != '🎤 Sent a voice message')
                  Text(
                    message.message,
                    style: TextStyle(
                        color: isMine ? Colors.white : Colors.black),
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMine ? Colors.white70 : Colors.grey,
                      ),
                    ),
                    if (isMine && message.isRead)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.done_all,
                            size: 12, color: Colors.blue),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (isMine) const SizedBox(width: 8),
          if (isMine)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: senderAvatar != null
                  ? NetworkImage('$_kBaseUrl$senderAvatar')
                  : null,
              child: senderAvatar == null
                  ? const Icon(Icons.person, size: 16, color: AppColors.primary)
                  : null,
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          // Image picker (works on web now)
          IconButton(
            icon: const Icon(Icons.image, color: AppColors.primary),
            onPressed: _isLoading ? null : _pickAndSendImage,
          ),
          // Voice recording (works on web now too)
          IconButton(
            icon: Icon(
              _isRecording ? Icons.stop_circle : Icons.mic_none,
              color: _isRecording ? Colors.red : AppColors.primary,
            ),
            onPressed: _isLoading ? null : _toggleRecording,
          ),
          // Text input
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          // Send button
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primary),
            onPressed: _isLoading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now        = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1)   return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) {
      return '${time.hour.toString().padLeft(2, '0')}:'
             '${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.month}/${time.day} '
           '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}';
  }
}