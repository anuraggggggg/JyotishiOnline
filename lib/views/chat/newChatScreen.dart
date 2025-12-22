import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../fastApi/fastApiServices.dart';

class CustomerChatPage extends StatefulWidget {
  final String astrologerUserId;
  final String astrologerProfileId;
  final String roomId;
  final String myUserId;
  final String astrologerName;
  final String? token;

  const CustomerChatPage({
    super.key,
    required this.astrologerUserId,
    required this.astrologerProfileId,
    required this.roomId,
    required this.myUserId,
    required this.astrologerName,
    this.token,
  });

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
  bool _manuallyClosed = false;
  bool _isCharged = false;

  final List<Map<String, dynamic>> _messages = [];

  Timer? _reconnectTimer;
  Timer? _sessionTimer;

  static const int _totalSessionSeconds = 600;
  int _secondsLeft = _totalSessionSeconds;
  bool _timerStarted = false;

  late String _myUserId;
  late String _roomId;
  String? _token;

  String? _displayName;
  String? _profileImageUrl;
  double _chatRate = 0;

  int _retries = 0;

  // 🔥 Pagination state
  int _historyPage = 1;
  bool _hasMoreHistory = true;
  bool _loadingHistory = false;
  static const int _pageSize = 50;

  static const Color appYellow = Color(0xFFFFC31F);
  static const Color appDark = Color(0xFF1A1A1A);
  static const Color appLight = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _displayName = widget.astrologerName;
    _initialize();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.minScrollExtent &&
          !_loadingHistory &&
          _hasMoreHistory) {
        _loadOlderMessages();
      }
    });
  }

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _myUserId = widget.myUserId.trim();
    _roomId = widget.roomId.trim();
    _token = widget.token ?? prefs.getString('access_token');

    if (_myUserId.isEmpty || _roomId.isEmpty || _token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid chat session')),
        );
        Navigator.pop(context);
      }
      return;
    }

    try {
      final astro =
      await _api.fetchAstrologerDetail(widget.astrologerProfileId);

      if (mounted) {
        setState(() {
          _displayName = astro.name;
          _profileImageUrl = astro.profileImage;
          _chatRate = (astro.chatCharge ?? 0).toDouble();
        });
      }

      await _deductBalance();

      final history = await _loadFullChatHistory();

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(history);
          _isLoading = false;
        });
        _scrollToBottom(force: true);
      }
    } catch (e) {
      debugPrint("❌ Init error: $e");
      if (mounted) setState(() => _isLoading = false);
    }

    _connectWebSocket();
  }

  // ---------------------------------------------------------------------------
  // FULL HISTORY (ALL PAGES)
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> _loadFullChatHistory() async {
    final List<Map<String, dynamic>> all = [];
    int page = 1;
    bool hasMore = true;

    while (hasMore) {
      final batch = await _api.getChatHistory(
        widget.astrologerUserId,
        page: page,
        size: _pageSize,
      );

      if (batch.isEmpty) {
        hasMore = false;
      } else {
        for (final msg in batch) {
          all.add({
            'sender_id': msg.senderId,
            'message': msg.content.toString(),
            'created_at': msg.createdAt.toIso8601String(),
          });
        }
        page++;
      }
    }

    _historyPage = page - 1;
    return all;
  }

  Future<void> _loadOlderMessages() async {
    if (_loadingHistory || !_hasMoreHistory) return;
    _loadingHistory = true;

    try {
      final batch = await _api.getChatHistory(
        widget.astrologerUserId,
        page: _historyPage + 1,
        size: _pageSize,
      );

      if (batch.isEmpty) {
        _hasMoreHistory = false;
      } else {
        _historyPage++;
        setState(() {
          _messages.insertAll(
            0,
            batch.map((msg) =>
            {
              'sender_id': msg.senderId,
              'message': msg.content.toString(),
              'created_at': msg.createdAt.toIso8601String(),
            }),
          );
        });
      }
    } catch (_) {}
    _loadingHistory = false;
  }

  // ---------------------------------------------------------------------------
  // MONEY DEDUCTION
  // ---------------------------------------------------------------------------

  Future<void> _deductBalance() async {
    if (_isCharged || _chatRate <= 0) return;
    _isCharged = true;

    try {
      await _api.sendMoney(
        astrologerId: widget.astrologerProfileId,
        amount: _chatRate,
        type: "chat",
      );
    } catch (_) {
      _isCharged = false;
    }
  }

  // ---------------------------------------------------------------------------
  // WEBSOCKET
  // ---------------------------------------------------------------------------

  Future<void> _connectWebSocket() async {
    if (_socket != null || _manuallyClosed) return;

    final wsUrl =
        "wss://fastapi.jyotishionline.com/chat/ws/$_roomId?token=$_token&user_id=$_myUserId&role=customer";

    try {
      final socket = await WebSocket.connect(wsUrl);

      if (!mounted || _manuallyClosed) {
        socket.close();
        return;
      }

      _socket = socket;
      _socket!.pingInterval = const Duration(seconds: 20);
      _retries = 0;

      setState(() => _isConnected = true);

      _socket!.listen(
        _handleIncomingMessage,
        onDone: _handleDisconnect,
        onError: (_) => _handleDisconnect(),
      );
    } catch (_) {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    if (_manuallyClosed) return;
    _socket = null;
    if (mounted) setState(() => _isConnected = false);

    if (_retries >= 5) return;
    final delay = [2, 4, 8, 16, 30][_retries++];
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delay), _connectWebSocket);
  }

  void _handleIncomingMessage(dynamic data) {
    try {
      final raw = data is String ? data : utf8.decode(data as List<int>);
      final parsed = jsonDecode(raw);
      if (parsed['type'] != 'message') return;

      final msg = parsed['message'];
      if (msg == null) return;

      final senderId = msg['sender_user_id'];
      if (senderId == _myUserId) return;

      setState(() {
        _messages.add({
          'sender_id': senderId,
          'message': msg['content'],
          'created_at': msg['created_at'] ??
              DateTime.now().toIso8601String(),
        });
      });

      _scrollToBottom();
    } catch (_) {}
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || !_isConnected || _socket == null) return;

    _socket!.add(jsonEncode({
      'action': 'send',
      'room_id': _roomId,
      'sender_id': _myUserId,
      'receiver_id': widget.astrologerUserId,
      'content': text,
    }));

    setState(() {
      _messages.add({
        'sender_id': _myUserId,
        'message': text,
        'created_at': DateTime.now().toIso8601String(),
      });
      _controller.clear();
    });

    _scrollToBottom(force: true);
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  void _scrollToBottom({bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (force) {
        _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent);
      } else {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String iso) {
    try {
      return DateFormat('h:mm a').format(DateTime.parse(iso));
    } catch (_) {
      return '';
    }
  }

  @override
  void dispose() {
    _manuallyClosed = true;
    _socket?.close();
    _reconnectTimer?.cancel();
    _sessionTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI (UNCHANGED)
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final imageUrl = buildImageUrl(_profileImageUrl);
    return Scaffold(
      backgroundColor: appLight,


      appBar: AppBar(
        backgroundColor: appDark,
        elevation: 3,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: appYellow,
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : null,
              child: imageUrl.isEmpty
                  ? const Icon(Icons.person,
                  color: appDark, size: 20)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _displayName ?? widget.astrologerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),


      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: appYellow))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isMine =
                    m['sender_id'] == _myUserId;
                return _buildMessageBubble(m, isMine);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> m, bool isMine) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment:
        isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMine ? appYellow : Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(m['message']),
            ),
            Text(
              _formatTime(m['created_at']),
              style:
              const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: appLight,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: const CircleAvatar(
              backgroundColor: appYellow,
              child: Icon(Icons.send, color: appDark),
            ),
          ),
        ],
      ),
    );
  }

  String buildImageUrl(String? rawPath) {
    if (rawPath == null) return '';

    final cleaned = rawPath
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .replaceAll(RegExp(r'\s+'), '');

    if (cleaned.isEmpty || cleaned.toLowerCase().contains('null')) {
      return '';
    }

    // ❌ file:///static/uploads → FIX
    if (cleaned.startsWith('file://')) {
      final path = cleaned.replaceFirst('file://', '');
      return 'https://fastapi.jyotishionline.com$path';
    }

    if (cleaned.startsWith('http')) {
      return cleaned;
    }

    return 'https://fastapi.jyotishionline.com${cleaned.startsWith('/')
        ? cleaned
        : '/$cleaned'}';
  }
}
