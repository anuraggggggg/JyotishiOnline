import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // 🔥 Handshake flags
  bool _iAmReady = false;
  bool _otherIsReady = false;
  bool _timerStarted = false;

  // ⏱ Timer (10 min)
  static const int _totalSessionSeconds = 10 * 60;
  int _secondsLeft = _totalSessionSeconds;
  Timer? _sessionTimer;

  final List<Map<String, dynamic>> _messages = [];

  late String _myUserId;
  late String _roomId;
  late String _token;

  String? _displayName;
  double _chatRate = 0;

  // Pagination
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
    _token = widget.token ?? prefs.getString('access_token') ?? '';

    if (_myUserId.isEmpty || _roomId.isEmpty || _token.isEmpty) {
      Navigator.pop(context);
      return;
    }

    try {
      final astro =
      await _api.fetchAstrologerDetail(widget.astrologerProfileId);

      _displayName = astro.name;
      _chatRate = (astro.chatCharge ?? 0).toDouble();

      await _deductBalance();
      await _loadFullChatHistory();
    } catch (_) {}

    setState(() => _isLoading = false);
    _scrollToBottom(force: true);
    _connectWebSocket();
  }

  // ---------------------------------------------------------------------------
  // CHAT HISTORY
  // ---------------------------------------------------------------------------

  Future<void> _loadFullChatHistory() async {
    final List<Map<String, dynamic>> all = [];
    int page = 1;

    while (true) {
      final batch = await _api.getChatHistory(
        widget.astrologerUserId,
        page: page,
        size: _pageSize,
      );

      if (batch.isEmpty) break;

      for (final msg in batch) {
        all.add({
          'sender_id': msg.senderId,
          'message': msg.content,
          'created_at': msg.createdAt.toIso8601String(),
        });
      }
      page++;
    }

    _historyPage = page - 1;
    _messages
      ..clear()
      ..addAll(all);
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
        _messages.insertAll(
          0,
          batch.map((m) => {
            'sender_id': m.senderId,
            'message': m.content,
            'created_at': m.createdAt.toIso8601String(),
          }),
        );
      }
    } catch (_) {}

    _loadingHistory = false;
  }

  // ---------------------------------------------------------------------------
  // MONEY
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

    final uri = Uri(
      scheme: 'wss',
      host: 'fastapi.jyotishionline.com',
      path: '/chat/ws/$_roomId',
      queryParameters: {'token': _token},
    );

    try {
      _socket = await WebSocket.connect(uri.toString());
      _socket!.pingInterval = const Duration(seconds: 20);

      setState(() => _isConnected = true);

      _socket!.listen(
        _onMessage,
        onDone: _handleDisconnect,
        onError: (_) => _handleDisconnect(),
      );

      // 🔥 READY SIGNAL
      _iAmReady = true;
      _socket!.add(jsonEncode({
        "type": "connectivity",
        "status": "ready",
        "user_id": _myUserId,
        "room_id": _roomId,
      }));
    } catch (_) {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _otherIsReady = false;
    _stopSessionTimer();
    if (mounted) setState(() => _isConnected = false);
  }

  void _onMessage(dynamic data) {
    try {
      final raw = data is String ? data : utf8.decode(data);
      final parsed = jsonDecode(raw);

      // 🔥 HANDSHAKE
      if (parsed['type'] == 'connectivity') {
        if (parsed['user_id'] == _myUserId) return;

        if (parsed['status'] == 'ready') {
          _otherIsReady = true;
          _tryStartTimer();
        } else if (parsed['status'] == 'offline') {
          _otherIsReady = false;
          _stopSessionTimer();
        }
        return;
      }

      if (parsed['type'] != 'message') return;

      final msg = parsed['message'];
      if (msg == null) return;

      _otherIsReady = true;
      _tryStartTimer();

      setState(() {
        _messages.add({
          'sender_id': msg['sender_user_id'],
          'message': msg['content'],
          'created_at': msg['created_at'],
        });
      });

      _scrollToBottom();
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // TIMER
  // ---------------------------------------------------------------------------

  void _tryStartTimer() {
    if (_timerStarted) return;
    if (_iAmReady && _otherIsReady && _isConnected) {
      _startSessionTimer();
    }
  }

  void _startSessionTimer() {
    _timerStarted = true;
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 0) {
        _stopSessionTimer();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _timerStarted = false;
  }

  // ---------------------------------------------------------------------------
  // SEND
  // ---------------------------------------------------------------------------

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || !_isConnected || _socket == null) return;

    setState(() {
      _messages.add({
        'sender_id': _myUserId,
        'message': text,
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    _socket!.add(jsonEncode({'content': text}));

    _controller.clear();
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
          _scrollController.position.maxScrollExtent,
        );
      } else {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appLight,
      appBar: AppBar(
        backgroundColor: appDark,
        title: Text(_displayName ?? widget.astrologerName, style: TextStyle(
          color: Colors.white
        ),),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                "${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:"
                    "${(_secondsLeft % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
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
                final isMine = m['sender_id'] == _myUserId;
                return _buildBubble(m, isMine);
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> m, bool isMine) {
    return Align(
      alignment:
      isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMine ? appYellow : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(m['message']),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration:
              const InputDecoration(hintText: "Type message"),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _manuallyClosed = true;
    _socket?.add(jsonEncode({
      "type": "connectivity",
      "status": "offline",
      "user_id": _myUserId,
      "room_id": _roomId,
    }));
    _stopSessionTimer();
    _socket?.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
