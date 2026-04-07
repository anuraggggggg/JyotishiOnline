// lib/views/live/LiveViewerPage.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:provider/provider.dart';

import '../../controllers/fastApiProvider/giftProvider.dart';
import '../../fastApi/fastApiServices.dart';
import '../../model/fastApiModel/astrologerProfileModel.dart';
import '../../model/fastApiModel/giftModel.dart';
import '../../theme/appTheme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────

enum _SenderType { me, host, viewer, giftAnnounce, superChat }

class _ChatMessage {
  final String displayName;
  final String text;
  final DateTime at;
  final _SenderType type;
  final String? giftEmoji;
  final int? giftTotal;

  // Super Chat fields
  final bool isSuper;
  final double? superAmount;

  _ChatMessage({
    required this.displayName,
    required this.text,
    required this.at,
    required this.type,
    this.giftEmoji,
    this.giftTotal,
    this.isSuper = false,
    this.superAmount,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────────────────

class LiveViewerPage extends StatefulWidget {
  final String channelName;
  final String token;

  /// The astrologer backend ID — used ONLY to fetch profile info, NOT an Agora UID.
  final String astroId;

  const LiveViewerPage({
    super.key,
    required this.channelName,
    required this.token,
    required this.astroId,
  });

  @override
  State<LiveViewerPage> createState() => _LiveViewerPageState();
}

class _LiveViewerPageState extends State<LiveViewerPage>
    with TickerProviderStateMixin {
  // ── Agora ──────────────────────────────────────────────────────────────────
  late RtcEngine _engine;
  static const String _agoraAppId = "3a39af44074a40bebc2fff2cba7437e5";

  late final int _myUid;
  int? _hostAgoraUid;
  int? _dataStreamId;
  bool _isBroadcaster = false;
  bool _roleSwitching = false;
  bool _joining = true;
  bool _sessionEnded = false;

  final Set<int> _remoteUids = {};

  // ── Profile ────────────────────────────────────────────────────────────────
  String _myName = 'You';
  String _astrologerName = 'Astrologer';
  Astrologer? _astrologer;

  // ── Stats ──────────────────────────────────────────────────────────────────
  int _viewerCount = 0;
  int _lastViewerCount = 0;

  // ── Chat ───────────────────────────────────────────────────────────────────
  final Map<int, String> _uidNameCache = {};
  final Map<String, List<String?>> _recvParts = {};
  final Map<String, int> _recvTotal = {};

  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _inputCtrl = TextEditingController();

  bool _showChat = true;
  bool _showConsultButtons = true;

  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // ── Gift overlay ───────────────────────────────────────────────────────────
  OverlayEntry? _giftOverlayEntry;

  // ── Wallet ─────────────────────────────────────────────────────────────────
  double _walletBalance = 0;

  // ── Super Chat ─────────────────────────────────────────────────────────────
  bool _superChatPaying = false;

  // Pinned super chats (max 3, newest first)
  final List<_ChatMessage> _pinnedSuperChats = [];

  static const double _superChatAmount = 10.0;

  bool get _canSend =>
      !_joining && !_roleSwitching && _inputCtrl.text.trim().isNotEmpty;

  void _log(Object m) => debugPrint('🧭 [LiveViewer] $m');

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _myUid = Random().nextInt(900000) + 100000;

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _loadProfile();
    _initRTC();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _giftOverlayEntry?.remove();
    try {
      _engine.leaveChannel();
      _engine.release();
    } catch (_) {}
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PROFILE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    try {
      final svc = FastAPIServices();
      final user = await svc.fetchCurrentUserDetails();
      final balance = await svc.fetchCurrentWallet();
      _myName =
      (user.name?.trim().isNotEmpty ?? false) ? user.name!.trim() : 'Guest';
      _walletBalance = (balance!.amount ?? 0).toDouble();

      final astro = await svc.fetchAstrologerDetail(widget.astroId);
      _astrologer = astro;
      _astrologerName = astro.name.trim();
      if (mounted) setState(() {});
    } catch (e) {
      _log('Profile error: $e');
      if (mounted) setState(() {});
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AGORA INIT
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _initRTC() async {
    if (widget.token.isEmpty || widget.channelName.isEmpty) {
      _log('ERROR: token or channelName is empty — aborting RTC init');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Invalid session token. Please go back and try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ));
      }
      return;
    }

    _log('initRTC → channel=${widget.channelName} uid=$_myUid');

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: _agoraAppId));

    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        _log('Joined uid=$_myUid elapsed=${elapsed}ms');
        if (mounted) setState(() => _joining = false);

        if (_hostAgoraUid == null && _remoteUids.isNotEmpty && mounted) {
          final firstUid = _remoteUids.first;
          _log('Host already captured in _remoteUids → $firstUid');
          setState(() => _hostAgoraUid = firstUid);
        }
      },

      onUserJoined: (connection, uid, elapsed) {
        _log('onUserJoined uid=$uid  hostAlreadySet=${_hostAgoraUid != null}');
        _remoteUids.add(uid);
        if (_hostAgoraUid == null && mounted) {
          setState(() => _hostAgoraUid = uid);
          _log('Host locked via onUserJoined → $uid');
        }
      },

      onUserOffline: (connection, uid, reason) {
        _log('onUserOffline uid=$uid reason=$reason host=$_hostAgoraUid');
        _remoteUids.remove(uid);
        if (uid == _hostAgoraUid && mounted && !_sessionEnded) {
          setState(() => _hostAgoraUid = null);
          _onHostLeft();
        }
      },

      onRtcStats: (connection, stats) {
        if (!mounted) return;
        final total = stats.userCount ?? 0;
        final viewers = total > 1 ? total - 1 : 0;
        if (viewers != _lastViewerCount) {
          setState(() {
            _viewerCount = viewers;
            _lastViewerCount = viewers;
          });
        }
      },

      onConnectionStateChanged: (connection, state, reason) {
        if (!mounted) return;
        if (state == ConnectionStateType.connectionStateReconnecting) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Reconnecting…'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ));
        } else if (state == ConnectionStateType.connectionStateConnected) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      },

      onStreamMessage: (connection, uid, streamId, data, offset, length) {
        _log('onStreamMessage from uid=$uid streamId=$streamId offset=$offset length=$length dataLen=${data.length}');
        final end = offset + length;
        final payload = (length > 0 && end <= data.length)
            ? Uint8List.sublistView(data, offset, end)
            : data;
        _handleIncomingChunk(uid, payload);
      },

      onError: (err, msg) {
        _log('Agora error $err – $msg');
        if (err == ErrorCodeType.errInvalidToken && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Session expired. Please rejoin.'),
            backgroundColor: Colors.red,
          ));
        }
      },
    ));

    await _engine
        .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await _engine.enableVideo();
    await _engine.enableLocalAudio(false);
    await _engine.enableLocalVideo(false);
    await _engine.muteLocalAudioStream(true);
    await _engine.muteLocalVideoStream(true);

    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: _myUid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        audienceLatencyLevel:
        AudienceLatencyLevelType.audienceLatencyLevelUltraLowLatency,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: false,
        publishMicrophoneTrack: false,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SESSION END
  // ─────────────────────────────────────────────────────────────────────────

  void _onHostLeft() {
    if (_sessionEnded) return;
    _sessionEnded = true;
    try {
      _engine.leaveChannel();
    } catch (_) {}

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: const Color(0xFF12121F),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF3B30)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.red.withOpacity(0.35),
                        blurRadius: 20,
                        spreadRadius: 2)
                  ],
                ),
                child: const Icon(Icons.live_tv_rounded,
                    color: Colors.white, size: 38),
              ),
              const SizedBox(height: 22),
              const Text('Session Ended',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 10),
              Text(
                '$_astrologerName has ended the live session.\nThank you for watching! 🙏',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: Colors.white54, height: 1.65),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    if (mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Go Back',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INCOMING STREAM MESSAGES
  // ─────────────────────────────────────────────────────────────────────────

  Uint8List _trimNulls(Uint8List b) {
    int s = 0, e = b.length;
    while (s < e && b[s] == 0) s++;
    while (e > s && b[e - 1] == 0) e--;
    return b.sublist(s, e);
  }

  void _handleIncomingChunk(int senderUid, Uint8List data) {
    try {
      final trimmed = _trimNulls(Uint8List.fromList(data));
      if (trimmed.isEmpty) {
        _log('Trimmed chunk empty from uid=$senderUid — skipping');
        return;
      }

      final rawStr = utf8.decode(trimmed, allowMalformed: true);

      Map<String, dynamic> envelope;
      try {
        envelope = jsonDecode(rawStr) as Map<String, dynamic>;
      } catch (e) {
        _log('Envelope jsonDecode FAILED uid=$senderUid raw=$rawStr err=$e');
        return;
      }

      final m = envelope['m'];
      final d = envelope['d'];
      if (m == null || d == null) {
        _log('Envelope missing m or d from uid=$senderUid');
        return;
      }

      final msgId = m['id']?.toString();
      if (msgId == null) {
        _log('m.id is null from uid=$senderUid — skipping');
        return;
      }

      final part = int.tryParse(m['part']?.toString() ?? '0') ?? 0;
      final total = int.tryParse(m['total']?.toString() ?? '1') ?? 1;

      final bufferKey = '$senderUid-$msgId';

      _recvParts.putIfAbsent(
          bufferKey, () => List<String?>.filled(total, null));
      _recvTotal[bufferKey] = total;

      if (part < 0 || part >= total) {
        _log('Invalid part=$part total=$total from uid=$senderUid — skipping');
        return;
      }

      _recvParts[bufferKey]![part] = d as String;

      if (_recvParts[bufferKey]!.any((p) => p == null)) return;

      final combined = <int>[];
      for (final p in _recvParts[bufferKey]!) {
        try {
          combined.addAll(base64.decode(p!));
        } catch (e) {
          _log('base64 decode FAILED from uid=$senderUid err=$e');
          _recvParts.remove(bufferKey);
          _recvTotal.remove(bufferKey);
          return;
        }
      }
      _recvParts.remove(bufferKey);
      _recvTotal.remove(bufferKey);

      final payloadStr = utf8.decode(combined, allowMalformed: true);

      Map<String, dynamic> obj;
      try {
        obj = jsonDecode(payloadStr) as Map<String, dynamic>;
      } catch (e) {
        _log('Payload jsonDecode FAILED uid=$senderUid err=$e');
        return;
      }

      _log('Parsed message from uid=$senderUid → $obj');

      final msgType =
          (obj['type'] as String?)?.trim().toLowerCase() ?? 'chat';

      if (msgType == 'gift') {
        _handleIncomingGift(senderUid, obj);
      } else if (msgType == 'superchat') {
        _handleIncomingSuperchat(senderUid, obj);
      } else {
        _handleIncomingChatMessage(senderUid, obj);
      }
    } catch (e, st) {
      _log('_handleIncomingChunk unhandled exception: $e\n$st');
    }
  }

  void _handleIncomingChatMessage(int senderUid, Map<String, dynamic> obj) {
    final String senderName;
    final _SenderType senderType;

    if (senderUid == _hostAgoraUid) {
      senderName = _astrologerName;
      senderType = _SenderType.host;
    } else {
      final payloadName = (obj['user'] ??
          obj['name'] ??
          obj['username'] ??
          obj['sender'] ??
          '')
          .toString()
          .trim();
      senderName = _uidNameCache.putIfAbsent(
        senderUid,
            () => payloadName.isNotEmpty ? payloadName : 'Viewer',
      );
      senderType = _SenderType.viewer;
    }

    final text =
    (obj['text'] ?? obj['message'] ?? obj['msg'] ?? '').toString().trim();

    if (text.isEmpty) {
      _log('Empty chat text from uid=$senderUid — skipping');
      return;
    }

    if (mounted) {
      setState(() {
        _messages.add(_ChatMessage(
          displayName: senderName,
          text: text,
          at: DateTime.now(),
          type: senderType,
        ));
      });
      _scrollDown();
    }
  }

  // ── Handle incoming Super Chat from another viewer or host ────────────────
  void _handleIncomingSuperchat(int senderUid, Map<String, dynamic> obj) {
    final String senderName;

    if (senderUid == _hostAgoraUid) {
      senderName = _astrologerName;
    } else {
      final payloadName = (obj['user'] ?? obj['name'] ?? '').toString().trim();
      senderName = _uidNameCache.putIfAbsent(
        senderUid,
            () => payloadName.isNotEmpty ? payloadName : 'Viewer',
      );
    }

    final text =
    (obj['text'] ?? obj['message'] ?? '').toString().trim();
    final amount = (obj['amount'] as num?)?.toDouble() ?? _superChatAmount;

    if (text.isEmpty) return;

    final msg = _ChatMessage(
      displayName: senderName,
      text: text,
      at: DateTime.now(),
      type: _SenderType.superChat,
      isSuper: true,
      superAmount: amount,
    );

    if (mounted) {
      setState(() {
        _messages.add(msg);
        _pinnedSuperChats.insert(0, msg);
        if (_pinnedSuperChats.length > 3) _pinnedSuperChats.removeLast();
      });
      _scrollDown();
      _showSuperChatOverlay(senderName, text, amount);
    }
  }

  void _handleIncomingGift(int senderUid, Map<String, dynamic> obj) {
    final senderName = senderUid == _hostAgoraUid
        ? _astrologerName
        : _uidNameCache[senderUid] ??
        (obj['user'] ?? obj['name'] ?? obj['username'] ?? 'Viewer')
            .toString()
            .trim();

    final emoji =
    (obj['gift_icon'] ?? obj['giftIcon'] ?? obj['icon'] ?? '🎁')
        .toString();
    final giftName =
    (obj['gift_name'] ?? obj['giftName'] ?? 'Gift').toString();
    final price = (obj['gift_price'] as num?)?.toInt() ??
        (obj['giftPrice'] as num?)?.toInt() ??
        int.tryParse(obj['gift_price']?.toString() ?? '0') ??
        0;

    if (mounted) {
      setState(() {
        _messages.add(_ChatMessage(
          displayName: senderName,
          text: 'sent $giftName',
          at: DateTime.now(),
          type: _SenderType.giftAnnounce,
          giftEmoji: emoji,
          giftTotal: price,
        ));
      });
      _scrollDown();
      _showGiftOverlay(emoji);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GIFT OVERLAY
  // ─────────────────────────────────────────────────────────────────────────

  void _showGiftOverlay(String emoji) {
    _giftOverlayEntry?.remove();
    _giftOverlayEntry = OverlayEntry(
      builder: (_) => _GiftOverlay(
        emoji: emoji,
        onDone: () {
          _giftOverlayEntry?.remove();
          _giftOverlayEntry = null;
        },
      ),
    );
    Overlay.of(context).insert(_giftOverlayEntry!);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SUPER CHAT OVERLAY (pink floating banner on receive)
  // ─────────────────────────────────────────────────────────────────────────

  void _showSuperChatOverlay(String name, String text, double amount) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _SuperChatOverlay(
        name: name,
        text: text,
        amount: amount,
        onDone: () {
          entry.remove();
        },
      ),
    );
    overlay.insert(entry);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ENSURE SEND READY
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> _ensureSendReady() async {
    if (_isBroadcaster && _dataStreamId != null) return true;
    if (_roleSwitching) return false;

    if (mounted) setState(() => _roleSwitching = true);
    try {
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      await _engine.updateChannelMediaOptions(const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: false,
        publishMicrophoneTrack: false,
        publishScreenTrack: false,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ));

      await _engine.muteLocalAudioStream(true);
      await _engine.muteLocalVideoStream(true);
      await _engine.enableLocalAudio(false);
      await _engine.enableLocalVideo(false);

      await Future.delayed(const Duration(milliseconds: 600));

      _dataStreamId = await _engine.createDataStream(
          const DataStreamConfig(syncWithAudio: false, ordered: true));

      if (_dataStreamId == null) {
        throw Exception('createDataStream returned null');
      }

      _isBroadcaster = true;
      _log('Stream ready id=$_dataStreamId');
      return true;
    } catch (e, st) {
      _log('ensureSendReady failed: $e\n$st');
      try {
        await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
        await _engine.updateChannelMediaOptions(const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleAudience,
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ));
      } catch (_) {}
      _isBroadcaster = false;
      _dataStreamId = null;
      return false;
    } finally {
      if (mounted) setState(() => _roleSwitching = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEND RAW PAYLOAD
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _sendRawPayload(Map<String, dynamic> payload) async {
    final payloadBytes = utf8.encode(jsonEncode(payload));
    final msgId =
        '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';
    const chunkSz = 900;
    final total = ((payloadBytes.length + chunkSz - 1) / chunkSz).ceil();

    _log('Sending payload: ${payloadBytes.length} bytes in $total chunk(s) id=$msgId');

    int sent = 0, part = 0;
    while (sent < payloadBytes.length) {
      final take = min(chunkSz, payloadBytes.length - sent);
      final chunk = payloadBytes.sublist(sent, sent + take);
      final packet = utf8.encode(jsonEncode({
        'm': {'id': msgId, 'part': part, 'total': total},
        'd': base64.encode(chunk),
      }));
      await _engine.sendStreamMessage(
        streamId: _dataStreamId!,
        data: Uint8List.fromList(packet),
        length: packet.length,
      );
      sent += take;
      part++;
      if (part < total) await Future.delayed(const Duration(milliseconds: 6));
    }
    _log('Payload sent ✅ $total chunk(s)');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEND CHAT
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _sendChatMessage([String? override]) async {
    final text = (override ?? _inputCtrl.text).trim();
    if (text.isEmpty) return;

    // Show locally first
    if (mounted) {
      setState(() {
        _messages.add(_ChatMessage(
          displayName: _myName,
          text: text,
          at: DateTime.now(),
          type: _SenderType.me,
        ));
      });
      _inputCtrl.clear();
      setState(() {});
      _scrollDown();
    }

    if (!await _ensureSendReady() || _dataStreamId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Message shown locally but stream not ready. Tap send again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      await _sendRawPayload({
        'type': 'chat',
        'user': _myName,
        'text': text,
        'ts': DateTime.now().toIso8601String(),
      });
      _log('Chat sent to host ✅');
    } catch (e, st) {
      _log('Send chat error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Could not reach host: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SUPER CHAT
  // Flow: wallet check → confirm dialog → pay API → send stream → show locally
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _sendSuperChat() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please type a message first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Step 1: wallet check
    if (_walletBalance < _superChatAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Insufficient balance. Need ₹${_superChatAmount.toStringAsFixed(0)}, you have ₹${_walletBalance.toStringAsFixed(0)}.'),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Step 2: confirm dialog
    final confirmed = await _showSuperChatConfirmDialog(text);
    if (!confirmed) return;

    // Step 3: call payment API
    if (mounted) setState(() => _superChatPaying = true);

    bool paymentOk = false;
    try {
      await FastAPIServices().sendMoney(
        astrologerId: widget.astroId,
        amount: _superChatAmount,
        type: 'superchat',
      );
      if (mounted) {
        setState(() => _walletBalance -= _superChatAmount);
      }
      paymentOk = true;
      _log('Super Chat payment OK');
    } catch (e) {
      _log('Super Chat payment failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _superChatPaying = false);
    }

    if (!paymentOk) return;

    // Step 4: ensure stream ready then send
    if (!await _ensureSendReady() || _dataStreamId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment done but stream not ready — please retry.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      await _sendRawPayload({
        'type': 'superchat',
        'user': _myName,
        'text': text,
        'amount': _superChatAmount,
        'ts': DateTime.now().toIso8601String(),
      });
      _log('Super Chat sent ✅');
    } catch (e) {
      _log('Super Chat stream send failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paid but message failed to send: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Step 5: show locally (Agora doesn't echo own messages)
    final msg = _ChatMessage(
      displayName: _myName,
      text: text,
      at: DateTime.now(),
      type: _SenderType.superChat,
      isSuper: true,
      superAmount: _superChatAmount,
    );

    if (mounted) {
      setState(() {
        _messages.add(msg);
        _pinnedSuperChats.insert(0, msg);
        if (_pinnedSuperChats.length > 3) _pinnedSuperChats.removeLast();
        _inputCtrl.clear();
      });
      _scrollDown();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SUPER CHAT CONFIRM DIALOG
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> _showSuperChatConfirmDialog(String text) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF12121F),
        title: Row(children: const [
          Text('⭐', style: TextStyle(fontSize: 22)),
          SizedBox(width: 8),
          Text('Super Chat',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pink preview bubble
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3A0020),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFE91E8C), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(
                      _myName,
                      style: const TextStyle(
                        color: Color(0xFFFF69B4),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E8C),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '⭐ Super Chat ₹${_superChatAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '₹${_superChatAmount.toStringAsFixed(0)} will be deducted from your wallet.',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your message will be highlighted in pink for everyone.',
              style: TextStyle(fontSize: 11, color: Colors.white38),
            ),
            const SizedBox(height: 12),
            // Wallet balance chip
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2E1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.green.shade700.withOpacity(0.5)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.account_balance_wallet,
                    color: Colors.green.shade400, size: 15),
                const SizedBox(width: 6),
                Text(
                  'Wallet: ₹${_walletBalance.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.green.shade400,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E8C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
                'Send ₹${_superChatAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ??
        false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEND GIFT
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _sendGift(GiftModel gift) async {
    if (gift.price > _walletBalance) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Insufficient balance. Please recharge your wallet.'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      throw Exception('Insufficient balance');
    }

    await FastAPIServices().sendMoney(
      astrologerId: widget.astroId,
      amount: gift.price,
      type: 'gift',
    );

    if (mounted) setState(() => _walletBalance -= gift.price);

    FastAPIServices()
        .sendNotificationToAstrologer(
      astrologerId: widget.astroId,
      title: '🎁 You received a gift!',
      body:
      '$_myName sent you ${gift.icon} ${gift.name} worth ₹${gift.price}',
      screen: 'LiveScreen',
      data: {
        'type': 'gift',
        'sender_name': _myName,
        'gift_name': gift.name,
        'gift_icon': gift.icon,
        'gift_price': gift.price.toString(),
        'astro_id': widget.astroId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    )
        .catchError((e) {
      _log('Gift notification failed (non-fatal): $e');
    });

    if (!await _ensureSendReady() || _dataStreamId == null) {
      throw Exception('Payment done but stream not ready — please retry');
    }

    await _sendRawPayload({
      'type': 'gift',
      'user': _myName,
      'gift_name': gift.name,
      'gift_icon': gift.icon,
      'gift_price': gift.price,
      'ts': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      setState(() {
        _messages.add(_ChatMessage(
          displayName: _myName,
          text: 'sent ${gift.name}',
          at: DateTime.now(),
          type: _SenderType.giftAnnounce,
          giftEmoji: gift.icon,
          giftTotal: gift.price,
        ));
      });
      _scrollDown();
      _showGiftOverlay(gift.icon);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GIFT SHEET
  // ─────────────────────────────────────────────────────────────────────────

  void _openGiftSheet() {
    context.read<GiftProvider>().getGifts();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _GiftSheet(
        onSend: (gift) async {
          await _sendGift(gift);
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SCROLL
  // ─────────────────────────────────────────────────────────────────────────

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CONSULTATION FLOW
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> _showDisclaimer() async =>
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF12121F),
          title: const Text('Disclaimer',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          content: const Text(
            'The platform is not responsible for any financial transactions '
                'conducted outside the platform with the astrologer.',
            style: TextStyle(fontSize: 14, height: 1.5, color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: appColor),
              child: const Text('I Accept',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ).then((v) => v ?? false);

  Future<void> _sendNotification(String type) async {
    if (_astrologer == null) return;
    try {
      String title, body, screen;
      switch (type.toLowerCase()) {
        case 'audio':
          title = 'Incoming Audio Call 📞';
          body = '$_myName wants audio.';
          screen = 'AudioCallScreen';
          break;
        case 'video':
          title = 'Incoming Video Call 🎥';
          body = '$_myName wants video.';
          screen = 'VideoCallScreen';
          break;
        default:
          title = 'New Chat Request 💬';
          body = '$_myName wants to chat.';
          screen = 'ChatScreen';
      }
      await FastAPIServices().sendNotificationToAstrologer(
        astrologerId: _astrologer!.astroId,
        title: title,
        body: body,
        screen: screen,
        data: {
          'client_name': _myName,
          'timestamp': DateTime.now().toIso8601String(),
          'call_type': type,
          'astro_id': _astrologer!.astroId,
        },
      );
    } catch (e) {
      _log('Notif error: $e');
    }
  }

  void _onConsultTap(String callType) async {
    if (_astrologer == null) return;
    if (!await _showDisclaimer()) return;

    final isAudio = callType.toLowerCase() == 'audio';
    final isVideo = callType.toLowerCase() == 'video';
    final rate = isAudio
        ? _astrologer!.audioCallCharge
        : isVideo
        ? _astrologer!.videoCallCharge
        : _astrologer!.chatCharge;

    final busy = ValueNotifier<bool>(false);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF12121F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 28,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 22),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isAudio
                    ? Icons.call_rounded
                    : isVideo
                    ? Icons.videocam_rounded
                    : Icons.chat_rounded,
                color: appColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$callType Consultation',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Text('with $_astrologerName',
                  style:
                  const TextStyle(fontSize: 13, color: Colors.white38)),
            ]),
          ]),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  appColor.withOpacity(0.18),
                  appColor.withOpacity(0.05)
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: appColor.withOpacity(0.25)),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (isAudio || isVideo)
                              ? 'Per 10 minutes'
                              : 'Per message',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        const Text('Estimated Charge',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 14)),
                      ]),
                  Text('₹ ${rate.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: appColor)),
                ]),
          ),
          const SizedBox(height: 12),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  size: 15, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  (isAudio || isVideo)
                      ? 'Charged for the first 10 mins; additional time in 10-min blocks.'
                      : 'Charged per message during the chat session.',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.blueAccent),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<bool>(
            valueListenable: busy,
            builder: (_, isBusy, __) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 17),
                ),
                onPressed: isBusy
                    ? null
                    : () async {
                  busy.value = true;
                  try {
                    final mapped =
                    callType.toLowerCase() == 'audio'
                        ? 'audio_call'
                        : callType.toLowerCase() == 'video'
                        ? 'video_call'
                        : 'chat';
                    await FastAPIServices().loadFromStorage();
                    final raw =
                    await FastAPIServices().createSession(
                      astrologerId: _astrologer!.astroId,
                      sessionType: mapped,
                    );
                    if (raw == null) {
                      if (sheetCtx.mounted) {
                        ScaffoldMessenger.of(sheetCtx).showSnackBar(
                            const SnackBar(
                                content:
                                Text('Failed to create session.')));
                      }
                      return;
                    }
                    await _sendNotification(callType);
                    if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                    if (mounted) _showSuccessDialog(callType);
                  } catch (e) {
                    if (sheetCtx.mounted) {
                      ScaffoldMessenger.of(sheetCtx).showSnackBar(
                          SnackBar(content: Text('Error: $e')));
                    }
                  } finally {
                    busy.value = false;
                  }
                },
                child: isBusy
                    ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isAudio
                          ? Icons.call_rounded
                          : isVideo
                          ? Icons.videocam_rounded
                          : Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    const Text('Send Request',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _showSuccessDialog(String type) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF12121F),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                  color: Color(0xFF1B3A2C), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: Color(0xFF4CAF50), size: 44),
            ),
            const SizedBox(height: 20),
            const Text('Request Sent!',
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 10),
            Text(
              'Your $type request has been sent.\nYou\'ll be notified when $_astrologerName accepts.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: Colors.white54, height: 1.65),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Continue',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLive = _hostAgoraUid != null;

    // Calculate bottom offset for chat panel depending on what's visible below it
    final double chatBottom =
    (_showConsultButtons && _astrologer != null && isLive) ? 188 : 82;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(children: [
          // ── Video / waiting screen ────────────────────────────────────────
          Positioned.fill(
            child: isLive
                ? AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: _hostAgoraUid),
                connection:
                RtcConnection(channelId: widget.channelName),
              ),
            )
                : _WaitingScreen(
              pulseAnim: _pulseAnim,
              isJoining: _joining,
              astrologerName: _astrologerName,
            ),
          ),

          // ── Top gradient ──────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 130,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xCC000000), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Bottom gradient ───────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 230,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xDD000000), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Header ────────────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: _Header(
              astrologerName: _astrologerName,
              viewerCount: _viewerCount,
              isLive: isLive,
              onBack: () => Navigator.pop(context),
            ),
          ),

          // ── Pinned Super Chat strip ───────────────────────────────────────
          if (_pinnedSuperChats.isNotEmpty)
            Positioned(
              top: 60,
              left: 14,
              right: 14,
              child: _PinnedSuperChatStrip(
                messages: _pinnedSuperChats,
                onDismiss: (msg) => setState(
                      () => _pinnedSuperChats.remove(msg),
                ),
              ),
            ),

          // ── Consult bar ───────────────────────────────────────────────────
          if (_showConsultButtons && _astrologer != null && isLive)
            Positioned(
              bottom: 82, left: 14, right: 14,
              child: _ConsultBar(
                astrologer: _astrologer!,
                onTap: _onConsultTap,
                onClose: () =>
                    setState(() => _showConsultButtons = false),
              ),
            ),

          // ── Chat panel ────────────────────────────────────────────────────
          if (_showChat && _messages.isNotEmpty)
            Positioned(
              left: 14,
              right: 14,
              bottom: chatBottom,
              child: _ChatPanel(
                messages: _messages,
                scrollCtrl: _scrollCtrl,
                onClose: () => setState(() => _showChat = false),
              ),
            ),

          // ── Input bar ─────────────────────────────────────────────────────
          Positioned(
            left: 14, right: 14, bottom: 14,
            child: _InputBar(
              showChat: _showChat,
              roleSwitching: _roleSwitching,
              superChatPaying: _superChatPaying,
              canSend: _canSend,
              inputCtrl: _inputCtrl,
              onToggleChat: () =>
                  setState(() => _showChat = !_showChat),
              onGiftTap: _openGiftSheet,
              onSend: _sendChatMessage,
              onSuperChat: _sendSuperChat,
              onInputChanged: () => setState(() {}),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PINNED SUPER CHAT STRIP
// Shows up to 3 most recent super chats just below the header.
// Tap the × to dismiss individual entries.
// ─────────────────────────────────────────────────────────────────────────────

class _PinnedSuperChatStrip extends StatelessWidget {
  final List<_ChatMessage> messages;
  final void Function(_ChatMessage) onDismiss;

  const _PinnedSuperChatStrip({
    required this.messages,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE91E8C).withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFE91E8C).withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('📌 ',
                style: TextStyle(fontSize: 10)),
            const Text('Super Chat',
                style: TextStyle(
                    color: Color(0xFFE91E8C),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4)),
          ]),
          const SizedBox(height: 5),
          ...messages.take(3).map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF3A0020),
                borderRadius: BorderRadius.circular(8),
                border:
                Border.all(color: const Color(0xFFE91E8C).withOpacity(0.4)),
              ),
              child: Row(children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: '${m.displayName}: ',
                        style: const TextStyle(
                            color: Color(0xFFFF69B4),
                            fontWeight: FontWeight.bold,
                            fontSize: 11),
                      ),
                      TextSpan(
                        text: m.text,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                    ]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '₹${m.superAmount?.toStringAsFixed(0) ?? '10'}',
                  style: const TextStyle(
                      color: Color(0xFFE91E8C),
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => onDismiss(m),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white24, size: 14),
                ),
              ]),
            ),
          )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUPER CHAT OVERLAY ANIMATION
// Big pink banner that floats up and fades out on receive
// ─────────────────────────────────────────────────────────────────────────────

class _SuperChatOverlay extends StatefulWidget {
  final String name;
  final String text;
  final double amount;
  final VoidCallback onDone;

  const _SuperChatOverlay({
    required this.name,
    required this.text,
    required this.amount,
    required this.onDone,
  });

  @override
  State<_SuperChatOverlay> createState() => _SuperChatOverlayState();
}

class _SuperChatOverlayState extends State<_SuperChatOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400));

    _slide = Tween<Offset>(
        begin: const Offset(0, 0.2), end: const Offset(0, -0.05))
        .animate(CurvedAnimation(
        parent: _ctrl, curve: const Interval(0, 0.4, curve: Curves.easeOut)));

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _ctrl, curve: const Interval(0.65, 1.0)));

    _ctrl.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 220,
      left: 20,
      right: 20,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Opacity(
            opacity: _opacity.value,
            child: SlideTransition(
              position: _slide,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E8C),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFFE91E8C).withOpacity(0.6),
                        blurRadius: 22,
                        spreadRadius: 2),
                  ],
                ),
                child: Row(children: [
                  const Text('⭐', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(widget.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '₹${widget.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 2),
                        Text(widget.text,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GIFT SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _GiftSheet extends StatefulWidget {
  final Future<void> Function(GiftModel gift) onSend;
  const _GiftSheet({required this.onSend});

  @override
  State<_GiftSheet> createState() => _GiftSheetState();
}

class _GiftSheetState extends State<_GiftSheet> {
  GiftModel? _selected;
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF12121F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 18),

        Row(children: [
          const Icon(Icons.card_giftcard_rounded,
              color: Colors.orangeAccent, size: 20),
          const SizedBox(width: 8),
          const Text('Send a Gift',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close_rounded,
                color: Colors.white38, size: 20),
          ),
        ]),
        const SizedBox(height: 18),

        Consumer<GiftProvider>(
          builder: (_, provider, __) {
            if (provider.isLoading) {
              return const SizedBox(
                height: 120,
                child: Center(
                    child: CircularProgressIndicator(
                        color: Colors.orangeAccent)),
              );
            }

            if (provider.error != null || provider.gifts.isEmpty) {
              return SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    provider.error ?? 'No gifts available',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 13),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 200,
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: provider.gifts.length,
                itemBuilder: (_, i) {
                  final gift = provider.gifts[i];
                  final isSelected = _selected?.id == gift.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = gift),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.orangeAccent.withOpacity(0.18)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? Colors.orangeAccent
                              : Colors.white.withOpacity(0.08),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(gift.icon,
                              style: const TextStyle(fontSize: 26)),
                          const SizedBox(height: 4),
                          Text(gift.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 10)),
                          const SizedBox(height: 2),
                          Text('₹${gift.price}',
                              style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
              _selected != null ? Colors.orangeAccent : Colors.white12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: (_selected == null || _sending)
                ? null
                : () async {
              setState(() => _sending = true);
              try {
                await widget.onSend(_selected!);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Failed to send gift: $e')));
                }
              } finally {
                if (mounted) setState(() => _sending = false);
              }
            },
            child: _sending
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
                : Text(
              _selected != null
                  ? 'Send ${_selected!.icon}  ₹${_selected!.price}'
                  : 'Select a gift',
              style: TextStyle(
                color: _selected != null
                    ? Colors.white
                    : Colors.white30,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GIFT OVERLAY ANIMATION
// ─────────────────────────────────────────────────────────────────────────────

class _GiftOverlay extends StatefulWidget {
  final String emoji;
  final VoidCallback onDone;

  const _GiftOverlay({required this.emoji, required this.onDone});

  @override
  State<_GiftOverlay> createState() => _GiftOverlayState();
}

class _GiftOverlayState extends State<_GiftOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _scale = Tween<double>(begin: 0.4, end: 1.2).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.4)));

    _slide = Tween<Offset>(
        begin: const Offset(0, 0.3), end: const Offset(0, -0.3))
        .animate(CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.4, 1.0)));

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _ctrl, curve: const Interval(0.65, 1.0)));

    _ctrl.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 180,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Opacity(
            opacity: _opacity.value,
            child: SlideTransition(
              position: _slide,
              child: Transform.scale(
                scale: _scale.value,
                child: Center(
                  child: Text(widget.emoji,
                      style: const TextStyle(fontSize: 72)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _WaitingScreen extends StatelessWidget {
  final Animation<double> pulseAnim;
  final bool isJoining;
  final String astrologerName;

  const _WaitingScreen({
    required this.pulseAnim,
    required this.isJoining,
    required this.astrologerName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0A15), Color(0xFF12122A), Color(0xFF0A0F1A)],
        ),
      ),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedBuilder(
            animation: pulseAnim,
            builder: (_, __) => Transform.scale(
              scale: pulseAnim.value,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      appColor.withOpacity(0.9),
                      appColor.withOpacity(0.4)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: appColor.withOpacity(0.45),
                        blurRadius: 35,
                        spreadRadius: 6)
                  ],
                ),
                child: const Icon(Icons.live_tv_rounded,
                    color: Colors.white, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            isJoining ? 'Joining live…' : 'Waiting for $astrologerName…',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text('The live session will begin shortly',
              style: TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 30),
          SizedBox(
            width: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: Colors.white10,
                color: appColor,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String astrologerName;
  final int viewerCount;
  final bool isLive;
  final VoidCallback onBack;

  const _Header({
    required this.astrologerName,
    required this.viewerCount,
    required this.isLive,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 0),
      child: Row(children: [
        _GlassBtn(
          onTap: onBack,
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(astrologerName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const Text('Live Session',
                    style: TextStyle(color: Colors.white38, fontSize: 11)),
              ]),
        ),
        if (isLive) ...[
          _GlassPill(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.remove_red_eye_outlined,
                  color: Colors.white60, size: 12),
              const SizedBox(width: 4),
              Text('$viewerCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(width: 8),
        ],
        isLive
            ? _liveBadge()
            : const _GlassPill(
          child: Text('Waiting',
              style: TextStyle(color: Colors.white38, fontSize: 11)),
        ),
      ]),
    );
  }

  Widget _liveBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
          colors: [Color(0xFFFF3B30), Color(0xFFFF6961)]),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
            color: Colors.red.withOpacity(0.45),
            blurRadius: 10,
            spreadRadius: 1)
      ],
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      const Text('LIVE',
          style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6)),
    ]),
  );
}

class _ConsultBar extends StatelessWidget {
  final Astrologer astrologer;
  final void Function(String) onTap;
  final VoidCallback onClose;

  const _ConsultBar({
    required this.astrologer,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 22,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(children: [
        Expanded(
            child: _ConsultBtn(
              icon: Icons.chat_bubble_rounded,
              label: 'Chat',
              price: '₹${astrologer.chatCharge.toStringAsFixed(0)}',
              color: const Color(0xFFFF9500),
              onTap: () => onTap('Chat'),
            )),
        _VDivider(),
        Expanded(
            child: _ConsultBtn(
              icon: Icons.call_rounded,
              label: 'Audio',
              price: '₹${astrologer.audioCallCharge.toStringAsFixed(0)}/10m',
              color: const Color(0xFF4A9EFF),
              onTap: () => onTap('Audio'),
            )),
        _VDivider(),
        Expanded(
            child: _ConsultBtn(
              icon: Icons.videocam_rounded,
              label: 'Video',
              price: '₹${astrologer.videoCallCharge.toStringAsFixed(0)}/10m',
              color: const Color(0xFF30D158),
              onTap: () => onTap('Video'),
            )),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle),
            child: const Icon(Icons.close_rounded,
                color: Colors.white30, size: 14),
          ),
        ),
      ]),
    );
  }
}

class _ConsultBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String price;
  final Color color;
  final VoidCallback onTap;

  const _ConsultBtn({
    required this.icon,
    required this.label,
    required this.price,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 5),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
        Text(price,
            style: TextStyle(
                color: color, fontSize: 9, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _ChatPanel extends StatelessWidget {
  final List<_ChatMessage> messages;
  final ScrollController scrollCtrl;
  final VoidCallback onClose;

  const _ChatPanel({
    required this.messages,
    required this.scrollCtrl,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 200,
        color: Colors.black.withOpacity(0.78),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
            color: Colors.white.withOpacity(0.04),
            child: Row(children: [
              const Icon(Icons.forum_rounded,
                  color: Colors.white38, size: 13),
              const SizedBox(width: 6),
              Text('Live Chat · ${messages.length}',
                  style:
                  const TextStyle(color: Colors.white38, fontSize: 11)),
              const Spacer(),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.white30, size: 20),
              ),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              itemCount: messages.length,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemBuilder: (_, i) =>
                  _ChatMessageTile(msg: messages[i]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ChatMessageTile extends StatelessWidget {
  final _ChatMessage msg;
  const _ChatMessageTile({required this.msg});

  @override
  Widget build(BuildContext context) {
    // ── Gift announcement row ─────────────────────────────────────────────
    if (msg.type == _SenderType.giftAnnounce) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.withOpacity(0.2)),
          ),
          child: Row(children: [
            Text(msg.giftEmoji ?? '🎁',
                style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 7),
            Expanded(
              child: Text('${msg.displayName} ${msg.text}',
                  style: const TextStyle(
                      color: Color(0xFFFFD27F),
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ),
            Text('₹${msg.giftTotal ?? 0}',
                style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      );
    }

    // ── Super Chat row (pink highlight) ───────────────────────────────────
    if (msg.type == _SenderType.superChat) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF3A0020),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE91E8C), width: 1.2),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFE91E8C).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('⭐ ', style: TextStyle(fontSize: 13)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(
                        msg.displayName,
                        style: const TextStyle(
                            color: Color(0xFFFF69B4),
                            fontWeight: FontWeight.bold,
                            fontSize: 11),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E8C),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Super Chat ₹${msg.superAmount?.toStringAsFixed(0) ?? '10'}',
                          style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 3),
                    Text(msg.text,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                '${msg.at.hour.toString().padLeft(2, '0')}:${msg.at.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.pink, fontSize: 9),
              ),
            ],
          ),
        ),
      );
    }

    // ── Normal chat row ───────────────────────────────────────────────────
    final Color nameColor;
    Widget? badge;

    switch (msg.type) {
      case _SenderType.host:
        nameColor = const Color(0xFFFFCC00);
        badge = Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.18),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('⭐ Astrologer',
              style: TextStyle(
                  color: Colors.amber,
                  fontSize: 8,
                  fontWeight: FontWeight.w700)),
        );
        break;
      case _SenderType.me:
        nameColor = const Color(0xFF4A9EFF);
        badge = null;
        break;
      default:
        nameColor = const Color(0xFF8E8E93);
        badge = null;
    }

    final time =
        '${msg.at.hour.toString().padLeft(2, '0')}:${msg.at.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Flexible(
          flex: 0,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('${msg.displayName} ',
                style: TextStyle(
                    color: nameColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
            if (badge != null) badge,
            const Text(': ',
                style: TextStyle(color: Colors.white30, fontSize: 11)),
          ]),
        ),
        Expanded(
            child: Text(msg.text,
                style: const TextStyle(color: Colors.white, fontSize: 11))),
        const SizedBox(width: 6),
        Text(time,
            style: const TextStyle(color: Colors.white24, fontSize: 9)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INPUT BAR — now with ⭐ Super Chat button
// ─────────────────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final bool showChat;
  final bool roleSwitching;
  final bool superChatPaying;
  final bool canSend;
  final TextEditingController inputCtrl;
  final VoidCallback onToggleChat;
  final VoidCallback onGiftTap;
  final VoidCallback onSend;
  final VoidCallback onSuperChat;
  final VoidCallback onInputChanged;

  const _InputBar({
    required this.showChat,
    required this.roleSwitching,
    required this.superChatPaying,
    required this.canSend,
    required this.inputCtrl,
    required this.onToggleChat,
    required this.onGiftTap,
    required this.onSend,
    required this.onSuperChat,
    required this.onInputChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool busy = roleSwitching || superChatPaying;

    return Row(children: [
      // ── Toggle chat visibility ─────────────────────────────────────────
      GestureDetector(
        onTap: onToggleChat,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Icon(
            showChat
                ? Icons.chat_rounded
                : Icons.chat_bubble_outline_rounded,
            color: showChat ? appColor : Colors.white38,
            size: 19,
          ),
        ),
      ),
      const SizedBox(width: 6),

      // ── Gift button ────────────────────────────────────────────────────
      GestureDetector(
        onTap: onGiftTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            shape: BoxShape.circle,
            border:
            Border.all(color: Colors.orangeAccent.withOpacity(0.4)),
          ),
          child: const Icon(Icons.card_giftcard_rounded,
              color: Colors.orangeAccent, size: 20),
        ),
      ),
      const SizedBox(width: 6),

      // ── Text input ─────────────────────────────────────────────────────
      Expanded(
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.94),
            borderRadius: BorderRadius.circular(22),
          ),
          child: TextField(
            controller: inputCtrl,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            onChanged: (_) => onInputChanged(),
            decoration: InputDecoration(
              hintText: busy ? 'Connecting…' : 'Say something…',
              hintStyle:
              TextStyle(color: Colors.grey.shade500, fontSize: 14),
              border: InputBorder.none,
              isDense: true,
              contentPadding:
              const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      ),
      const SizedBox(width: 6),

      // ── ⭐ Super Chat button ─────────────────────────────────────────────
      GestureDetector(
        onTap: busy ? null : onSuperChat,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: busy
                ? Colors.grey.shade800
                : const Color(0xFFE91E8C),
            shape: BoxShape.circle,
            boxShadow: busy
                ? null
                : [
              BoxShadow(
                  color: const Color(0xFFE91E8C).withOpacity(0.45),
                  blurRadius: 10,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: superChatPaying
              ? const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.white),
          )
              : const Icon(Icons.star_rounded,
              color: Colors.white, size: 20),
        ),
      ),
      const SizedBox(width: 6),

      // ── Normal send button ─────────────────────────────────────────────
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: canSend ? appColor : Colors.white12,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: busy
              ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
              : Icon(Icons.send_rounded,
              color: canSend ? Colors.white : Colors.white24,
              size: 18),
          onPressed: canSend ? onSend : null,
        ),
      ),
    ]);
  }
}

class _GlassBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _GlassBtn({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final Widget child;
  const _GlassPill({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: Colors.white.withOpacity(0.07),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

