import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/model/fastApiModel/astrologerProfileModel.dart';
import 'package:http/http.dart' as http;

import '../../services/location_services.dart';

class CustomerChatPage extends StatefulWidget {
  final String astrologerUserId;
  final String astrologerProfileId;
  final String roomId;
  final String myUserId;
  final String astrologerName;
  final String? token;
  final double? chatCharge; // Add this parameter

  const CustomerChatPage({
    super.key,
    required this.astrologerUserId,
    required this.astrologerProfileId,
    required this.roomId,
    required this.myUserId,
    required this.astrologerName,
    this.token,
    this.chatCharge, // Add this
  });

  @override
  State<CustomerChatPage> createState() => _CustomerChatPageState();
}

class _CustomerChatPageState extends State<CustomerChatPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final FastAPIServices _api = FastAPIServices();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  WebSocket? _socket;
  bool _isConnected = false;
  bool _isLoading = true;
  bool _manuallyClosed = false;
  bool _isCharged = false;
  bool _chargeFailed = false;

  bool _iAmReady = false;
  bool _otherIsReady = false;
  bool _timerStarted = false;

  // Reconnection variables
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const int _reconnectDelaySeconds = 3;

  static const int _totalSessionSeconds = 10 * 60;
  int _secondsLeft = _totalSessionSeconds;
  Timer? _sessionTimer;

  final List<Map<String, dynamic>> _messages = [];

  late String _myUserId;
  late String _roomId;
  late String _token;

  String? _displayName;
  String? _astrologerProfileImage;
  double _chatRate = 0;

  double _chatRateInr = 0;
  double _chatRateUsd = 0;

  int _historyPage = 1;
  bool _hasMoreHistory = true;
  bool _loadingHistory = false;
  static const int _pageSize = 50;

  // Flag to track if warning dialog has been shown
  bool _warningDialogShown = false;

  // Contact detection constants
  static const List<String> _blockedKeywords = [
    'whatsapp', 'wa.me', 'telegram', 'instagram', 'fb.com',
    'facebook', 't.me', 'telegram.me', 'signal', 'wechat',
    'snapchat', 'line.me', 'viber', 'kik', 'skype',
    'onlyfans', 'patreon', 'cashapp', 'paypal.me', 'gpay',
    'phonepe', 'paytm', 'amazon pay', 'google pay', 'whats app',
    'wa me', 'tele gram', 'insta', 'fb', 'yt', 'youtube.com',
    'youtu.be', 'whatsapp.com', 'wa.link', 'call me', 'text me',
    'contact me', 'my number', 'reach me', 'ping me', 'dm me'
  ];

  static const List<String> _platformPatterns = [
    r'whatsapp\.com',
    r'wa\.me',
    r'telegram\.(me|org)',
    r't\.me',
    r'instagram\.com',
    r'fb\.com',
    r'facebook\.com',
    r'signal\.org',
    r'line\.me',
    r'viber\.com',
    r'kik\.me',
    r'skype\.com',
    r'youtube\.com',
    r'youtu\.be',
    r'wa\.link',
  ];

  // Enhanced color scheme
  static const Color primaryYellow = Color(0xFFFFC31F);
  static const Color primaryDark = Color(0xFF1A1A1A);
  static const Color primaryLight = Color(0xFFF8F9FA);
  static const Color messageBubbleMine = Color(0xFFFFC31F);
  static const Color messageBubbleOther = Colors.white;
  static const Color onlineGreen = Color(0xFF4CAF50);
  static const Color offlineGrey = Color(0xFF9E9E9E);
  static const Color shadowColor = Color(0x1A000000);
  static const Color appBarGradientStart = Color(0xFF2C3E50);
  static const Color appBarGradientEnd = Color(0xFF1A1A1A);

  // Animation controllers
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  bool _isAstrologerTyping = false;
  Timer? _typingTimer;
  Timer? _warningDebounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();

    // Initialize typing animation
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _typingAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
          parent: _typingAnimationController, curve: Curves.easeInOut),
    );
    _typingAnimationController.repeat(reverse: true);

    // Add listener for real-time contact detection
    _controller.addListener(_onTextChanged);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels <=
          _scrollController.position.minScrollExtent + 100 &&
          !_loadingHistory &&
          _hasMoreHistory) {
        _loadOlderMessages();
      }
    });

    // Show warning dialog after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStayOnScreenWarning();
    });
  }

  // Show warning dialog about staying on screen
  void _showStayOnScreenWarning() {
    if (_warningDialogShown) return;
    _warningDialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text(
                'Important!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 50,
                      color: Colors.orange,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your 10-minute chat session starts now!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      '⚠️ Please do NOT:\n'
                          '• Minimize the app\n'
                          '• Switch to other apps\n'
                          '• Turn off your screen\n'
                          '• Close the chat\n\n'
                          'The timer will continue running and you may lose your session!',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  'I Understand',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Contact Detection Methods
  bool _containsPersonalContact(String message) {
    if (message.isEmpty) return false;

    final lowerMsg = message.toLowerCase();

    // 1. Check for blocked keywords
    for (final keyword in _blockedKeywords) {
      if (lowerMsg.contains(keyword)) {
        debugPrint("🚫 Blocked keyword found: $keyword");
        return true;
      }
    }

    // 2. Check for phone numbers (multiple formats)
    final phonePatterns = [
      r'\b[6-9]\d{9}\b',
      r'(\+91|0091)[6-9]\d{9}\b',
      r'\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b',
      r'\+\d{1,3}[-.\s]?\d{4,14}\b',
      r'\b\d{10,15}\b',
      r'\b\d{5}[-\s]?\d{5}\b',
      r'\b\d{3}\s?\d{3}\s?\d{4}\b',
    ];

    for (final pattern in phonePatterns) {
      final regex = RegExp(pattern);
      if (regex.hasMatch(message)) {
        debugPrint("📞 Phone number pattern detected: $pattern");
        return true;
      }
    }

    // 3. Check for email addresses
    final emailPattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b';
    final emailRegex = RegExp(emailPattern);
    if (emailRegex.hasMatch(message)) {
      debugPrint("📧 Email address detected");
      return true;
    }

    // 4. Check for social media/platform URLs
    for (final pattern in _platformPatterns) {
      final regex = RegExp(pattern, caseSensitive: false);
      if (regex.hasMatch(message)) {
        debugPrint("🌐 Social media URL detected: $pattern");
        return true;
      }
    }

    // 5. Check for common contact sharing phrases
    final contactPhrases = [
      r'call me at',
      r'text me at',
      r'contact me on',
      r'reach me at',
      r'my number is',
      r'my whatsapp',
      r'my telegram',
      r'add me on',
      r'ping me on',
      r'dm me on',
      r'message me on',
      r'hit me up on',
      r'you can call',
      r'you can text',
      r'here is my',
      r'this is my',
    ];

    for (final phrase in contactPhrases) {
      if (RegExp(phrase, caseSensitive: false).hasMatch(message)) {
        debugPrint("🔍 Contact phrase detected: $phrase");
        return true;
      }
    }

    return false;
  }

  List<String> _getDetectedPatterns(String message) {
    final patterns = <String>[];
    final lowerMsg = message.toLowerCase();

    for (final keyword in _blockedKeywords) {
      if (lowerMsg.contains(keyword)) {
        patterns.add('keyword_$keyword');
      }
    }

    if (RegExp(r'\b[6-9]\d{9}\b').hasMatch(message)) {
      patterns.add('phone_indian');
    }

    if (RegExp(r'\+\d{1,3}[-.\s]?\d{4,14}\b').hasMatch(message)) {
      patterns.add('phone_international');
    }

    if (RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
        .hasMatch(message)) {
      patterns.add('email');
    }

    for (final pattern in _platformPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(message)) {
        patterns.add('social_media');
        break;
      }
    }

    return patterns;
  }

  void _logSuspiciousMessage(String message) {
    final logData = {
      'user_id': _myUserId,
      'astrologer_id': widget.astrologerUserId,
      'room_id': _roomId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'detected_patterns': _getDetectedPatterns(message),
    };
    debugPrint("📝 Suspicious message logged: $logData");
  }

  void _onTextChanged() {
    final text = _controller.text;
    if (text.isNotEmpty && _containsPersonalContact(text)) {
      _warningDebounceTimer?.cancel();
      _warningDebounceTimer = Timer(const Duration(milliseconds: 800), () {
        if (mounted && _containsPersonalContact(_controller.text)) {
          _showTypingWarning();
        }
      });
    }
  }

  void _showTypingWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sharing personal contact information is not allowed',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showContactWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('Warning!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sharing personal contact information is not allowed:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              _buildBulletPoint('Phone numbers'),
              _buildBulletPoint('Email addresses'),
              _buildBulletPoint('Social media handles'),
              _buildBulletPoint('WhatsApp / Telegram links'),
              _buildBulletPoint('Payment app details'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Text(
                  'For your safety, all conversations are monitored. '
                      'Please keep all communication within the app.',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: primaryDark,
              ),
              child: const Text('I Understand'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text)),
        ],
      ),
    );
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
      // First fetch astrologer profile to get chat rate
      await _fetchAstrologerProfile();

      // Charge user immediately when entering, just like video call page
      if (_chatRateInr > 0 || _chatRateUsd > 0) {
        await _deductBalance(); // Charge immediately
      }

      // If charge failed, don't proceed
      if (_chargeFailed) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      // Load chat history
      await _loadFullChatHistory();

      // Start timer immediately when screen loads
      _startSessionTimer();

    } catch (e) {
      debugPrint("Error initializing: $e");
      _displayName = widget.astrologerName;
    }

    if (mounted) setState(() => _isLoading = false);
    _scrollToBottom(force: true);
    _connectWebSocket();
    await _saveSession();
  }

  Future<void> _fetchAstrologerProfile() async {
    try {
      final astro =
      await _api.fetchAstrologerDetail(widget.astrologerProfileId);

      if (mounted) {
        setState(() {
          _displayName = astro.name;

           _chatRateInr = astro.chatCharge ?? 0;
           _chatRateUsd = astro.chatChargeUSD ?? 0;

          debugPrint("💰 Chat INR rate: $_chatRateInr");
          debugPrint("💰 Chat USD rate: $_chatRateUsd");

          if (astro.profileImage != null && astro.profileImage!.isNotEmpty) {
            _astrologerProfileImage = _getFullImageUrl(astro.profileImage);
          }
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching astrologer profile: $e");

      if (widget.chatCharge != null) {
        _chatRateInr = widget.chatCharge!;
      }
    }
  }

  String? _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;

    if (imagePath.startsWith('http')) return imagePath;

    if (imagePath.startsWith('file://')) {
      final fileName = imagePath.split('/').last;
      return 'https://fastapi.jyotishionline.com/static/uploads/$fileName';
    }

    if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
      return 'https://fastapi.jyotishionline.com${imagePath.startsWith('/') ? imagePath : '/$imagePath'}';
    }

    return imagePath;
  }

  String _decodeMessageContent(dynamic content) {
    if (content == null) return '';

    try {
      String text;
      if (content is String) {
        text = content;
      } else {
        text = content.toString();
      }
      return _fixTextEncoding(text);
    } catch (e) {
      debugPrint("Error decoding message: $e");
      return content.toString();
    }
  }

  String _fixTextEncoding(String text) {
    if (text.isEmpty) return text;
    String result = text;

    if (_looksLikeDoubleEncoded(result)) {
      result = _tryFixDoubleEncoding(result);
    }

    result = _fixCommonMojibake(result);
    result = _fixHindiEncoding(result);
    result = _removeInvalidCharacters(result);

    return result;
  }

  bool _looksLikeDoubleEncoded(String text) {
    return text.contains('Ã') ||
        text.contains('â') ||
        text.contains('Â') ||
        text.contains('â€') ||
        text.contains('à¤') ||
        text.contains('à¥');
  }

  String _tryFixDoubleEncoding(String text) {
    try {
      final latinBytes = latin1.encode(text);
      final decoded = utf8.decode(latinBytes, allowMalformed: true);
      if (!decoded.contains('�') && decoded != text) {
        return decoded;
      }
    } catch (_) {}
    return text;
  }

  String _fixCommonMojibake(String text) {
    String result = text;
    final fixes = {
      'â€™': '\'',
      'â€œ': '"',
      'â€': '"',
      'â€˜': '\'',
      'â€¦': '…',
      'â€¢': '•',
      'â€"': '–',
      'â€"': '—',
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
    final hindiFixes = {
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

    if (result.contains('à¤') && result.length > 10) {
      try {
        final bytes = latin1.encode(result);
        final decoded = utf8.decode(bytes, allowMalformed: true);
        if (!decoded.contains('à¤') && decoded != result) {
          result = decoded;
        }
      } catch (_) {}
    }
    return result;
  }

  String _removeInvalidCharacters(String text) {
    return text.replaceAll('�', '');
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("chat_active", true);
    await prefs.setString("room_id", _roomId);
    await prefs.setString("astro_id", widget.astrologerUserId);
    await prefs.setString("astro_name", widget.astrologerName);
  }

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
            final messageText = _decodeMessageContent(msg.content);
            _messages.add({
              'sender_id': msg.senderId.toString(),
              'message': messageText,
              'created_at': msg.createdAt.toIso8601String(),
            });
          }
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
        final oldScrollPosition = _scrollController.position.pixels;
        final oldItemCount = _messages.length;

        if (mounted) {
          setState(() {
            for (var msg in batch) {
              final messageText = _decodeMessageContent(msg.content);
              _messages.insert(0, {
                'sender_id': msg.senderId.toString(),
                'message': messageText,
                'created_at': msg.createdAt.toIso8601String(),
              });
            }
            _messages.sort((a, b) => DateTime.parse(a['created_at'])
                .compareTo(DateTime.parse(b['created_at'])));
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              final newItemCount = _messages.length;
              final itemsAdded = newItemCount - oldItemCount;
              final newScrollPosition = oldScrollPosition +
                  (_scrollController.position.maxScrollExtent *
                      (itemsAdded / newItemCount));
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

      // Reset reconnection attempts on successful connection
      _reconnectAttempts = 0;

      if (mounted) setState(() => _isConnected = true);

      _socket!.listen(
        _onMessage,
        onDone: _handleDisconnect,
        onError: (error) {
          debugPrint("❌ WebSocket error: $error");
          _handleDisconnect();
        },
      );

      // Send ready status
      _iAmReady = true;
      final readyMsg = jsonEncode({
        "type": "connectivity",
        "status": "ready",
        "user_id": _myUserId,
        "room_id": _roomId,
      });
      _socket!.add(readyMsg);
      debugPrint("📤 Sent ready status: $readyMsg");
    } catch (e) {
      debugPrint("❌ WebSocket connection error: $e");
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _otherIsReady = false;
    _stopSessionTimer();
    _socket = null;
    if (mounted) setState(() => _isConnected = false);

    // Attempt to reconnect if not manually closed and within limits
    if (!_manuallyClosed && _reconnectAttempts < _maxReconnectAttempts) {
      _attemptReconnection();
    } else if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint("❌ Max reconnection attempts reached");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to connect to chat server'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _attemptReconnection() {
    _reconnectAttempts++;
    debugPrint("🔄 Attempting to reconnect (${_reconnectAttempts}/$_maxReconnectAttempts)...");

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: _reconnectDelaySeconds), () {
      if (mounted && !_manuallyClosed) {
        _connectWebSocket();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_socket == null && !_manuallyClosed) {
        _connectWebSocket();
      }
    } else if (state == AppLifecycleState.paused) {
      // Show warning when app is minimized
      if (mounted && !_manuallyClosed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Chat timer is still running! Please stay on this screen.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
          if (mounted) setState(() {});
          debugPrint("✅ Astrologer is ready to chat");
        } else if (parsed['status'] == 'offline') {
          _otherIsReady = false;
          if (mounted) setState(() {});
          debugPrint("❌ Astrologer went offline");
        } else if (parsed['status'] == 'typing') {
          _handleTypingIndicator(parsed['is_typing'] ?? false);
        }
        return;
      }

      if (parsed['type'] != 'message') return;

      final msg = parsed['message'];
      if (msg == null || msg['sender_user_id'].toString() == _myUserId) return;

      // Ensure astrologer is marked as ready when they send a message
      _otherIsReady = true;

      final messageText = _decodeMessageContent(msg['content']);

      if (mounted) {
        setState(() {
          _messages.add({
            'sender_id': msg['sender_user_id'].toString(),
            'message': messageText,
            'created_at': msg['created_at'],
          });
          _messages.sort((a, b) => DateTime.parse(a['created_at'])
              .compareTo(DateTime.parse(b['created_at'])));
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("WS error: $e");
    }
  }

  void _handleTypingIndicator(bool isTyping) {
    setState(() {
      _isAstrologerTyping = isTyping;
    });

    if (isTyping) {
      _typingTimer?.cancel();
    } else {
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isAstrologerTyping = false);
        }
      });
    }
  }

  void _startSessionTimer() {
    if (_timerStarted) return;
    _timerStarted = true;
    debugPrint("⏱️ Chat timer started: 10 minutes");

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        _showTimeUpDialog();
        timer.cancel();
        return;
      }
      if (mounted) setState(() => _secondsLeft--);
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              Icon(Icons.timer_off, color: primaryYellow, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Chat Session Ended',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          content: const Text(
            'Your 10-minute chat session has ended. Thank you for using our service!',
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryYellow,
                  foregroundColor: primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('OK',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _timerStarted = false;
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || !_isConnected || _socket == null) return;

    // Check if charge failed
    if (_chargeFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment failed. Please check your balance.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check for personal contact info
    if (_containsPersonalContact(text)) {
      _logSuspiciousMessage(text);
      _showContactWarningDialog();
      return;
    }

    setState(() {
      _messages.add({
        'sender_id': _myUserId,
        'message': text,
        'created_at': DateTime.now().toIso8601String(),
      });
      _messages.sort((a, b) => DateTime.parse(a['created_at'])
          .compareTo(DateTime.parse(b['created_at'])));
    });

    _socket!.add(jsonEncode({'content': text}));
    _controller.clear();
    _scrollToBottom(force: true);
  }

  void _sendTypingIndicator(bool isTyping) {
    if (_socket != null && _isConnected) {
      _socket!.add(jsonEncode({
        "type": "connectivity",
        "status": "typing",
        "is_typing": isTyping,
        "user_id": _myUserId,
        "room_id": _roomId,
      }));
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

  // Enhanced deduct balance method matching video call page pattern
  Future<void> _deductBalance() async {
    if (_isCharged) return;

    _isCharged = true;

    try {
      double chargeAmount;

      if (LocationService.isIndianUser) {
        chargeAmount = _chatRateInr;

        debugPrint("🇮🇳 Indian user → ₹$chargeAmount");

      } else {
        double usdAmount = _chatRateUsd > 0 ? _chatRateUsd : _chatRateInr;

        debugPrint("🌍 International user → \$${usdAmount}");

        final response =
        await http.get(Uri.parse("https://open.er-api.com/v6/latest/USD"));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          double rate = data["rates"]["INR"];

          chargeAmount = usdAmount * rate;

          debugPrint("💱 Converted: \$${usdAmount} → ₹$chargeAmount");

        } else {
          chargeAmount = usdAmount * 83;
        }
      }

      debugPrint("📤 Final amount sent to astrologer: ₹$chargeAmount");

      await _api.sendMoney(
        astrologerId: widget.astrologerProfileId,
        amount: chargeAmount.round(),
        type: "chat",
      );

      if (mounted) {
        _showMoneyDeductedDialog(chargeAmount);
      }

    } catch (e) {
      debugPrint("💥 Charge failed: $e");

      _chargeFailed = true;

      _showSnackBar("Failed to charge. Chat may not start.", Colors.red);

      _showChargeFailedDialog();
    }
  }

  // Charge failed dialog (copied from video call page)
  void _showChargeFailedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text(
                'Payment Failed',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Unable to charge your account.\n\n'
                    'Please check your balance and try again.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Customer can send messages if connected to WebSocket and payment succeeded
    final canSend = _isConnected && !_chargeFailed;

    return WillPopScope(
      onWillPop: () async {
        // Show warning when trying to go back
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('End Chat Session?'),
            content: const Text(
                'Are you sure you want to leave?\n\n'
                    'Your chat session will end and you may still be charged.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Leave'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: primaryLight,
        appBar: _buildAppBar(),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryYellow))
            : _chargeFailed
            ? _buildChargeFailedScreen()
            : Column(
          children: [
            _buildConnectionStatus(),
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: _buildMessageList(),
              ),
            ),
            if (_isAstrologerTyping) _buildTypingIndicator(),
            _buildInput(canSend),
          ],
        ),
      ),
    );
  }

  // Charge failed screen (copied from video call page)
  Widget _buildChargeFailedScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 80,
          ),
          const SizedBox(height: 20),
          const Text(
            'Payment Failed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Unable to charge your account.\nPlease check your balance.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [appBarGradientStart, appBarGradientEnd],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () async {
                        // Show warning when trying to go back
                        final shouldPop = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text('End Chat Session?'),
                            content: const Text(
                                'Are you sure you want to leave?\n\n'
                                    'Your chat session will end and you may still be charged.'
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Stay'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Leave'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildAstrologerAvatar(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayName ?? widget.astrologerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _otherIsReady ? onlineGreen : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _otherIsReady ? 'Online' : 'Away',
                                style: TextStyle(
                                  color: _otherIsReady ? onlineGreen : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildTimerWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAstrologerAvatar() {
    final hasValidImage = _astrologerProfileImage != null &&
        _astrologerProfileImage!.isNotEmpty;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primaryYellow, width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryYellow.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: hasValidImage
            ? CachedNetworkImage(
          imageUrl: _astrologerProfileImage!,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildAvatarPlaceholder(),
          errorWidget: (context, url, error) {
            debugPrint("Error loading profile image: $error");
            return _buildAvatarPlaceholder();
          },
        )
            : _buildAvatarPlaceholder(),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    String? firstLetter;
    if (_displayName != null && _displayName!.isNotEmpty) {
      firstLetter = _displayName![0].toUpperCase();
    } else if (widget.astrologerName.isNotEmpty) {
      firstLetter = widget.astrologerName[0].toUpperCase();
    }

    return Container(
      color: Colors.grey[300],
      child: Center(
        child: firstLetter != null
            ? Text(
          firstLetter,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        )
            : const Icon(
          Icons.person,
          color: Colors.grey,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildTimerWidget() {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    final progress = _secondsLeft / _totalSessionSeconds;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress < 0.3 ? Colors.red : primaryYellow,
                  ),
                  strokeWidth: 3,
                ),
              ),
              Icon(
                Icons.timer,
                color: progress < 0.3 ? Colors.red : primaryYellow,
                size: 18,
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            '$minutes:$seconds',
            style: TextStyle(
              color: progress < 0.3 ? Colors.red : primaryYellow,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    // Show connection status with reconnection attempt info
    if (_isConnected) return const SizedBox.shrink();

    String message = 'Connecting...';
    if (_reconnectAttempts > 0) {
      message = 'Reconnecting... (Attempt $_reconnectAttempts/$_maxReconnectAttempts)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.red[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
          if (_reconnectAttempts > 0)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/chat_bg_pattern.png'),
          fit: BoxFit.cover,
          opacity: 0.05,
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        reverse: false,
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (_, i) {
          final m = _messages[i];
          final isMine = m['sender_id'].toString() == _myUserId;
          final showAvatar = !isMine &&
              (i == 0 || _messages[i - 1]['sender_id'] != m['sender_id']);
          return _buildEnhancedBubble(m, isMine, showAvatar);
        },
      ),
    );
  }

  Widget _buildEnhancedBubble(
      Map<String, dynamic> m, bool isMine, bool showAvatar) {
    final messageTime = DateTime.parse(m['created_at']);
    final timeString = TimeOfDay.fromDateTime(messageTime).format(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
        isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine && showAvatar)
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryYellow, width: 1.5),
              ),
              child: ClipOval(
                child: _astrologerProfileImage != null
                    ? CachedNetworkImage(
                  imageUrl: _astrologerProfileImage!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.person,
                        color: Colors.grey, size: 16),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.person,
                        color: Colors.grey, size: 16),
                  ),
                )
                    : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.person,
                      color: Colors.grey, size: 16),
                ),
              ),
            ),
          if (!isMine && !showAvatar) const SizedBox(width: 38),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: isMine ? messageBubbleMine : messageBubbleOther,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: !isMine && showAvatar
                      ? Radius.zero
                      : const Radius.circular(20),
                  bottomRight: isMine && showAvatar
                      ? Radius.zero
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m['message'] ?? "",
                    style: TextStyle(
                      fontSize: 15,
                      color: isMine ? Colors.black : primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeString,
                    style: TextStyle(
                      fontSize: 10,
                      color: isMine ? Colors.black54 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryYellow, width: 1),
            ),
            child: ClipOval(
              child: _astrologerProfileImage != null
                  ? CachedNetworkImage(
                imageUrl: _astrologerProfileImage!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.person,
                      color: Colors.grey, size: 16),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.person,
                      color: Colors.grey, size: 16),
                ),
              )
                  : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.person,
                    color: Colors.grey, size: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _typingAnimation,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: primaryDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                FadeTransition(
                  opacity: _typingAnimation,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: primaryDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                FadeTransition(
                  opacity: _typingAnimation,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: primaryDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(bool canSend) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: canSend ? primaryLight : Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                enabled: canSend,
                onChanged: (text) {
                  if (canSend) {
                    _sendTypingIndicator(text.isNotEmpty);
                  }
                },
                decoration: InputDecoration(
                  hintText: canSend
                      ? "Type a message..."
                      : _chargeFailed
                      ? "Payment failed. Please go back."
                      : _reconnectAttempts > 0
                      ? "Reconnecting... Please wait"
                      : "Connecting...",
                  hintStyle: TextStyle(
                    color: canSend ? Colors.grey[500] : Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  suffixIcon: _controller.text.isNotEmpty && canSend
                      ? IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined,
                        color: primaryYellow),
                    onPressed: () {
                      // Implement emoji picker if needed
                    },
                  )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: canSend ? primaryYellow : Colors.grey[400],
            ),
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: canSend ? primaryDark : Colors.white,
              ),
              onPressed: canSend ? _sendMessage : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("chat_active");
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _warningDebounceTimer?.cancel();
    _clearSession();
    WidgetsBinding.instance.removeObserver(this);
    _typingAnimationController.dispose();
    _typingTimer?.cancel();

    _manuallyClosed = true;
    if (_socket != null) {
      try {
        _socket!.add(jsonEncode({
          "type": "connectivity",
          "status": "offline",
          "user_id": _myUserId,
          "room_id": _roomId,
        }));
      } catch (_) {}
    }
    _stopSessionTimer();
    _socket?.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showMoneyDeductedDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text(
                "Payment Successful",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            LocationService.isIndianUser
                ? "₹${_chatRateInr.toStringAsFixed(2)} has been deducted"
                : "\$${_chatRateUsd.toStringAsFixed(2)} has been deducted",
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text("OK"),
              ),
            ),
          ],
        );
      },
    );
  }
}