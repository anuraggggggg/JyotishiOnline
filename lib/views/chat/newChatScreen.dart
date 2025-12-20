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
  bool _isCharged = false; // Flag to prevent double charging

  final List<Map<String, dynamic>> _messages = [];

  Timer? _reconnectTimer;
  Timer? _sessionTimer;

  static const int _totalSessionSeconds = 600;
  int _secondsLeft = _totalSessionSeconds;
  bool _timerStarted = false;

  late String _myUserId;
  late String _roomId;
  String? _token;

  // Dynamic Astrologer Data
  String? _displayName;
  String? _profileImageUrl;
  double _chatRate = 0; // Stores the rate from API

  int _retries = 0;

  static const Color appYellow = Color(0xFFFFC31F);
  static const Color appDark = Color(0xFF1A1A1A);
  static const Color appLight = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _displayName = widget.astrologerName;
    _initialize();
  }

  // ---------------------------------------------------------------------------
  // INIT LOGIC (Now matching AudioCallPage bootstrap style)
  // ---------------------------------------------------------------------------

  Future<void> _initialize() async {
    debugPrint("🚀 [ChatInit] Starting Initialization...");
    final prefs = await SharedPreferences.getInstance();

    _myUserId = widget.myUserId.trim();
    _roomId = widget.roomId.trim();
    _token = widget.token ?? prefs.getString('access_token');

    if (_myUserId.isEmpty || _roomId.isEmpty || _token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid chat session. Please login again.')),
        );
        Navigator.pop(context);
      }
      return;
    }

    try {
      // 1. Fetch Astrologer Details FIRST to get the Charge
      final astro = await _api.fetchAstrologerDetail(widget.astrologerProfileId);

      if (mounted) {
        setState(() {
          _displayName = astro.name;
          _profileImageUrl = astro.profileImage;
          // Extract chatCharge from the same response
          _chatRate = (astro.chatCharge ?? 0).toDouble();
        });
      }

      // 🔥 2. CHARGE USER IMMEDIATELY (Exactly like AudioCallPage)
      await _deductBalance();

      // 3. Fetch History and connect Socket
      final history = await _api.getChatHistory(widget.astrologerUserId);

      if (mounted) {
        setState(() {
          _messages.clear();
          for (final msg in history) {
            _messages.add({
              'sender_id': msg.senderId,
              'message': msg.content.toString(),
              'created_at': msg.createdAt.toIso8601String(),
            });
          }
          _isLoading = false;
        });
        _scrollToBottom(force: true);
      }
    } catch (e) {
      debugPrint("⚠️ Initialization error: $e");
      if (mounted) setState(() => _isLoading = false);
    }

    // 4. Connect WebSocket
    _connectWebSocket();
  }

  // -------------------------------------------------------------------
  // DEDUCTION LOGIC (Money deducts as user enters)
  // -------------------------------------------------------------------
  Future<void> _deductBalance() async {
    if (_isCharged || _chatRate <= 0) return;
    _isCharged = true;

    try {
      debugPrint("💰 Upfront Chat Deduction: ₹$_chatRate for Astro: ${widget.astrologerProfileId}");
      await _api.sendMoney(
        astrologerId: widget.astrologerProfileId,
        amount: _chatRate,
        type: "chat",
      ).timeout(const Duration(seconds: 12));

      debugPrint("✅ Chat deduction successful");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("₹$_chatRate deducted for the session start"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Chat deduction failed: $e");
      _isCharged = false; // Allow retry if necessary
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Payment failed: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
        // Optional: Close screen if payment is mandatory
        // Navigator.pop(context);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // WEBSOCKET & MESSAGING
  // ---------------------------------------------------------------------------

  Future<void> _connectWebSocket() async {
    if (_socket != null || _manuallyClosed) return;

    final wsUrl = "wss://fastapi.jyotishionline.com/chat/ws/$_roomId"
        "?token=$_token&user_id=$_myUserId&role=customer"
        "&v=${DateTime.now().millisecondsSinceEpoch}";

    debugPrint("🔗 [WS] Connecting: $wsUrl");

    try {
      final socket = await WebSocket.connect(wsUrl).timeout(const Duration(seconds: 10));

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
        onError: (err) {
          debugPrint("WS Error: $err");
          _handleDisconnect();
        },
      );
    } catch (e) {
      debugPrint("💥 [WS] Connection Error: $e");
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    if (_manuallyClosed) return;
    _socket = null;
    if (mounted) setState(() => _isConnected = false);

    if (_retries >= 5) {
      debugPrint("🚫 [WS] Max retries reached.");
      return;
    }

    final delay = [2, 4, 8, 16, 30][_retries++];
    debugPrint("🔄 [WS] Retrying in $delay seconds...");
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delay), _connectWebSocket);
  }

  void _handleIncomingMessage(dynamic data) {
    try {
      final raw = data is String ? data : utf8.decode(data as List<int>);
      final parsed = jsonDecode(raw);
      if (parsed['type'] != 'message' || parsed['message'] == null) return;

      final msg = parsed['message'] as Map<String, dynamic>;
      final senderId = msg['sender_user_id'];
      final content = msg['content'];

      if (senderId == null || content == null || senderId == _myUserId) return;

      setState(() {
        _messages.add({
          'sender_id': senderId,
          'message': content.toString(),
          'created_at': msg['created_at'] ?? DateTime.now().toIso8601String(),
        });
      });

      if (!_timerStarted && senderId == widget.astrologerUserId) {
        _startTimer();
      }
      _scrollToBottom();
    } catch (e) {
      debugPrint("❌ WS parse error: $e");
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || !_isConnected || _socket == null) return;

    final payload = {
      'action': 'send',
      'room_id': _roomId,
      'sender_id': _myUserId,
      'receiver_id': widget.astrologerUserId,
      'content': text,
    };

    _socket!.add(jsonEncode(payload));

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
  // TIMER & SCROLLING
  // ---------------------------------------------------------------------------

  void _startTimer() {
    if (_timerStarted) return;
    _timerStarted = true;
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _secondsLeft--);
        if (_secondsLeft <= 0) {
          timer.cancel();
          _endSession();
        }
      }
    });
  }

  void _endSession() {
    _manuallyClosed = true;
    _socket?.close();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Session Ended")));
      Navigator.pop(context);
    }
  }

  void _scrollToBottom({bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (force) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
  // HELPERS & UI
  // ---------------------------------------------------------------------------

  String buildImageUrl(String? rawPath) {
    if (rawPath == null || rawPath.isEmpty || rawPath.toLowerCase().contains('null')) return '';
    final cleaned = rawPath.replaceAll('\n', '').replaceAll('\r', '').replaceAll(RegExp(r'\s+'), '');
    if (cleaned.startsWith('http')) return cleaned;
    return 'https://fastapi.jyotishionline.com${cleaned.startsWith('/') ? cleaned : '/$cleaned'}';
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('h:mm a').format(dt);
    } catch (e) {
      return '';
    }
  }

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
              backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl.isEmpty ? const Icon(Icons.person, color: appDark, size: 20) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayName ?? widget.astrologerName,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _isConnected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isConnected ? 'Online' : 'Connecting...',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_timerStarted)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: appYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: appYellow),
                ),
                child: Text(
                  '${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: appYellow),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: appYellow))
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
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isMine ? appYellow : Colors.white,
                borderRadius: BorderRadius.circular(15).copyWith(
                  bottomRight: isMine ? const Radius.circular(0) : null,
                  bottomLeft: !isMine ? const Radius.circular(0) : null,
                ),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Text(
                m['message'],
                style: TextStyle(color: isMine ? appDark : Colors.black87, fontSize: 15),
              ),
            ),
            const SizedBox(height: 2),
            Text(_formatTime(m['created_at']), style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 10,
          bottom: MediaQuery.of(context).padding.bottom + 10
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor: appLight,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: const CircleAvatar(
              backgroundColor: appYellow,
              radius: 22,
              child: Icon(Icons.send, color: appDark, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}