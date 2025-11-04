import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fastApi/fastapiservices.dart';
import '../../model/fastApiModel/newChatModel.dart';

class CustomerChatPage extends StatefulWidget {
  final String astrologerUid;
  final String roomId;          // required
  final String myUserId;        // required
  final String astrologerName;  // required
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
  // --- Services / controllers
  final FastAPIServices _api = FastAPIServices();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // --- Session
  WebSocket? _socket;
  bool _isConnected = false;
  bool _isLoading = true;

  // --- Data
  final List<Map<String, dynamic>> _messages = <Map<String, dynamic>>[];

  // --- Pagination
  static const int _pageSize = 20;
  int _currentPage = 1;
  bool _isFetchingMore = false;
  bool _hasMore = true;

  // --- Realtime / background
  Timer? _reconnectTimer;
  Timer? _pollTimer;
  bool _isPolling = false;
  int _retries = 0;
  int _seq = 0;

  // --- IDs for dedupe
  final Set<String> _clientSeqSeen = <String>{};       // client_sequence_id
  final Map<String, int> _clientSeqIndex = {};         // client_sequence_id → index in _messages
  final Set<String> _historyIdsSeen = <String>{};      // server-side message ids (if provided)

  // --- Misc
  late String _myUserId;
  late String _roomId;
  String? _token;
  DateTime? _latestSeenAt;

  // --- Debug HUD
  int _wsFrameCount = 0;
  String _lastWsRaw = '';

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
    debugPrint('✅ token: ${_token != null ? "LOADED" : "null"}');
    debugPrint('✅ roomId: $_roomId');

    if (_myUserId.isEmpty || _roomId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missing session details. Please try again.')),
        );
      }
      return;
    }

    await _loadChatHistory(); // initial history
    if (!mounted) return;

    setState(() => _isLoading = false);
    _connectWebSocket();
    _startPolling(); // safety net while WS connects
  }

  // ---------------------------------------------------------------------------
  // History & Polling
  // ---------------------------------------------------------------------------

  Future<void> _loadChatHistory({bool loadMore = false}) async {
    if (_isFetchingMore || (!_hasMore && loadMore)) return;
    _isFetchingMore = true;

    try {
      final allMessages = await _api.getChatHistory(widget.astrologerUid);
      if (allMessages.isEmpty) {
        setState(() => _hasMore = false);
        return;
      }

      // paginate locally
      final totalMessages = allMessages.length;
      final totalPages = (totalMessages / _pageSize).ceil();

      if (!loadMore) _currentPage = totalPages;

      final startIndex =
      (totalMessages - _currentPage * _pageSize).clamp(0, totalMessages);
      final endIndex = (startIndex + _pageSize).clamp(0, totalMessages);
      final chunk = allMessages.sublist(startIndex, endIndex);

      if (chunk.isEmpty) {
        setState(() => _hasMore = false);
        return;
      }

      // map to local shape (+potential server id)
      final formatted = chunk.map((msg) {
        final createdIso = msg.createdAt.toIso8601String();
        return <String, dynamic>{
          'sender_id': msg.senderId?.toString() ?? '',
          'message'  : msg.content?.toString() ?? '',
          'created_at': createdIso,
          if (msg.id != null) 'server_id': msg.id.toString(),
        };
      }).toList();

      if (loadMore) {
        final oldOffset = _scrollController.offset;
        final oldMax = _scrollController.position.maxScrollExtent;

        setState(() {
          for (final m in formatted) {
            _addMessageIfNew(m);
          }
          _messages.sort((a, b) =>
              (DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0))
                  .compareTo(DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0)));
          _currentPage--;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final newMax = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(newMax - oldMax + oldOffset);
        });
      } else {
        final fresh = <Map<String, dynamic>>[];
        for (final m in formatted) {
          if (_addMessageIfNew(m)) fresh.add(m);
        }
        setState(() {
          _messages
            ..clear()
            ..addAll(fresh);
        });
        _maybeScrollToBottom(force: true);
      }

      if (_currentPage <= 1) {
        setState(() => _hasMore = false);
      }
    } catch (e, st) {
      debugPrint('❌ Error loading chat history: $e\n$st');
    } finally {
      _isFetchingMore = false;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    if (_isConnected) return; // don’t poll if WS is up
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) => _pollForUpdates());
  }

  Future<void> _pollForUpdates() async {
    if (_isPolling || _isConnected) return;
    _isPolling = true;
    try {
      final all = await _api.getChatHistory(widget.astrologerUid);
      if (all.isEmpty) return;

      final candidates = all.map((msg) {
        final id = msg.id?.toString();
        if (id != null && _historyIdsSeen.contains(id)) {
          return <String, dynamic>{}; // already seen
        }
        return <String, dynamic>{
          'sender_id' : msg.senderId?.toString() ?? '',
          'message'   : msg.content?.toString() ?? '',
          'created_at': msg.createdAt.toIso8601String(),
          if (id != null) 'server_id': id,
        };
      }).where((m) => m.isNotEmpty).toList();

      candidates.sort((a, b) {
        final ta = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0);
        final tb = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0);
        return ta.compareTo(tb);
      });

      bool added = false;
      for (final m in candidates) {
        if (_addMessageIfNew(m)) added = true;
      }

      if (added && mounted) {
        setState(() {});
        _maybeScrollToBottom();
      }
    } catch (e, st) {
      debugPrint('⚠️ Poll failed: $e\n$st');
    } finally {
      _isPolling = false;
    }
  }

  // ---------------------------------------------------------------------------
  // WebSocket
  // ---------------------------------------------------------------------------

  Future<void> _connectWebSocket() async {
    if (_socket != null) return;

    final prefs = await SharedPreferences.getInstance();
    _token = _token ?? prefs.getString('accessToken');

    final wsUrl = Uri(
      scheme: 'wss',
      host: 'fastapi.jyotishionline.com',
      path: '/chat/ws/$_roomId',
      queryParameters: {
        if (_token != null && _token!.isNotEmpty) 'token': _token!,
        'user_id': _myUserId,
        'role': 'customer',
      },
    );

    debugPrint('🌐 Connecting WS: $wsUrl');

    try {
      final socket = await WebSocket.connect(wsUrl.toString());
      if (!mounted) {
        socket.close();
        return;
      }
      _socket = socket;
      _socket!.pingInterval = const Duration(seconds: 20);

      _retries = 0;
      setState(() => _isConnected = true);
      debugPrint('✅ WebSocket connected');

      // stop polling now that we are online
      _pollTimer?.cancel();

      // join room
      _sendRaw({
        "action": "join",
        "type": "join",
        "event": "subscribe",
        "room": _roomId,
        "room_id": _roomId,
        "user_id": _myUserId,
        "sender_id": _myUserId,
        "receiver_id": widget.astrologerUid,
        "role": "customer",
        "token": _token,
      });

      _socket!.listen(
            (data) {
          try {
            _wsFrameCount++;
            _lastWsRaw = data is String ? data : utf8.decode(data as List<int>);
            debugPrint('⬅️ WS #$_wsFrameCount: $_lastWsRaw');
          } catch (_) {}
          _handleIncomingMessage(data);
        },
        onDone: _handleDisconnect,
        onError: (error, st) {
          debugPrint('⚠️ WebSocket error: $error');
          _handleDisconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('❌ WS connect failed: $e');
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    debugPrint('❌ WS disconnected');
    if (mounted) setState(() => _isConnected = false);
    try { _socket?.close(); } catch (_) {}
    _socket = null;
    _startPolling(); // poll while trying to reconnect
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!mounted) return;
    if (_reconnectTimer?.isActive ?? false) return;
    final delaySecs = [2, 5, 10, 20, 30][_retries.clamp(0, 4)];
    debugPrint('🔁 Reconnect in $delaySecs s (attempt ${_retries + 1})…');
    _reconnectTimer = Timer(Duration(seconds: delaySecs), () {
      _retries++;
      _connectWebSocket();
    });
  }

  // ---------------------------------------------------------------------------
  // Message extraction / dedupe core
  // ---------------------------------------------------------------------------

  String? _extractClientSeqId(Map<String, dynamic> map) {
    for (final k in const [
      'client_sequence_id', 'client_seq', 'cid', 'clientId', 'client_id'
    ]) {
      final v = map[k];
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    for (final k in const ['message_obj', 'data', 'payload']) {
      final v = map[k];
      if (v is Map) {
        final nested = _extractClientSeqId(Map<String, dynamic>.from(v));
        if (nested != null) return nested;
      }
    }
    return null;
  }

  Map<String, dynamic>? _extractMessage(dynamic node) {
    if (node == null) return null;
    if (node is String) return null;

    if (node is List) {
      for (final item in node) {
        final found = _extractMessage(item);
        if (found != null) return found;
      }
      return null;
    }

    if (node is Map) {
      final map = Map<String, dynamic>.from(node);
      final content = (map['content'] ?? map['message'] ?? map['text'] ?? map['body']);
      if (content != null && content.toString().trim().isNotEmpty) {
        final created = (map['created_at'] ?? map['timestamp'] ?? map['time'])?.toString()
            ?? DateTime.now().toIso8601String();
        final out = <String, dynamic>{
          'sender_id' : (map['sender_id'] ?? map['user_id'] ?? map['from'] ?? '').toString(),
          'message'   : content.toString(),
          'created_at': created,
        };
        final cid = _extractClientSeqId(map);
        if (cid != null) out['client_sequence_id'] = cid;
        if (map['id'] != null) out['server_id'] = map['id'].toString();
        return out;
      }

      for (final k in const ['message', 'data', 'payload', 'detail', 'result', 'message_obj', 'event', 'record', 'value']) {
        if (map.containsKey(k)) {
          final found = _extractMessage(map[k]);
          if (found != null) return found;
        }
      }
    }
    return null;
  }

  void _handleIncomingMessage(dynamic data) {
    try {
      final raw = data is String ? data : utf8.decode(data as List<int>);
      final parsed = jsonDecode(raw);

      final msg = _extractMessage(parsed);
      if (msg == null) {
        if (parsed is Map && (parsed['type'] == 'pong' || parsed['type'] == 'ping')) return;
        if (parsed is Map && (parsed['action'] == 'join' || parsed['event'] == 'joined')) return;
        debugPrint('ℹ️ WS frame had no message content, ignored.');
        return;
      }

      if (_addMessageIfNew(msg) && mounted) {
        setState(() {});
        _maybeScrollToBottom();
      }
    } catch (e, st) {
      debugPrint('❌ Failed to decode WS message: $e\n$st\ndata=$data');
    }
  }

  bool _addMessageIfNew(Map<String, dynamic> m) {
    final cid = (m['client_sequence_id'] ?? '').toString();
    final sid = (m['server_id'] ?? '').toString();

    // Replace optimistic bubble if same client id
    if (cid.isNotEmpty) {
      if (_clientSeqSeen.contains(cid)) {
        final idx = _clientSeqIndex[cid];
        if (idx != null && idx >= 0 && idx < _messages.length) {
          _messages[idx]['created_at'] = m['created_at'] ?? _messages[idx]['created_at'];
          if (sid.isNotEmpty) _messages[idx]['server_id'] = sid;
          return false;
        }
        return false;
      }
    }

    // Skip if server id already known (history/poll)
    if (sid.isNotEmpty && _historyIdsSeen.contains(sid)) {
      return false;
    }

    // Fallback dedupe: same sender+text within 2s window
    final s = (m['sender_id'] ?? '').toString();
    final c = (m['message'] ?? '').toString().trim();
    final t = DateTime.tryParse((m['created_at'] ?? '').toString()) ?? DateTime.now();

    for (var i = _messages.length - 1; i >= 0 && i >= _messages.length - 20; i--) {
      final mm = _messages[i];
      final ms = (mm['sender_id'] ?? '').toString();
      final mc = (mm['message'] ?? '').toString().trim();
      final mt = DateTime.tryParse((mm['created_at'] ?? '').toString()) ?? DateTime(0);
      if (ms == s && mc == c && (t.difference(mt).inMilliseconds).abs() <= 2000) {
        return false;
      }
    }

    final addedIndex = _messages.length;
    _messages.add(m);

    if (cid.isNotEmpty) {
      _clientSeqSeen.add(cid);
      _clientSeqIndex[cid] = addedIndex;
    }
    if (sid.isNotEmpty) {
      _historyIdsSeen.add(sid);
    }

    _updateLatestSeenAt(m['created_at']);
    return true;
  }

  void _updateLatestSeenAt(String? iso) {
    if (iso == null) return;
    final dt = DateTime.tryParse(iso);
    if (dt == null) return;
    if (_latestSeenAt == null || dt.isAfter(_latestSeenAt!)) {
      _latestSeenAt = dt;
    }
  }

  // ---------------------------------------------------------------------------
  // Send
  // ---------------------------------------------------------------------------

  void _sendRaw(Map<String, dynamic> map) {
    if (!_isConnected || _socket == null) {
      debugPrint('🚫 _sendRaw while disconnected');
      return;
    }
    try {
      _socket!.add(jsonEncode(Map<String, dynamic>.from(map)));
    } catch (e, st) {
      debugPrint('❌ _sendRaw failed: $e\n$st\npayload=$map');
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (!_isConnected || _socket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecting… please wait')),
      );
      _connectWebSocket();
      return;
    }

    final clientId = 'c:${_myUserId}:${DateTime.now().millisecondsSinceEpoch}:${_seq++}';

    final payload = {
      "action": "send",
      "type": "message",
      "event": "message",
      "room": _roomId,
      "room_id": _roomId,
      "sender_id": _myUserId,
      "user_id": _myUserId,
      "receiver_id": widget.astrologerUid,
      "role": "customer",
      "content": text,
      "message": text,
      "client_sequence_id": clientId,
      "message_obj": {
        "room_id": _roomId,
        "sender_id": _myUserId,
        "receiver_id": widget.astrologerUid,
        "role": "customer",
        "content": text,
        "client_sequence_id": clientId,
        "created_at": DateTime.now().toIso8601String(),
        "token": _token,
      }
    };

    debugPrint('➡️ WS SEND: ${jsonEncode(payload)}');
    _sendRaw(payload);

    // optimistic bubble with the same client_sequence_id
    final local = <String, dynamic>{
      "sender_id": _myUserId,
      "message": text,
      "created_at": DateTime.now().toIso8601String(),
      "client_sequence_id": clientId,
    };
    _addMessageIfNew(local);

    setState(() {
      _controller.clear();
    });
    _maybeScrollToBottom(force: true);
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

  void _maybeScrollToBottom({bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final atBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 80;
      if (force || atBottom) {
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
    try { _socket?.close(); } catch (_) {}
    _reconnectTimer?.cancel();
    _pollTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

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
                      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
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

                // Tiny debug HUD (long-press to copy last WS frame)
                // Positioned(
                //   right: 8,
                //   bottom: 64,
                //   child: GestureDetector(
                //     onLongPress: () {
                //       Clipboard.setData(ClipboardData(text: _lastWsRaw));
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         const SnackBar(content: Text('Copied last WS frame')),
                //       );
                //     },
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //       decoration: BoxDecoration(
                //         color: Colors.black54,
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //       child: Text(
                //         'WS:${_isConnected ? "✓" : "×"} #$_wsFrameCount',
                //         style: const TextStyle(color: Colors.white, fontSize: 12),
                //       ),
                //     ),
                //   ),
                // ),
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
                onSubmitted: (_) {
                  if (canSend) {
                    _sendMessage();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Connecting… please wait')),
                    );
                  }
                },
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
