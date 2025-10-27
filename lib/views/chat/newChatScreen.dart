import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';

// =================================================================
// 0. MOCK/PLACEHOLDER CLASSES & CONSTANTS (REPLACE IN REAL APP)
// =================================================================

// ⚠️ IMPORTANT: In your production app, replace these placeholders
// with your actual values and imported classes.

// Mock ChatMessage Model (Must match your server's JSON structure)
class ChatMessage {
  final int id;
  final String fromId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final bool isSender; // Now just a field

  ChatMessage({
    required this.id,
    required this.fromId,
    required this.message,
    required this.timestamp,
    required this.isRead,
    // ❌ REMOVED 'required this.isSender' from the parameter list to fix error 1 & 2
  }) : isSender = (fromId == _mockMyUserId); // ✅ Initialized in the initializer list only

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // 💡 NOTE: The factory constructor does NOT need to pass isSender
    // because the main constructor calculates it.
    return ChatMessage(
      id: json['id'] as int? ?? 0,
      fromId: json['from_id'].toString(),
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}

// Global Mock Configuration (MUST BE REPLACED)
const String _mockServerBaseUrl = '10.0.2.2:8000'; // For Android Emulator
const String _mockMyUserId = 'CUSTOMER_USER_123';
const String _mockToken = 'TEST_CUSTOMER_JWT_TOKEN';
const Color _primaryColor = Color(0xFFE57373); // Light Red/Primary Color Mock

// Mock Service to simulate network calls
class MockChatService {
  Future<Map<String, dynamic>> getOrCreateRoomId(String otherUserId, String token) async {
    // ⚠️ REAL APP: This POSTs to /chat/room/{other_user_id}
    // For testing, we create a deterministic room ID based on user IDs
    final userList = [_mockMyUserId, otherUserId]..sort();
    final mockRoomId = userList.join('_');
    await Future.delayed(const Duration(milliseconds: 300));
    return {'room_id': mockRoomId};
  }

  Future<List<Map<String, dynamic>>> chatHistory(String roomId, String token) async {
    // ⚠️ REAL APP: This GETs /chat/{room_id}
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock history:
    return [
      {'id': 1, 'from_id': _mockMyUserId, 'message': 'Hi, I need a reading.', 'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(), 'is_read': true},
      {'id': 2, 'from_id': 'ASTROLOGER_456', 'message': 'Hello! How can I help you?', 'timestamp': DateTime.now().subtract(const Duration(minutes: 4)).toIso8601String(), 'is_read': false},
    ];
  }

  Future<void> markChatAsRead(String roomId, String token) async {
    // ⚠️ REAL APP: This POSTs to /chat/{room_id}/read
    await Future.delayed(const Duration(milliseconds: 100));
    print("MOCK: Messages in room $roomId marked as read.");
  }

  // Mocking other services just to prevent errors
  Future<bool> checkBlockStatus(String myId, String otherId, String token) async => false;
}

// =================================================================
// 1. CHAT SCREEN WIDGET
// =================================================================

class CustomerChatPage extends StatefulWidget {
  // 'uid' here is the ID of the ASTROLOGER the customer is chatting with.
  final String astrologerUid;
  const CustomerChatPage({Key? key, required this.astrologerUid}) : super(key: key);

  @override
  State<CustomerChatPage> createState() => _CustomerChatPageState();
}

class _CustomerChatPageState extends State<CustomerChatPage> with WidgetsBindingObserver {
  // SERVICES & CONTROLLERS
  final MockChatService _chatService = MockChatService();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  // STATE MANAGEMENT
  String? _myUserId;
  String? _token;
  String? _roomId; // ⭐️ NEW: Required for REST APIs
  WebSocketChannel? _webSocketChannel;
  bool _isLoading = true;
  bool _isBlocked = false; // Mocked
  bool _isBlockedByOtherUser = false; // Mocked
  bool _isConnected = false;

  // Lifecycle
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeChat();
  }

  // =================================================================
  // 2. INITIALIZATION & CORE LOGIC
  // =================================================================

  Future<void> _initializeChat() async {
    // ⚠️ REAL APP: Fetch your real user ID and token here
    _myUserId = _mockMyUserId;
    _token = _mockToken;

    if (_myUserId == null || _token == null) {
      // Handle missing auth data
      setState(() => _isLoading = false);
      _showSnackBar("Authentication failed. Cannot start chat.");
      return;
    }

    // 1. Check block status (Mocked)
    _isBlocked = await _chatService.checkBlockStatus(_myUserId!, widget.astrologerUid, _token!);
    if (_isBlocked) {
      setState(() => _isLoading = false);
      _showSnackBar("You have blocked this astrologer.");
      return;
    }

    // 2. Fetch or Create Room ID (Crucial step for REST API)
    await _fetchOrCreateRoomId();

    if (_roomId != null) {
      // 3. Load History
      await _loadChatHistory();

      // 4. Establish WebSocket (Same as Astrologer side)
      _connectWebSocket();

      // 5. Mark As Read (REST API)
      _markMessagesAsRead();
    }

    setState(() => _isLoading = false);
  }

  // ⭐️ NEW: Logic to get the room ID for REST APIs
  Future<void> _fetchOrCreateRoomId() async {
    try {
      final response = await _chatService.getOrCreateRoomId(widget.astrologerUid, _token!);
      setState(() {
        _roomId = response['room_id']?.toString();
      });
      print('✅ Fetched Room ID: $_roomId');
    } catch (e) {
      print("❌ Error fetching/creating room ID: $e");
      _showSnackBar('Failed to initialize chat room.');
    }
  }

  // ⭐️ UPDATED: Uses _roomId
  Future<void> _loadChatHistory() async {
    if (_roomId == null) return;
    try {
      final jsonHistory = await _chatService.chatHistory(_roomId!, _token!);
      final history = jsonHistory.map((json) => ChatMessage.fromJson(json)).toList();

      setState(() {
        _messages.clear();
        _messages.addAll(history.reversed); // Display latest message at the bottom
      });
      _scrollToBottom();
    } catch (e) {
      print("❌ Error loading chat history: $e");
      _showSnackBar("Could not load previous messages.");
    }
  }

  // ⭐️ NEW: Implements the REST API call to mark messages as read
  Future<void> _markMessagesAsRead() async {
    if (_roomId == null) return;
    try {
      await _chatService.markChatAsRead(_roomId!, _token!);
      // Optionally update the local messages list to show 'read' status
    } catch (e) {
      print("❌ Error marking messages as read: $e");
    }
  }

  // ⭐️ SAME AS ASTROLOGER SIDE: WebSocket Connection
  void _connectWebSocket() {
    // ⚠️ The WebSocket URI uses the other user's ID, not the room ID.
    // This is consistent with your existing FastAPI setup.
    final uri = Uri.parse(
        'ws://$_mockServerBaseUrl/ws/chat/${widget.astrologerUid}?token=$_token');

    try {
      _webSocketChannel = WebSocketChannel.connect(uri);
      setState(() => _isConnected = true);

      _webSocketChannel!.stream.listen(
            (message) {
          _handleWebSocketMessage(message);
        },
        onDone: () {
          print('WebSocket closed');
          setState(() => _isConnected = false);
        },
        onError: (error) {
          print('WebSocket error: $error');
          setState(() => _isConnected = false);
        },
      );
      print('✅ WebSocket Connected');
    } catch (e) {
      print('❌ WebSocket Connection Failed: $e');
      setState(() => _isConnected = false);
    }
  }

  // ⭐️ SAME AS ASTROLOGER SIDE: Message Handling
  void _handleWebSocketMessage(dynamic rawMessage) {
    try {
      // Assuming your server sends back a JSON string of the ChatMessage
      final json = jsonDecode(rawMessage);
      final message = ChatMessage.fromJson(json);

      setState(() {
        // Prevent duplicate messages if the server echos back
        if (!_messages.any((m) => m.id == message.id && m.timestamp.isAtSameMomentAs(message.timestamp))) {
          _messages.insert(0, message);
        }
      });
      _scrollToBottom();
      _markMessagesAsRead(); // Mark incoming message as read
    } catch (e) {
      print('Error parsing or processing WebSocket message: $e');
    }
  }

  // ⭐️ SAME AS ASTROLOGER SIDE: Send Message
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _webSocketChannel == null || !_isConnected) return;

    final messageText = _messageController.text.trim();

    // ⚠️ Your existing FastAPI setup expects the raw text string to be sent
    _webSocketChannel!.sink.add(messageText);

    _messageController.clear();
  }

  // ⭐️ SAME AS ASTROLOGER SIDE: Disconnect
  void _disconnectWebSocket() {
    _webSocketChannel?.sink.close();
    setState(() => _isConnected = false);
  }

  // Utility Methods
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disconnectWebSocket();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // =================================================================
  // 3. UI BUILD
  // =================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Astrologer (${widget.astrologerUid})', style: const TextStyle(fontSize: 16)),
        backgroundColor: _primaryColor,
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.circle : Icons.circle_outlined, color: _isConnected ? Colors.greenAccent : Colors.white70),
            onPressed: () {},
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
          : Column(
        children: <Widget>[
          // Status Banner
          if (_isBlocked || _isBlockedByOtherUser)
            Container(
              width: double.infinity,
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _isBlocked ? 'You have blocked this user.' : 'You are blocked by this user.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),

          // Chat Bubbles List
          Expanded(
            child: ListView.builder(
              reverse: true, // Newest messages at the bottom
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index]; // Display messages in reverse chronological order
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Message Input Area
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.isSender;

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(top: 6.0, bottom: 6.0),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: isMe ? _primaryColor.withOpacity(0.9) : Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.message,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 15.0,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(message.timestamp),
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.black45,
                        fontSize: 10.0,
                      ),
                    ),
                    if (isMe)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14.0,
                          color: message.isRead ? Colors.lightBlueAccent : Colors.white70,
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
      padding: const EdgeInsets.all(8.0),
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
        children: <Widget>[
          // Text Input
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: null,
            ),
          ),

          const SizedBox(width: 8),

          // Send Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (_isBlocked || _isBlockedByOtherUser || !_isConnected)
                  ? Colors.grey
                  : _primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: (_isBlocked || _isBlockedByOtherUser || !_isConnected) ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
