import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/chat_service.dart';
import '../core/theme.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final conversations = await ChatService.getConversations();
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : _conversations.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _conversations.length,
                      itemBuilder: (context, index) {
                        final conv = _conversations[index];
                        final user = conv['user'];
                        return _buildConversationTile(user, conv);
                      },
                    ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadConversations,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Try Again', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No messages yet'),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with the admin',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/chat/1'), // Admin ID is 1
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Message Admin', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> user, Map<String, dynamic> conv) {
    final hasUnread = conv['unread_count'] > 0;
    final profileImage = user['profile_image'];
    
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        backgroundImage: profileImage != null
            ? NetworkImage('http://localhost:8000$profileImage')
            : null,
        child: profileImage == null
            ? Icon(
                user['name'].toLowerCase().contains('admin') ? Icons.admin_panel_settings : Icons.person,
                color: AppColors.primary,
              )
            : null,
      ),
      title: Text(
        user['name'] ?? 'User',
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        conv['last_message'] ?? 'No messages',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
          color: hasUnread ? Colors.black : Colors.grey,
        ),
      ),
      trailing: hasUnread
          ? Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                conv['unread_count'].toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : Text(
              conv['last_message_time'] ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
      onTap: () {
        context.push('/chat/${user['id']}', extra: user);
      },
    );
  }
}