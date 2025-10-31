import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../fastApi/fastapiservices.dart';
import '../../model/fastApiModel/newChatModel.dart';

class CustomerChatPage extends StatefulWidget {
  final String astrologerUid;
  final String roomId;          // required & non-null
  final String myUserId;        // required & non-null
  final String astrologerName;  // required & non-null
  final String? token;          // optional

  const CustomerChatPage({
    Key? key,
    required this.astrologerUid,
    required this.roomId,
    required this.myUserId,
    required this.astrologerName,
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
  List<Map<String, dynamic>> _messages = <Map<String, dynamic>>[];
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  late String _myUserId; // from constructor
  late String _roomId;   // from constructor
  String? _token;

  // Pagination
  static const int _pageSize = 20;
  int _currentPage = 1;
  bool _isFetchingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _initializeUserData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent + 100 &&
          !_isFetchingMore &&
          _hasMore) {
        debugPrint('⬆️ Reached top — loading older messages...');
        _loadChatHistory(loadMore: true);
      }
    });
  }

  Future<void> _initializeUserData() async {
    debugPrint('🧠 Loading stored user data / wiring params...');
    final prefs = await SharedPreferences.getInstance();

    _myUserId = widget.myUserId;
    _roomId = widget.roomId;
    _token = widget.token ?? prefs.getString('accessToken');

    debugPrint('✅ userId: $_myUserId');
    debugPrint('✅ token: $_token');
    debugPrint('✅ roomId: $_roomId');

    if (_myUserId.isEmpty || _roomId.isEmpty) {
      debugPrint('⚠️ Missing required navigation payload (userId/roomId).');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing session details. Please try again.')),
        );
      }
      return;
    }

    await _loadChatHistory();
    if (!mounted) return;
    setState(() => _isLoading = false);
    _connectWebSocket();
  }

  /// Fetch chat history (client-side pagination)
  Future<void> _loadChatHistory({bool loadMore = false}) async {
    if (_isFetchingMore || (!_hasMore && loadMore)) return;
    _isFetchingMore = true;

    try {
      final allMessages = await _api.getChatHistory(widget.astrologerUid);
      if (allMessages.isEmpty) {
        setState(() => _hasMore = false);
        return;
      }

      final totalMessages = allMessages.length;
      final totalPages = (totalMessages / _pageSize).ceil();

      if (!loadMore) _currentPage = totalPages;

      final startIndex =
      (totalMessages - _currentPage * _pageSize).clamp(0, totalMessages);
      final endIndex = (startIndex + _pageSize).clamp(0, totalMessages);
      final newChunk = allMessages.sublist(startIndex, endIndex);

      if (newChunk.isEmpty) {
        setState(() => _hasMore = false);
        return;
      }

      // 🔑 Force the element type to Map<String, dynamic>
      final List<Map<String, dynamic>> formatted = newChunk
          .map<Map<String, dynamic>>((msg) => <String, dynamic>{
        'sender_id': msg.senderId?.toString() ?? '',
        'message': msg.content?.toString() ?? '',
        'created_at': msg.createdAt.toIso8601String(),
      })
          .toList();

      if (loadMore) {
        final oldOffset = _scrollController.offset;
        final oldMaxExtent = _scrollController.position.maxScrollExtent;

        setState(() {
          _messages.insertAll(0, List<Map<String, dynamic>>.from(formatted));
          _currentPage--;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final newMaxExtent = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(newMaxExtent - oldMaxExtent + oldOffset);
        });
      } else {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(formatted);
        });
        _scrollToBottom();
      }

      if (_currentPage <= 1) {
        setState(() => _hasMore = false);
      }
    } catch (e, st) {
      debugPrint('❌ Error loading chat history: $e');
      debugPrint('$st');
    } finally {
      _isFetchingMore = false;
    }
  }

  /// WebSocket connection
  Future<void> _connectWebSocket() async {
    final wsUrl = Uri.parse('wss://fastapi.jyotishionline.com/chat/ws/$_roomId');
    debugPrint('🌐 Connecting to WebSocket: $wsUrl');

    try {
      _socket = await WebSocket.connect(wsUrl.toString());
      if (!mounted) return;
      setState(() => _isConnected = true);
      debugPrint('✅ WebSocket connected');

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
    try {
      final decodedAny = jsonDecode(data);

      // Ignore keep-alives / joins
      if (decodedAny is Map &&
          (decodedAny['type'] == 'pong' || decodedAny['action'] == 'join')) {
        return;
      }

      // Normalize to a Map<String, dynamic>
      final Map<String, dynamic> container =
      (decodedAny is Map) ? Map<String, dynamic>.from(decodedAny) : <String, dynamic>{};

      final Map<String, dynamic> msgMap = container['message'] is Map
          ? Map<String, dynamic>.from(container['message'] as Map)
          : container;

      final String contentStr =
      (msgMap['content'] ?? msgMap['message'] ?? '').toString();
      if (contentStr.isEmpty) return;

      final String senderStr = (msgMap['sender_id'] ?? '').toString();
      final String createdAtStr =
      (msgMap['created_at'] ?? DateTime.now().toIso8601String()).toString();

      setState(() {
        _messages.add(<String, dynamic>{
          'sender_id': senderStr,
          'message': contentStr,
          'created_at': createdAtStr,
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
    if (mounted) setState(() => _isConnected = false);
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
    _pingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _sendRaw({"action": "ping", "ts": DateTime.now().toIso8601String()});
    });
  }

  void _stopPing() => _pingTimer?.cancel();

  // -------- hardened sender utilities --------

  void _sendRaw(Map<String, dynamic> map) {
    if (!_isConnected || _socket == null) return;
    try {
      final normalized = Map<String, dynamic>.from(map);
      final encoded = jsonEncode(normalized); // ALWAYS send String
      _socket!.add(encoded);
      // debugPrint('➡️ WS SEND: $encoded');
    } catch (e, st) {
      debugPrint('❌ _sendRaw failed: $e');
      debugPrint('$st');
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (!_isConnected || _socket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not connected. Trying to reconnect...')),
      );
      _connectWebSocket(); // best effort
      return;
    }

    final Map<String, dynamic> payload = <String, dynamic>{
      "action": "send",
      "room_id": _roomId,
      "sender_id": _myUserId,
      "receiver_id": widget.astrologerUid,
      "content": text,
    };

    try {
      _sendRaw(payload); // goes through hardened path
      setState(() {
        _messages.add(<String, dynamic>{
          "sender_id": _myUserId,
          "message": text,
          "created_at": DateTime.now().toIso8601String(),
        });
        _controller.clear();
      });
      _scrollToBottom();
    } catch (e, st) {
      debugPrint('❌ Failed to send message: $e');
      debugPrint('$st');
    }
  }

  // -------------------------------------------

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
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
    final canSend = _isConnected && _socket != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.astrologerName,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _isConnected ? 'Online' : 'Offline',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
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
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length + (_isFetchingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isFetchingMore && index == 0) {
                      return const Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    final msg = _messages[_isFetchingMore ? index - 1 : index];
                    final isMine = msg['sender_id']?.toString() == _myUserId;

                    return Align(
                      alignment:
                      isMine ? Alignment.centerRight : Alignment.centerLeft,
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
                          (msg['message'] ?? '').toString(),
                          style: TextStyle(
                            color: isMine ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildInputBox(canSend: canSend),
        ],
      ),
    );
  }

  Widget _buildInputBox({required bool canSend}) {
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
              icon: Icon(
                Icons.send,
                color: canSend ? Colors.deepPurple : Colors.grey,
              ),
              onPressed: canSend ? _sendMessage : null,
              tooltip: canSend ? 'Send' : 'Connecting…',
            ),
          ],
        ),
      ),
    );
  }
}
