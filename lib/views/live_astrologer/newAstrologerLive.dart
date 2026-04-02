// lib/views/LiveViewerPage.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../../fastApi/fastApiServices.dart';
import '../../model/fastApiModel/astrologerProfileModel.dart';
import '../../theme/appTheme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────

enum _SenderType { me, host, viewer }

class _Comment {
  final String displayName;
  final String text;
  final DateTime at;
  final _SenderType type;

  _Comment({
    required this.displayName,
    required this.text,
    required this.at,
    required this.type,
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

  /// My own random Agora UID.
  late final int _myUid;

  /// The Agora UID of the astrologer/host — locked on first publish.
  int? _hostAgoraUid;

  int?  _dataStreamId;
  bool  _isBroadcaster = false;
  bool  _roleSwitching  = false;
  bool  _joining        = true;
  bool  _sessionEnded   = false;

  // ── Profile ────────────────────────────────────────────────────────────────
  String      _myName         = "You";
  String      _astrologerName = "Astrologer";
  Astrologer? _astrologer;

  // ── Stats ──────────────────────────────────────────────────────────────────
  int _viewerCount     = 0;
  int _lastViewerCount = 0;

  // ── Chat ───────────────────────────────────────────────────────────────────
  final Map<int, String> _uidNameCache = {};
  final Map<String, List<String?>> _recvParts = {};
  final Map<String, int>           _recvTotal  = {};

  final List<_Comment>       _comments = [];
  final ScrollController     _scrollCtrl = ScrollController();
  final TextEditingController _inputCtrl  = TextEditingController();

  bool _showChat           = true;
  bool _showConsultButtons = true;

  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  bool get _canSend =>
      !_joining && !_roleSwitching && _inputCtrl.text.trim().isNotEmpty;

  void _log(Object m) => debugPrint("🧭 [LiveViewer] $m");

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _myUid = Random().nextInt(900000) + 100000;

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _loadProfile();
    _initRTC();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    try {
      _engine.leaveChannel();
      _engine.release();
    } catch (_) {}
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DATA
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    try {
      final svc  = FastAPIServices();
      final user = await svc.fetchCurrentUserDetails();
      _myName = (user.name?.trim().isNotEmpty ?? false)
          ? user.name!.trim()
          : "Guest";

      final astro   = await svc.fetchAstrologerDetail(widget.astroId);
      _astrologer   = astro;
      _astrologerName = astro.name.trim();
      if (mounted) setState(() {});
    } catch (e) {
      _log("Profile error: $e");
      if (mounted) setState(() {});
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AGORA
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _initRTC() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: _agoraAppId));

    _engine.registerEventHandler(RtcEngineEventHandler(

      onJoinChannelSuccess: (connection, elapsed) {
        _log("Joined uid=$_myUid");
        if (mounted) setState(() => _joining = false);
      },

      // Only record the FIRST broadcaster as the host.
      // Viewers who temporarily switch to Broadcaster to send a data-stream
      // message also fire onUserJoined — we deliberately ignore them.
      onUserJoined: (connection, uid, elapsed) {
        _log("onUserJoined uid=$uid  hostAlreadySet=${_hostAgoraUid != null}");
        if (_hostAgoraUid == null && mounted) {
          setState(() => _hostAgoraUid = uid);
          _log("Host locked → $uid");
        }
      },

      // Only end the session when THE HOST goes offline.
      onUserOffline: (connection, uid, reason) {
        _log("onUserOffline uid=$uid reason=$reason  host=$_hostAgoraUid");
        if (uid == _hostAgoraUid && mounted && !_sessionEnded) {
          setState(() => _hostAgoraUid = null);
          _onHostLeft();
        }
      },

      onRtcStats: (connection, stats) {
        if (!mounted) return;
        final total   = stats.userCount ?? 0;
        final viewers = total > 1 ? total - 1 : 0;
        if (viewers != _lastViewerCount) {
          setState(() {
            _viewerCount     = viewers;
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
        _handleIncomingChunk(uid, data);
      },

      onError: (err, msg) {
        _log("Agora error $err – $msg");
        if (err == ErrorCodeType.errInvalidToken && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Session expired. Please rejoin.'),
            backgroundColor: Colors.red,
          ));
        }
      },
    ));

    await _engine.setChannelProfile(
        ChannelProfileType.channelProfileLiveBroadcasting);
    await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await _engine.enableVideo();

    // Hard-mute from the very start — never publish mic/camera.
    await _engine.enableLocalAudio(false);
    await _engine.enableLocalVideo(false);
    await _engine.muteLocalAudioStream(true);
    await _engine.muteLocalVideoStream(true);

    // ✅ THE KEY FIX:
    // audienceLatencyLevelUltraLowLatency makes this viewer a real RTC
    // participant. This is what causes onUserJoined / onUserOffline to fire
    // on the HOST side the moment we enter or leave the channel.
    //
    // Without this (default = audienceLatencyLevelLowLatency), the viewer
    // is treated as a passive CDN consumer — the host NEVER sees them join,
    // so the watching count only updates when a message is sent (which
    // temporarily switches the role to Broadcaster).
    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: _myUid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        // ✅ This single line is what makes the host's onUserJoined fire.
        audienceLatencyLevel:
        AudienceLatencyLevelType.audienceLatencyLevelUltraLowLatency,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        // Ensure we never accidentally publish anything
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
    try { _engine.leaveChannel(); } catch (_) {}

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: const Color(0xFF12121F),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 76, height: 76,
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
              const Text("Session Ended",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 10),
              Text(
                "$_astrologerName has ended the live session.\nThank you for watching! 🙏",
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
                  child: const Text("Go Back",
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
  // INCOMING CHAT
  // ─────────────────────────────────────────────────────────────────────────

  Uint8List _trimNulls(Uint8List b) {
    int s = 0, e = b.length;
    while (s < e && b[s] == 0) s++;
    while (e > s && b[e - 1] == 0) e--;
    return b.sublist(s, e);
  }

  void _handleIncomingChunk(int senderUid, Uint8List data) {
    try {
      final envelope =
      jsonDecode(utf8.decode(_trimNulls(Uint8List.fromList(data))));
      final m = envelope["m"];
      final d = envelope["d"];
      if (m == null || d == null) return;

      final id    = m["id"] as String;
      final part  = m["part"] as int;
      final total = m["total"] as int;

      _recvParts.putIfAbsent(id, () => List<String?>.filled(total, null));
      _recvParts[id]![part] = d as String;
      if (_recvParts[id]!.any((p) => p == null)) return;

      final combined = <int>[];
      for (final p in _recvParts[id]!) {
        combined.addAll(base64.decode(p!));
      }
      _recvParts.remove(id);

      final obj = jsonDecode(utf8.decode(combined)) as Map<String, dynamic>;

      final String      senderName;
      final _SenderType senderType;

      if (senderUid == _hostAgoraUid) {
        senderName = _astrologerName;
        senderType = _SenderType.host;
      } else {
        final payloadName = (obj["user"] as String?)?.trim() ?? "";
        senderName = _uidNameCache.putIfAbsent(
          senderUid,
              () => payloadName.isNotEmpty ? payloadName : "Viewer",
        );
        senderType = _SenderType.viewer;
      }

      if (mounted) {
        setState(() {
          _comments.add(_Comment(
            displayName: senderName,
            text: obj["text"] as String? ?? "",
            at  : DateTime.now(),
            type: senderType,
          ));
        });
        _scrollDown();
      }
    } catch (e) {
      _log("Chunk error: $e");
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SENDING
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> _ensureSendReady() async {
    if (_isBroadcaster && _dataStreamId != null) return true;
    if (_roleSwitching) return false;

    if (mounted) setState(() => _roleSwitching = true);
    try {
      // Mute BEFORE switching so Agora never opens the mic/camera.
      await _engine.muteLocalAudioStream(true);
      await _engine.muteLocalVideoStream(true);
      await _engine.enableLocalAudio(false);
      await _engine.enableLocalVideo(false);

      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await Future.delayed(const Duration(milliseconds: 350));

      // Double-mute after role switch (Agora re-enables publishing flags).
      await _engine.muteLocalAudioStream(true);
      await _engine.muteLocalVideoStream(true);

      _dataStreamId = await _engine.createDataStream(
          const DataStreamConfig(syncWithAudio: false, ordered: true));
      _isBroadcaster = true;
      _log("Stream ready id=$_dataStreamId (mic/cam muted)");
      return true;
    } catch (e) {
      _log("ensureSendReady failed: $e");
      try {
        await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
      } catch (_) {}
      _isBroadcaster = false;
      _dataStreamId  = null;
      return false;
    } finally {
      if (mounted) setState(() => _roleSwitching = false);
    }
  }

  Future<void> _sendMessage([String? override]) async {
    final text = (override ?? _inputCtrl.text).trim();
    if (text.isEmpty) return;

    if (!await _ensureSendReady() || _dataStreamId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not send. Please try again.")));
      }
      return;
    }

    try {
      final payloadBytes = utf8.encode(jsonEncode({
        "user": _myName,
        "text": text,
        "ts"  : DateTime.now().toIso8601String(),
      }));

      final msgId   = "${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}";
      const chunkSz = 900;
      final total   = ((payloadBytes.length + chunkSz - 1) / chunkSz).ceil();

      int sent = 0, part = 0;
      while (sent < payloadBytes.length) {
        final take   = min(chunkSz, payloadBytes.length - sent);
        final chunk  = payloadBytes.sublist(sent, sent + take);
        final packet = utf8.encode(jsonEncode({
          "m": {"id": msgId, "part": part, "total": total},
          "d": base64.encode(chunk),
        }));
        await _engine.sendStreamMessage(
          streamId: _dataStreamId!,
          data    : Uint8List.fromList(packet),
          length  : packet.length,
        );
        sent += take;
        part++;
        if (part < total) await Future.delayed(const Duration(milliseconds: 5));
      }

      if (mounted) {
        setState(() {
          _comments.add(_Comment(
            displayName: _myName,
            text: text,
            at  : DateTime.now(),
            type: _SenderType.me,
          ));
        });
        _inputCtrl.clear();
        _scrollDown();
      }
    } catch (e) {
      _log("Send error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Send failed: $e")));
      }
    }
  }

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

  Future<bool> _disclaimer() async =>
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF12121F),
          title: const Text("Disclaimer",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          content: const Text(
            "The platform is not responsible for any financial transactions "
                "conducted outside the platform with the astrologer.",
            style: TextStyle(fontSize: 14, height: 1.5, color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: appColor),
              child: const Text("I Accept",
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
          title = "Incoming Audio Call 📞"; body = "$_myName wants audio."; screen = "AudioCallScreen"; break;
        case 'video':
          title = "Incoming Video Call 🎥"; body = "$_myName wants video."; screen = "VideoCallScreen"; break;
        default:
          title = "New Chat Request 💬"; body = "$_myName wants to chat."; screen = "ChatScreen";
      }
      await FastAPIServices().sendNotificationToAstrologer(
        astrologerId: _astrologer!.astroId,
        title: title, body: body, screen: screen,
        data: {
          "client_name": _myName,
          "timestamp"  : DateTime.now().toIso8601String(),
          "call_type"  : type,
          "astro_id"   : _astrologer!.astroId,
        },
      );
    } catch (e) { _log("Notif error: $e"); }
  }

  void _onConsultTap(String callType) async {
    if (_astrologer == null) return;
    if (!await _disclaimer()) return;

    final isAudio = callType.toLowerCase() == 'audio';
    final isVideo = callType.toLowerCase() == 'video';
    final rate    = isAudio
        ? _astrologer!.audioCallCharge
        : isVideo ? _astrologer!.videoCallCharge : _astrologer!.chatCharge;

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
          left: 24, right: 24, top: 20,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 28,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
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
                isAudio ? Icons.call_rounded : isVideo ? Icons.videocam_rounded : Icons.chat_rounded,
                color: appColor, size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("$callType Consultation",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              Text("with ${_astrologer!.name}",
                  style: const TextStyle(fontSize: 13, color: Colors.white38)),
            ]),
          ]),
          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [appColor.withOpacity(0.18), appColor.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: appColor.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    (isAudio || isVideo) ? "Per 10 minutes" : "Per message",
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  const Text("Estimated Charge",
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ]),
                Text("₹ ${rate.toStringAsFixed(0)}",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: appColor)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, size: 15, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  (isAudio || isVideo)
                      ? "Charged for the first 10 mins; additional time in 10-min blocks."
                      : "Charged per message during the chat session.",
                  style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
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
                onPressed: isBusy ? null : () async {
                  busy.value = true;
                  try {
                    final mapped = callType.toLowerCase() == "audio"
                        ? "audio_call"
                        : callType.toLowerCase() == "video"
                        ? "video_call"
                        : "chat";
                    await FastAPIServices().loadFromStorage();
                    final raw = await FastAPIServices().createSession(
                      astrologerId: _astrologer!.astroId,
                      sessionType : mapped,
                    );
                    if (raw == null) {
                      if (sheetCtx.mounted) {
                        ScaffoldMessenger.of(sheetCtx).showSnackBar(
                            const SnackBar(content: Text("Failed to create session.")));
                      }
                      return;
                    }
                    await _sendNotification(callType);
                    if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();
                    if (mounted) _showSuccessDialog(callType);
                  } catch (e) {
                    if (sheetCtx.mounted) {
                      ScaffoldMessenger.of(sheetCtx)
                          .showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  } finally {
                    busy.value = false;
                  }
                },
                child: isBusy
                    ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(
                    isAudio ? Icons.call_rounded : isVideo ? Icons.videocam_rounded : Icons.send_rounded,
                    color: Colors.white, size: 18,
                  ),
                  const SizedBox(width: 10),
                  const Text("Send Request",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ]),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF12121F),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 76, height: 76,
              decoration: const BoxDecoration(
                  color: Color(0xFF1B3A2C), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: Color(0xFF4CAF50), size: 44),
            ),
            const SizedBox(height: 20),
            const Text("Request Sent!",
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 10),
            Text(
              "Your $type request has been sent.\nYou'll be notified when $_astrologerName accepts.",
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
                child: const Text("Continue",
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

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(children: [

          // ── VIDEO / WAITING ──────────────────────────────────────────────
          Positioned.fill(
            child: isLive
                ? AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas   : VideoCanvas(uid: _hostAgoraUid),
                connection: RtcConnection(channelId: widget.channelName),
              ),
            )
                : _waitingScreen(),
          ),

          // ── TOP GRADIENT SCRIM ───────────────────────────────────────────
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

          // ── BOTTOM GRADIENT SCRIM ────────────────────────────────────────
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

          // ── HEADER ──────────────────────────────────────────────────────
          Positioned(top: 0, left: 0, right: 0,
              child: _header(isLive)),

          // ── CONSULT BUTTONS ──────────────────────────────────────────────
          if (_showConsultButtons && _astrologer != null && isLive)
            Positioned(
              bottom: 82, left: 14, right: 14,
              child: _consultBar(),
            ),

          // ── CHAT PANEL ───────────────────────────────────────────────────
          if (_showChat && _comments.isNotEmpty)
            Positioned(
              left: 14, right: 14,
              bottom: (_showConsultButtons && _astrologer != null && isLive)
                  ? 188
                  : 82,
              child: _chatPanel(),
            ),

          // ── INPUT BAR ────────────────────────────────────────────────────
          Positioned(
            left: 14, right: 14, bottom: 14,
            child: _inputBar(),
          ),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WIDGET BUILDERS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _waitingScreen() => Container(
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
          animation: _pulseAnim,
          builder: (_, __) => Transform.scale(
            scale: _pulseAnim.value,
            child: Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [appColor.withOpacity(0.9), appColor.withOpacity(0.4)],
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
          _joining ? "Joining live…" : "Waiting for $_astrologerName…",
          style: const TextStyle(
              color: Colors.white, fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text("The live session will begin shortly",
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

  Widget _header(bool isLive) => Padding(
    padding: const EdgeInsets.fromLTRB(10, 8, 12, 0),
    child: Row(children: [
      _glassBtn(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 17),
      ),
      const SizedBox(width: 10),

      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_astrologerName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const Text("Live Session",
              style: TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      )),

      if (isLive) ...[
        _glassPill(child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.remove_red_eye_outlined,
              color: Colors.white60, size: 12),
          const SizedBox(width: 4),
          Text("$_viewerCount",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ])),
        const SizedBox(width: 8),
      ],

      isLive ? _liveBadge() : _glassPill(
        child: const Text("Waiting",
            style: TextStyle(color: Colors.white38, fontSize: 11)),
      ),
    ]),
  );

  Widget _consultBar() => Container(
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
      Expanded(child: _consultBtn(
        icon: Icons.chat_bubble_rounded,
        label: "Chat",
        price: "₹${_astrologer!.chatCharge.toStringAsFixed(0)}",
        color: const Color(0xFFFF9500),
        onTap: () => _onConsultTap("Chat"),
      )),
      _vDivider(),
      Expanded(child: _consultBtn(
        icon: Icons.call_rounded,
        label: "Audio",
        price: "₹${_astrologer!.audioCallCharge.toStringAsFixed(0)}/10m",
        color: const Color(0xFF4A9EFF),
        onTap: () => _onConsultTap("Audio"),
      )),
      _vDivider(),
      Expanded(child: _consultBtn(
        icon: Icons.videocam_rounded,
        label: "Video",
        price: "₹${_astrologer!.videoCallCharge.toStringAsFixed(0)}/10m",
        color: const Color(0xFF30D158),
        onTap: () => _onConsultTap("Video"),
      )),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: () => setState(() => _showConsultButtons = false),
        child: Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              shape: BoxShape.circle),
          child: const Icon(Icons.close_rounded,
              color: Colors.white30, size: 14),
        ),
      ),
    ]),
  );

  Widget _chatPanel() => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: Container(
      height: 200,
      color: Colors.black.withOpacity(0.78),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
          color: Colors.white.withOpacity(0.04),
          child: Row(children: [
            const Icon(Icons.forum_rounded, color: Colors.white38, size: 13),
            const SizedBox(width: 6),
            Text("Live Chat · ${_comments.length}",
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _showChat = false),
              child: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.white30, size: 20),
            ),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            itemCount: _comments.length,
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemBuilder: (_, i) => _CommentTile(c: _comments[i]),
          ),
        ),
      ]),
    ),
  );

  Widget _inputBar() => Row(children: [
    GestureDetector(
      onTap: () => setState(() => _showChat = !_showChat),
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(
          _showChat ? Icons.chat_rounded : Icons.chat_bubble_outline_rounded,
          color: _showChat ? appColor : Colors.white38,
          size: 19,
        ),
      ),
    ),
    const SizedBox(width: 8),

    Expanded(
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(22),
        ),
        child: TextField(
          controller: _inputCtrl,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _sendMessage(),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: _roleSwitching ? "Connecting…" : "Say something…",
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
    ),
    const SizedBox(width: 8),

    AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: _canSend ? appColor : Colors.white12,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: _roleSwitching
            ? const SizedBox(width: 18, height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.white))
            : Icon(Icons.send_rounded,
            color: _canSend ? Colors.white : Colors.white24,
            size: 18),
        onPressed: _canSend ? _sendMessage : null,
      ),
    ),
  ]);

  // ── Micro widgets ──────────────────────────────────────────────────────────

  Widget _glassBtn({required Widget child, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Center(child: child),
        ),
      );

  Widget _glassPill({required Widget child}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    ),
    child: child,
  );

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
      Container(width: 6, height: 6,
          decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      const Text("LIVE",
          style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6)),
    ]),
  );

  Widget _vDivider() => Container(
    width: 1, height: 38,
    color: Colors.white.withOpacity(0.07),
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );

  Widget _consultBtn({
    required IconData icon,
    required String label,
    required String price,
    required Color color,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 42, height: 42,
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

// ─────────────────────────────────────────────────────────────────────────────
// COMMENT TILE
// ─────────────────────────────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final _Comment c;
  const _CommentTile({required this.c});

  @override
  Widget build(BuildContext context) {
    final Color nameColor;
    Widget? badge;

    switch (c.type) {
      case _SenderType.host:
        nameColor = const Color(0xFFFFCC00);
        badge = Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.18),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text("⭐ Astrologer",
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
      case _SenderType.viewer:
        nameColor = const Color(0xFF8E8E93);
        badge = null;
    }

    final time =
        "${c.at.hour.toString().padLeft(2, '0')}:${c.at.minute.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Flexible(
          flex: 0,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text("${c.displayName} ",
                style: TextStyle(
                    color: nameColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
            if (badge != null) badge,
            const Text(": ",
                style: TextStyle(color: Colors.white30, fontSize: 11)),
          ]),
        ),
        Expanded(
          child: Text(c.text,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ),
        const SizedBox(width: 6),
        Text(time,
            style: const TextStyle(color: Colors.white24, fontSize: 9)),
      ]),
    );
  }
}