import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../core/theme.dart';
import '../extensions/map_extensions.dart';

class ChatScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic>? user;
  
  const ChatScreen({super.key, required this.userId, this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _messages = [];
  bool _isLoading = true;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  
  // Typing indicator
  bool _isOtherUserTyping = false;
  Timer? _typingCheckTimer;
  bool _isTyping = false;
  Timer? _typingTimer;
  
  // Voice recording (only for non-web platforms)
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;
  
  // Audio player
  AudioPlayer? _audioPlayer;
  String? _currentPlayingUrl;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startAutoRefresh();
    _startTypingCheck();
    _setupTypingListener();
    _initAudioPlayer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _typingCheckTimer?.cancel();
    _typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    if (!kIsWeb) {
      _recorder.dispose();
    }
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();
  }

  void _setupTypingListener() {
    _messageController.addListener(() {
      if (_messageController.text.isNotEmpty && !_isTyping) {
        _sendTypingStatus(true);
        _isTyping = true;
      } else if (_messageController.text.isEmpty && _isTyping) {
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

  void _sendTypingStatus(bool isTyping) async {
    try {
      await ChatService.sendTypingStatus(widget.userId, isTyping);
    } catch (e) {
      // Ignore errors
    }
  }

  void _startTypingCheck() {
    _typingCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final isTyping = await ChatService.getTypingStatus(widget.userId);
        if (mounted && _isOtherUserTyping != isTyping) {
          setState(() => _isOtherUserTyping = isTyping);
        }
      } catch (e) {
        // Ignore errors
      }
    });
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _refreshMessages();
    });
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final messages = await ChatService.getMessages(widget.userId);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading messages: $e');
    }
  }

  Future<void> _refreshMessages() async {
    try {
      final messages = await ChatService.getMessages(widget.userId);
      if (mounted) {
        setState(() {
          _messages = messages;
        });
      }
    } catch (e) {
      print('Error refreshing messages: $e');
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final message = _messageController.text.trim();
    _messageController.clear();
    _sendTypingStatus(false);
    _isTyping = false;
    
    try {
      await ChatService.sendMessage(widget.userId, message);
      _refreshMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    
    try {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() => _isLoading = true);
        final File imageFile = File(pickedFile.path);
        await ChatService.sendImage(widget.userId, imageFile);
        _refreshMessages();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image sent!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startRecording() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice recording is not supported on web yet')),
      );
      return;
    }
    
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        _recordingPath = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(const RecordConfig(), path: _recordingPath!);
        setState(() => _isRecording = true);
      }
    } catch (e) {
      print('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording not supported on this platform')),
      );
    }
  }

  Future<void> _stopRecordingAndSend() async {
    if (!_isRecording) return;
    
    final path = await _recorder.stop();
    setState(() => _isRecording = false);
    
    if (path != null) {
      setState(() => _isLoading = true);
      try {
        await ChatService.sendAudio(widget.userId, File(path));
        _refreshMessages();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice message sent!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send audio: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _playAudio(String audioUrl) async {
    if (_currentPlayingUrl == audioUrl && _audioPlayer?.state == PlayerState.playing) {
      await _audioPlayer?.pause();
      setState(() => _currentPlayingUrl = null);
    } else {
      await _audioPlayer?.play(UrlSource('http://localhost:8000$audioUrl'));
      setState(() => _currentPlayingUrl = audioUrl);
      
      _audioPlayer?.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() => _currentPlayingUrl = null);
        }
      });
    }
  }

  void _showMessageOptions(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
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
              title: const Text('Delete Message', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await ChatService.deleteMessage(message.id);
                _refreshMessages();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message deleted')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService.user.getInt('id');
    final userAvatar = widget.user.getString('profile_image');
    final userName = widget.user.getString('name') ?? 'User';
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: userAvatar != null
                  ? NetworkImage('http://localhost:8000$userAvatar')
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
                  Text(
                    userName,
                    style: const TextStyle(fontSize: 16),
                  ),
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
                          final isMine = message.senderId == currentUserId;
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

  // Using the extension method for safe map access
  Widget _buildMessageBubble(Message message, bool isMine) {
    // Clean and safe using the extension method!
    final String? senderAvatar = isMine
        ? AuthService.user.getString('profile_image')
        : widget.user.getString('profile_image');
    
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMine)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: senderAvatar != null
                  ? NetworkImage('http://localhost:8000$senderAvatar')
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
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.imageUrl != null)
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: Image.network('http://localhost:8000${message.imageUrl}'),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'http://localhost:8000${message.imageUrl}',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    ),
                  ),
                if (message.audioUrl != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _currentPlayingUrl == message.audioUrl ? Icons.pause : Icons.play_arrow,
                          color: isMine ? Colors.white : AppColors.primary,
                        ),
                        onPressed: () => _playAudio(message.audioUrl!),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Voice message',
                          style: TextStyle(color: isMine ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                if (message.message.isNotEmpty && 
                    message.message != '📷 Sent an image' && 
                    message.message != '🎤 Sent a voice message')
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isMine ? Colors.white : Colors.black,
                    ),
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
                        child: Icon(Icons.done_all, size: 12, color: Colors.blue),
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
                  ? NetworkImage('http://localhost:8000$senderAvatar')
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
          IconButton(
            icon: const Icon(Icons.image, color: AppColors.primary),
            onPressed: _pickImage,
          ),
          if (!kIsWeb) // Hide voice recording on web
            IconButton(
              icon: Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                color: _isRecording ? Colors.red : AppColors.primary,
              ),
              onPressed: _isRecording ? _stopRecordingAndSend : _startRecording,
            ),
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
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primary),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}