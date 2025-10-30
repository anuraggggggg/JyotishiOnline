import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../fastApi/fastapiservices.dart';
import '../../model/fastApiModel/newChatModel.dart';

class CustomerChatPage extends StatefulWidget {
  final String astrologerUid;
  final String? roomId;
  final String? myUserId;
  final String? token;

  const CustomerChatPage({
    Key? key,
    required this.astrologerUid,
    this.roomId,
    this.myUserId,
    this.token,
  }) : super(key: key);

  @override
  State<CustomerChatPage> createState() => _CustomerChatPageState();
}

class _CustomerChatPageState extends State<CustomerChatPage> {
  final FastAPIServices _api = FastAPIServices();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  WebSocket? _socket;
  bool _isConnected = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _messages = [];
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  String? _myUserId;
  String? _token;
  String? _roomId;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  /// ✅ Load stored user data, chat history and connect socket
  Future<void> _initializeUserData() async {
    debugPrint('🧠 Loading stored user data...');
    final prefs = await SharedPreferences.getInstance();

    _myUserId = widget.myUserId ?? prefs.getString('userId');
    _token = widget.token ?? prefs.getString('accessToken');
    _roomId = widget.roomId ?? 'room_${widget.astrologerUid}_$_myUserId';

    debugPrint('✅ Loaded userId: $_myUserId');
    debugPrint('✅ Loaded token: $_token');
    debugPrint('✅ Room ID: $_roomId');

    if (_myUserId == null) {
      debugPrint('⚠️ Missing user ID! Cannot continue.');
      return;
    }

    await _loadChatHistory();
    setState(() => _isLoading = false);
    _connectWebSocket();
  }

  /// ✅ Fetch previous chat messages
  Future<void> _loadChatHistory() async {
    debugPrint('📦 Fetching chat history for astrologer: $widget.astrologerUid');

    try {
      final messages = await _api.getChatHistory(widget.astrologerUid);

      if (messages.isEmpty) {
        debugPrint('⚠️ No chat messages found.');
      }

      setState(() {
        _messages = messages
            .map((msg) => {
          'sender_id': msg.senderId,
          'message': msg.content,
          'created_at': msg.createdAt.toIso8601String(),
        })
            .toList();
      });

      debugPrint('✅ Loaded ${_messages.length} messages from history');
    } catch (e, st) {
      debugPrint('❌ Error loading chat history: $e');
      debugPrint('📄 Stack trace: $st');
    }
  }






  /// ✅ WebSocket connection setup
  Future<void> _connectWebSocket() async {
    final wsUrl = Uri.parse('wss://fastapi.jyotishionline.com/chat/ws/$_roomId');
    debugPrint('🌐 Connecting to WebSocket: $wsUrl');

    try {
      _socket = await WebSocket.connect(wsUrl.toString());
      setState(() => _isConnected = true);
      debugPrint('✅ WebSocket connected successfully');

      _socket!.listen(
            (data) => _handleIncomingMessage(data),
        onDone: _handleDisconnect,
        onError: (error) {
          debugPrint('⚠️ WebSocket error: $error');
          _handleDisconnect();
        },
      );

      _sendRaw({
        "action": "join",
        "room_id": _roomId,
        "sender_id": _myUserId,
        "receiver_id": widget.astrologerUid,
      });

      _startPing();
    } catch (e) {
      debugPrint('❌ WebSocket connection failed: $e');
      _scheduleReconnect();
    }
  }

  void _handleIncomingMessage(dynamic data) {
    debugPrint('📨 Incoming message: $data');
    try {
      final decoded = jsonDecode(data);
      if (decoded['type'] == 'pong' || decoded['action'] == 'join') return;

      final msg = decoded['message'] ?? decoded;
      final content = msg['content'] ?? msg['message'];
      if (content == null) return;

      setState(() {
        _messages.add({
          'sender_id': msg['sender_id'] ?? '',
          'message': content,
          'created_at': msg['created_at'] ?? DateTime.now().toIso8601String(),
        });
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Failed to decode message: $e');
    }
  }

  void _handleDisconnect() {
    debugPrint('❌ Disconnected from WebSocket');
    _stopPing();
    setState(() => _isConnected = false);
    _socket = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive ?? false) return;
    debugPrint('🔁 Scheduling reconnect in 5 seconds...');
    _reconnectTimer = Timer(const Duration(seconds: 5), _connectWebSocket);
  }

  void _startPing() {
    _stopPing();
    debugPrint('🏓 Starting ping timer...');
    _pingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _sendRaw({"action": "ping", "ts": DateTime.now().toIso8601String()});
    });
  }

  void _stopPing() {
    debugPrint('🛑 Stopping ping timer...');
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _sendRaw(Map<String, dynamic> map) {
    if (!_isConnected || _socket == null) {
      debugPrint('⚠️ Tried to send data while disconnected: $map');
      return;
    }
    final jsonMsg = jsonEncode(map);
    _socket!.add(jsonMsg);
    debugPrint('📤 Sent: $jsonMsg');
  }


  /// ✅ Send chat message
  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || !_isConnected) {
      debugPrint('⚠️ Cannot send empty or disconnected message.');
      return;
    }

    // 🔹 Convert everything to String before sending
    final payload = {
      "action": "send",
      "room_id": _roomId.toString(),
      "sender_id": _myUserId.toString(),
      "receiver_id": widget.astrologerUid.toString(),
      "content": text.toString(),
    };

    try {
      // 🔹 Convert to JSON and send directly (avoid type conflicts)
      _socket?.add(jsonEncode(payload));

      // 🧠 Update UI instantly
      setState(() {
        _messages.add({
          "sender_id": _myUserId,
          "message": text,
          "created_at": DateTime.now().toIso8601String(),
        });
        _controller.clear();
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Failed to send message: $e');
    }
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _stopPing();
    _socket?.close();
    _controller.dispose();
    _scrollController.dispose();
    _reconnectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isConnected ? 'Chat (Online)' : 'Chat (Offline)'),
        backgroundColor: Colors.deepPurple,
        actions: [
          Icon(
            _isConnected ? Icons.circle : Icons.circle_outlined,
            color: _isConnected ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMine =
                    msg['sender_id']?.toString() == _myUserId;

                return Align(
                  alignment: isMine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 5, horizontal: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMine
                          ? Colors.deepPurpleAccent.withOpacity(0.8)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['message'] ?? msg['content'] ?? '',
                      style: TextStyle(
                        color: isMine ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInputBox(),
        ],
      ),
    );
  }

  Widget _buildInputBox() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey.shade100,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.deepPurple),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
