import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';
import '../../fastApi/fastApiServices.dart';


// =================================================================
// 🧩 Chat Message Model
// =================================================================

class ChatMessage {
  final int id;
  final String fromId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final bool isSender;

  ChatMessage({
    required this.id,
    required this.fromId,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.isSender,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String myUserId) {
    return ChatMessage(
      id: json['id'] ?? 0,
      fromId: json['from_id'].toString(),
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']).toLocal(),
      isRead: json['is_read'] ?? false,
      isSender: json['from_id'].toString() == myUserId,
    );
  }
}

// =================================================================
// 🧠 Chat Page
// =================================================================

class CustomerChatPage extends StatefulWidget {
  final String astrologerUid; // ID of the astrologer (other user)
  final String myUserId; // current user ID (customer)
  final String token; // JWT token (used in headers and WebSocket)

  const CustomerChatPage({
    Key? key,
    required this.astrologerUid,
    required this.myUserId,
    required this.token,
  }) : super(key: key);

  @override
  State<CustomerChatPage> createState() => _CustomerChatPageState();
}

class _CustomerChatPageState extends State<CustomerChatPage> with WidgetsBindingObserver {
  final FastAPIServices _api = FastAPIServices();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  WebSocketChannel? _webSocketChannel;
  bool _isLoading = true;
  bool _isConnected = false;
  String? _roomId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeChat();
  }

  // =================================================================
  // 🚀 Initialize Chat
  // =================================================================
  Future<void> _initializeChat() async {
    try {
      // 1️⃣ Get or Create Room
      await _fetchOrCreateRoomId();

      // 2️⃣ Load Chat History
      if (_roomId != null) await _loadChatHistory();

      // 3️⃣ Connect WebSocket
      _connectWebSocket();

      // 4️⃣ Mark Messages as Read
      if (_roomId != null) await _markMessagesAsRead();
    } catch (e) {
      print('❌ Error initializing chat: $e');
      _showSnackBar('Chat initialization failed.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchOrCreateRoomId() async {
    // For now assume your backend auto-creates the room via WebSocket or first message.
    // If you have a specific endpoint, call it here.
    // For simplicity, use astrologerUid + myUserId combo as roomId.
    final ids = [widget.myUserId, widget.astrologerUid]..sort();
    _roomId = ids.join('_');
    print('✅ Room ID: $_roomId');
  }

  Future<void> _loadChatHistory() async {
    if (_roomId == null) return;
    try {
      final response = await _api.getChatHistory(_roomId!);
      final List<ChatMessage> history = response
          .map<ChatMessage>((json) => ChatMessage.fromJson(json, widget.myUserId))
          .toList();

      setState(() {
        _messages.clear();
        _messages.addAll(history.reversed);
      });
      _scrollToBottom();
    } catch (e) {
      print('❌ Failed to load chat history: $e');
    }
  }

  Future<void> _markMessagesAsRead() async {
    if (_roomId == null) return;
    try {
      await _api.markAsRead(_roomId!);
    } catch (e) {
      print('⚠️ Could not mark messages as read: $e');
    }
  }

  // =================================================================
  // 🔌 WebSocket Connection
  // =================================================================
  void _connectWebSocket() {
    // 🔹 Ensure required values are available
    if (widget.astrologerUid.isEmpty || widget.token.isEmpty) {
      print('❌ Missing astrologerUid or token. Cannot connect to WebSocket.');
      return;
    }

    // 🔹 Construct WebSocket URL
    final uri = Uri.parse(
        'wss://fastapi.umeed.app/api/v1/chat/ws/chat/${widget.astrologerUid}?token=${widget.token}');
    print('🔗 Connecting WebSocket: $uri');

    try {
      // 🔹 Connect to WebSocket
      _webSocketChannel = WebSocketChannel.connect(uri);
      setState(() => _isConnected = true);

      // 🔹 Listen for incoming messages
      _webSocketChannel!.stream.listen(
            (message) {
          _handleWebSocketMessage(message);
        },
        onDone: () {
          print('⚠️ WebSocket disconnected');
          setState(() => _isConnected = false);
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          setState(() => _isConnected = false);
        },
      );

      print('✅ WebSocket Connected');
    } catch (e) {
      print('❌ Failed to connect WebSocket: $e');
      setState(() => _isConnected = false);
    }
  }


  void _handleWebSocketMessage(dynamic rawMessage) {
    try {
      final json = jsonDecode(rawMessage);
      final msg = ChatMessage.fromJson(json, widget.myUserId);
      setState(() => _messages.insert(0, msg));
      _scrollToBottom();
    } catch (e) {
      print('⚠️ WebSocket message parse error: $e');
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final text = _messageController.text.trim();

    try {
      // Send via WebSocket
      _webSocketChannel?.sink.add(text);

      // Also POST to backend to persist message
      await _api.sendMessage(
        roomId: _roomId!,
        senderId: widget.myUserId,
        receiverId: widget.astrologerUid,
        message: text,
      );

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print('❌ Send message error: $e');
      _showSnackBar('Failed to send message.');
    }
  }

  void _disconnectWebSocket() {
    _webSocketChannel?.sink.close();
  }

  // =================================================================
  // 🧭 Utility
  // =================================================================
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackBar(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  void dispose() {
    _disconnectWebSocket();
    _scrollController.dispose();
    _messageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // =================================================================
  // 💬 UI
  // =================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.astrologerUid}',
            style: const TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFFE57373),
        actions: [
          Icon(
            _isConnected ? Icons.circle : Icons.circle_outlined,
            color: _isConnected ? Colors.greenAccent : Colors.white70,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFE57373)),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isMe = msg.isSender;
    return Row(
      mainAxisAlignment:
      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? const Color(0xFFE57373).withOpacity(0.9)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  msg.message,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(msg.timestamp),
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.black45,
                        fontSize: 10,
                      ),
                    ),
                    if (isMe)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          msg.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: msg.isRead
                              ? Colors.lightBlueAccent
                              : Colors.white70,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFE57373),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _isConnected ? _sendMessage : null,
            ),
          ),
        ],
      ),
    );
  }
}
