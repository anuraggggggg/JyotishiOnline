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

  bool _iAmReady = false;
  bool _otherIsReady = false;
  bool _timerStarted = false;

  static const int _totalSessionSeconds = 10 * 60;
  int _secondsLeft = _totalSessionSeconds;
  Timer? _sessionTimer;

  final List<Map<String, dynamic>> _messages = [];

  late String _myUserId;
  late String _roomId;
  late String _token;

  String? _displayName;
  double _chatRate = 0;

  int _historyPage = 1;
  bool _hasMoreHistory = true;
  bool _loadingHistory = false;
  static const int _pageSize = 50;

  static const Color appYellow = Color(0xFFFFC31F);
  static const Color appDark = Color(0xFF1A1A1A);
  static const Color appLight = Color(0xFFF8F9FA);

  // ---------------------------------------------------------------------------
  // ✅ SIMPLIFIED TEXT DECODING - MAIN FUNCTION
  // ---------------------------------------------------------------------------
  String _decodeMessageContent(dynamic content) {
    if (content == null) return '';

    try {
      String text;

      // Convert to string (your API returns String, not List<int>)
      if (content is String) {
        text = content;
      } else {
        text = content.toString();
      }

      // Fix encoding issues
      return _fixTextEncoding(text);
    } catch (e) {
      debugPrint("Error decoding message: $e");
      return content.toString();
    }
  }

  // ---------------------------------------------------------------------------
  // 🔥 FIX TEXT ENCODING ISSUES (EMOJI, HINDI, OTHER LANGUAGES)
  // ---------------------------------------------------------------------------
  String _fixTextEncoding(String text) {
    if (text.isEmpty) return text;

    String result = text;

    // Step 1: Try to fix double-encoded UTF-8 (most common issue)
    if (_looksLikeDoubleEncoded(result)) {
      result = _tryFixDoubleEncoding(result);
    }

    // Step 2: Fix specific mojibake patterns
    result = _fixCommonMojibake(result);

    // Step 3: Fix Hindi/Devnagari encoding issues
    result = _fixHindiEncoding(result);

    // Step 4: Remove any remaining invalid characters
    result = _removeInvalidCharacters(result);

    return result;
  }

  bool _looksLikeDoubleEncoded(String text) {
    return text.contains('Ã') ||
        text.contains('â') ||
        text.contains('Â') ||
        text.contains('â€') ||
        text.contains('à¤') || // Hindi issue indicator
        text.contains('à¥');    // Hindi issue indicator
  }

  String _tryFixDoubleEncoding(String text) {
    try {
      // Common pattern: Latin-1 interpreted as UTF-8
      final latinBytes = latin1.encode(text);
      final decoded = utf8.decode(latinBytes, allowMalformed: true);

      // Only return if it actually improved
      if (!decoded.contains('�') && decoded != text) {
        return decoded;
      }
    } catch (_) {
      // If that fails, try another approach
    }

    // Try direct fixes for common patterns
    return text;
  }

  String _fixCommonMojibake(String text) {
    String result = text;

    // Comprehensive list of common mojibake fixes
    final fixes = {
      // Quotes and apostrophes
      'â€™': '\'',
      'â€œ': '"',
      'â€': '"',
      'â€˜': '\'',
      'â€¦': '…',
      'â€¢': '•',
      'â€"': '–',
      'â€"': '—',

      // Latin characters with accents
      'Ã¡': 'á',
      'Ã©': 'é',
      'Ã­': 'í',
      'Ã³': 'ó',
      'Ãº': 'ú',
      'Ã±': 'ñ',
      'Ã¼': 'ü',
      'Ã¶': 'ö',
      'Ã¤': 'ä',
      'Ã¥': 'å',
      'Ã¸': 'ø',
      'Ã¦': 'æ',
      'Ã§': 'ç',

      // Uppercase variants
      'Ã': 'Á',
      'Ã‰': 'É',
      'Ã': 'Í',
      'Ã"': 'Ó',
      'Ãš': 'Ú',
      'Ã': 'Ñ',
      'Ã': 'Ü',
      'Ã': 'Ö',
      'Ã': 'Ä',
      'Ã…': 'Å',
      'Ã˜': 'Ø',
      'Ã†': 'Æ',
      'Ã‡': 'Ç',

      // Complex patterns
      'Ã¢â‚¬â„¢': '\'',
      'Ã¢â‚¬â€"': '–',
      'Ã¢â‚¬Å¡': ',',
      'Ã¢â‚¬Å"': '"',
      'Ã¢â‚¬Â¦': '…',
      'Ã¢â‚¬Â¢': '•',
      'Ã¢â‚¬Â': '"',
    };

    fixes.forEach((pattern, replacement) {
      result = result.replaceAll(pattern, replacement);
    });

    return result;
  }

  String _fixHindiEncoding(String text) {
    String result = text;

    // Common Hindi encoding issues when UTF-8 is misinterpreted
    final hindiFixes = {
      'à¤': '', // Remove this prefix that appears before Devnagari chars
      'à¥': '', // Another common prefix
      'à¤•': 'क',
      'à¤–': 'ख',
      'à¤—': 'ग',
      'à¤˜': 'घ',
      'à¤™': 'ङ',
      'à¤š': 'च',
      'à¤›': 'छ',
      'à¤œ': 'ज',
      'à¤ž': 'झ',
      'à¤Ÿ': 'ञ',
      'à¤¤': 'त',
      'à¤¥': 'थ',
      'à¤¦': 'द',
      'à¤§': 'ध',
      'à¤¨': 'न',
      'à¤ª': 'प',
      'à¤«': 'फ',
      'à¤¬': 'ब',
      'à¤­': 'भ',
      'à¤®': 'म',
      'à¤¯': 'य',
      'à¤°': 'र',
      'à¤²': 'ल',
      'à¤µ': 'व',
      'à¤¶': 'श',
      'à¤·': 'ष',
      'à¤¸': 'स',
      'à¤¹': 'ह',
      'à¤¾': 'ा',
      'à¤¿': 'ि',
      'à€€': 'ी',
      'à¤‚': 'ं',
      'à¤ƒ': 'ः',
    };

    hindiFixes.forEach((pattern, replacement) {
      result = result.replaceAll(pattern, replacement);
    });

    // Try to decode Hindi text that's been double-encoded
    if (result.contains('à¤') && result.length > 10) {
      try {
        // This is a heuristic for fixing double-encoded Hindi
        final bytes = latin1.encode(result);
        final decoded = utf8.decode(bytes, allowMalformed: true);
        if (!decoded.contains('à¤') && decoded != result) {
          result = decoded;
        }
      } catch (_) {
        // Ignore errors
      }
    }

    return result;
  }

  String _removeInvalidCharacters(String text) {
    // Remove the replacement character �
    return text.replaceAll('�', '');
  }

  @override
  void initState() {
    super.initState();
    _initialize();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent &&
          !_loadingHistory &&
          _hasMoreHistory) {
        _loadOlderMessages();
      }
    });
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _myUserId = widget.myUserId.trim();
    _roomId = widget.roomId.trim();
    _token = widget.token ?? prefs.getString('access_token') ?? '';

    if (_myUserId.isEmpty || _roomId.isEmpty || _token.isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }

    try {
      final astro = await _api.fetchAstrologerDetail(widget.astrologerProfileId);
      _displayName = astro.name;
      _chatRate = (astro.chatCharge ?? 0).toDouble();
      await _deductBalance();
      await _loadFullChatHistory();
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
    _scrollToBottom(force: true);
    _connectWebSocket();
  }

  // ---------------------------------------------------------------------------
  // CHAT HISTORY - SIMPLIFIED
  // ---------------------------------------------------------------------------
  Future<void> _loadFullChatHistory() async {
    try {
      final batch = await _api.getChatHistory(
        widget.astrologerUserId,
        page: 1,
        size: _pageSize,
      );

      if (mounted) {
        setState(() {
          _messages.clear();
          for (var msg in batch) {
            // Use our simplified decoding function
            final messageText = _decodeMessageContent(msg.content);

            _messages.add({
              'sender_id': msg.senderId.toString(),
              'message': messageText,
              'created_at': msg.createdAt.toIso8601String(),
            });
          }
          // Sort messages by date (oldest to newest)
          _messages.sort((a, b) => DateTime.parse(a['created_at'])
              .compareTo(DateTime.parse(b['created_at'])));
        });
      }
    } catch (e) {
      debugPrint("Error loading chat history: $e");
    }
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

        // Store current scroll position before adding new messages
        final oldScrollPosition = _scrollController.position.pixels;
        final oldItemCount = _messages.length;

        if (mounted) {
          setState(() {
            // Add new messages at the beginning (oldest)
            for (var msg in batch) {
              final messageText = _decodeMessageContent(msg.content);

              _messages.insert(0, {
                'sender_id': msg.senderId.toString(),
                'message': messageText,
                'created_at': msg.createdAt.toIso8601String(),
              });
            }

            // Sort messages by date (oldest to newest)
            _messages.sort((a, b) => DateTime.parse(a['created_at'])
                .compareTo(DateTime.parse(b['created_at'])));
          });

          // After the list is updated, adjust scroll position
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              final newItemCount = _messages.length;
              final itemsAdded = newItemCount - oldItemCount;

              // Calculate new scroll position to maintain view
              final newScrollPosition = oldScrollPosition +
                  (_scrollController.position.maxScrollExtent * (itemsAdded / newItemCount));

              _scrollController.jumpTo(newScrollPosition);
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading older messages: $e");
    }
    _loadingHistory = false;
  }

  // ---------------------------------------------------------------------------
  // WEBSOCKET CONNECTION
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

      if (mounted) setState(() => _isConnected = true);

      _socket!.listen(
        _onMessage,
        onDone: _handleDisconnect,
        onError: (_) => _handleDisconnect(),
      );

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
    _socket = null;
    if (mounted) setState(() => _isConnected = false);
  }

  void _onMessage(dynamic data) {
    try {
      String raw;
      if (data is List<int>) {
        raw = utf8.decode(data, allowMalformed: true);
      } else {
        raw = data as String;
      }

      final parsed = jsonDecode(raw);

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
      if (msg == null || msg['sender_user_id'].toString() == _myUserId) return;

      _otherIsReady = true;
      _tryStartTimer();

      // Decode message content
      final messageText = _decodeMessageContent(msg['content']);

      if (mounted) {
        setState(() {
          _messages.add({
            'sender_id': msg['sender_user_id'].toString(),
            'message': messageText,
            'created_at': msg['created_at'],
          });
          // Keep messages sorted by date
          _messages.sort((a, b) => DateTime.parse(a['created_at'])
              .compareTo(DateTime.parse(b['created_at'])));
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("WS error: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // TIMER MANAGEMENT
  // ---------------------------------------------------------------------------
  void _tryStartTimer() {
    if (_timerStarted) return;
    if (_iAmReady && _otherIsReady && _isConnected) {
      _startSessionTimer();
    }
  }

  void _startSessionTimer() {
    if (_timerStarted) return;
    _timerStarted = true;
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 0) {
        _stopSessionTimer();
        return;
      }
      if (mounted) setState(() => _secondsLeft--);
    });
  }

  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _timerStarted = false;
  }

  // ---------------------------------------------------------------------------
  // SEND MESSAGE
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
      // Keep messages sorted by date
      _messages.sort((a, b) => DateTime.parse(a['created_at'])
          .compareTo(DateTime.parse(b['created_at'])));
    });

    _socket!.add(jsonEncode({'content': text}));
    _controller.clear();
    _scrollToBottom(force: true);
  }

  // ---------------------------------------------------------------------------
  // UI HELPER METHODS
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

  void _scrollToBottom({bool force = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appLight,
      appBar: AppBar(
        backgroundColor: appDark,
        title: Text(
          _displayName ?? widget.astrologerName,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                "${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(
                    color: appYellow, fontWeight: FontWeight.bold),
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
              reverse: false, // Ensure this is false for normal chronological order
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isMine = m['sender_id'].toString() == _myUserId;
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
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMine ? appYellow : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          m['message'] ?? "",
          style: TextStyle(
            fontSize: 16,
            color: isMine ? Colors.black : appDark,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: "Type message...",
                filled: true,
                fillColor: appLight,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: appYellow,
            child: IconButton(
              icon: const Icon(Icons.send, color: appDark),
              onPressed: _sendMessage,
            ),
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