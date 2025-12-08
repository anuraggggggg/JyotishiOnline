// lib/call/customer_video_call_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../../fastApi/agora_service.dart';
import '../../fastApi/fastApiServices.dart';

/// CustomerVideoCallPage now supports optional overrides:
/// CustomerVideoCallPage(astroId: '...', overrideRoomId: 'fa134...', overrideToken: '006...', overrideAccount: 'user_...', overrideAppId: '...')
class CustomerVideoCallPage extends StatefulWidget {
  final String astroId; // astrologer UID

  // Optional overrides provided by push or caller
  final String? overrideRoomId;   // agora channel / room id
  final String? overrideToken;    // token for this role (customer token)
  final String? overrideAccount;  // userAccount to join as
  final String? overrideAppId;    // optional appID from server

  const CustomerVideoCallPage({
    super.key,
    required this.astroId,
    this.overrideRoomId,
    this.overrideToken,
    this.overrideAccount,
    this.overrideAppId,
  });

  @override
  State<CustomerVideoCallPage> createState() => _CustomerVideoCallPageState();
}

class _CustomerVideoCallPageState extends State<CustomerVideoCallPage> {
  RtcEngine? _engine;
  bool _engineCreated = false;

  // Agora fields
  String _appId = "3a39af44074a40bebc2fff2cba7437e5";
  String _channel = '';
  String _token = '';
  String _account = '';

  bool _loading = true;
  bool _joined = false;
  int? _remoteUid;

  Timer? _callTimer;
  int _secondsLeft = 600; // 10 minutes
  bool _timerStarted = false;

  double _videoRate = 0; // ₹ per 10 minutes

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _callTimer?.cancel();

    () async {
      try {
        await _engine?.leaveChannel();
    } catch (_) {}
    try {
    await _engine?.stopPreview();
    } catch (_) {}
    try {
    await _engine?.release();
    } catch (_) {}
    }();

    super.dispose();
  }

  // ------------------------------------------------------------------
  // INITIALIZE CALL (prefer overrides provided by push)
  // ------------------------------------------------------------------
  Future<void> _bootstrap() async {
    try {
      // 1) Permissions
      final statuses = await [Permission.camera, Permission.microphone].request();
      if (statuses[Permission.camera] != PermissionStatus.granted ||
          statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Camera/Microphone permission denied';
      }

      // 2) Astrologer Call Rate (best-effort; ignore if fetch fails)
      try {
        final astro = await FastAPIServices().fetchAstrologerDetail(widget.astroId);
        _videoRate = (astro.videoCallCharge ?? 0).toDouble();
      } catch (e) {
        debugPrint("⚠️ Could not fetch astro rate: $e");
      }

      // 3) Decide join params
      final hasOverrideChannel = (widget.overrideRoomId ?? '').trim().isNotEmpty;
      final hasOverrideToken = (widget.overrideToken ?? '').trim().isNotEmpty;
      final hasOverrideAccount = (widget.overrideAccount ?? '').trim().isNotEmpty;
      final hasOverrideAppId = (widget.overrideAppId ?? '').trim().isNotEmpty;

      if (hasOverrideChannel) {
        debugPrint('🔑 [CustomerVC] Using overrides from caller/push: channel=${widget.overrideRoomId} tokenPresent=$hasOverrideToken account=${widget.overrideAccount} appId=${widget.overrideAppId}');
        _channel = widget.overrideRoomId!.trim();
        _token = widget.overrideToken?.trim() ?? '';
        _account = widget.overrideAccount?.trim() ?? '';
        _appId = widget.overrideAppId?.trim().isNotEmpty == true ? widget.overrideAppId!.trim() : _appId;
      }

      // If any critical field missing, fetch from server
      if (_channel.isEmpty || _token.isEmpty || _account.isEmpty) {
        debugPrint('🔎 [CustomerVC] Overrides incomplete or missing fields — fetching auth from server');
        final auth = await AgoraService.getVideoTokens(widget.astroId);
        _channel = _channel.isNotEmpty ? _channel : auth.channelName;
        _token = _token.isNotEmpty ? _token : auth.currentUserToken;
        _account = _account.isNotEmpty ? _account : (auth.currentUserId.isNotEmpty ? auth.currentUserId : 'viewer_${DateTime.now().millisecondsSinceEpoch}');
        _appId = _appId.isNotEmpty ? _appId : auth.appId;
      }

      // Validate
      if (_channel.isEmpty) throw 'Missing channel/room id';
      if (_token.isEmpty) debugPrint('⚠️ [CustomerVC] Token empty — server might allow tokenless join (check server).');
      if (_account.isEmpty) _account = 'viewer_${DateTime.now().millisecondsSinceEpoch}';

      // 4) Agora Init
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(appId: _appId));
      _engineCreated = true;

      await _engine!.setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      await _engine!.enableVideo();
      await _engine!.startPreview();

      // Event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (conn, elapsed) {
            debugPrint('🎉 [CustomerVC] joined channel ${conn.channelId} elapsed=${elapsed}ms');
            if (mounted) setState(() => _joined = true);
          },
          onUserJoined: (conn, remoteUid, elapsed) {
            debugPrint("⭐ Astrologer joined UID = $remoteUid");
            if (mounted) setState(() => _remoteUid = remoteUid);
            if (!_timerStarted) {
              _startTimer();
              _timerStarted = true;
            }
          },
          onUserOffline: (conn, remoteUid, reason) {
            debugPrint("👋 Astrologer offline uid=$remoteUid reason=$reason");
            if (mounted) setState(() => _remoteUid = null);
          },
          onError: (code, msg) {
            debugPrint('❗ [CustomerVC] Agora error: $code $msg');
          },
        ),
      );

      // 5) Join Agora Channel (by userAccount)
      debugPrint("➡️ [CustomerVC] joinChannelWithUserAccount(channel=$_channel, account=$_account, tokenPresent=${_token.isNotEmpty})");
      await _engine!.joinChannelWithUserAccount(
        token: _token,
        channelId: _channel,
        userAccount: _account,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
    } catch (e, st) {
      debugPrint('💥 [CustomerVC] init failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Video init failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Timer & session end methods unchanged (same as your existing code)...
  void _startTimer() {
    debugPrint("⏳ Timer started");
    _callTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        _endSession();
      } else {
        if (mounted) setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _endSession() async {
    debugPrint("⛔ Auto-end → Deducting ₹$_videoRate");
    _callTimer?.cancel();
    try {
      await _engine?.leaveChannel();
    } catch (_) {}
    try {
      await FastAPIServices().sendMoney(
        astrologerId: widget.astroId,
        amount: _videoRate,
        type: "video_call",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("₹$_videoRate has been deducted for the video session"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("💥 Deduction failed: $e");
    }
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.pop(context);
    }
  }

  Future<void> _leave() async {
    debugPrint("👋 Manual leave → Deducting ₹$_videoRate");
    _callTimer?.cancel();
    try {
      await _engine?.leaveChannel();
    } catch (_) {}
    try {
      await FastAPIServices().sendMoney(
        astrologerId: widget.astroId,
        amount: _videoRate,
        type: "video_call",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("₹$_videoRate has been deducted for the video session"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (_) {}
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, "0");
    final seconds = (_secondsLeft % 60).toString().padLeft(2, "0");

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Video Call (Customer)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(
            child: _remoteUid == null
                ? Center(
              child: Text(
                _joined ? "Waiting for astrologer…" : "Joining…",
                style: const TextStyle(color: Colors.white70),
              ),
            )
                : AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine!,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: RtcConnection(channelId: _channel),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            width: 120,
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.black54,
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$minutes:$seconds",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: _leave,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
