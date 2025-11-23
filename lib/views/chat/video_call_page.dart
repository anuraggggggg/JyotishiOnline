// lib/call/customer_video_call_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../../fastApi/agora_service.dart';
import '../../fastApi/fastApiServices.dart';

class CustomerVideoCallPage extends StatefulWidget {
  final String astroId; // astrologer UID

  const CustomerVideoCallPage({
    super.key,
    required this.astroId,
  });

  @override
  State<CustomerVideoCallPage> createState() => _CustomerVideoCallPageState();
}

class _CustomerVideoCallPageState extends State<CustomerVideoCallPage> {
  late RtcEngine _engine;
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
        await _engine.leaveChannel();
      } catch (_) {}
      try {
        await _engine.release();
      } catch (_) {}
    }();

    super.dispose();
  }

  // ------------------------------------------------------------------
  // INITIALIZE CALL
  // ------------------------------------------------------------------
  Future<void> _bootstrap() async {
    try {
      // 1) Permissions
      final statuses = await [Permission.camera, Permission.microphone].request();
      if (statuses[Permission.camera] != PermissionStatus.granted ||
          statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Camera/Microphone permission denied';
      }

      // 2) Astrologer Call Rate
      final astro = await FastAPIServices().fetchAstrologerDetail(widget.astroId);
      _videoRate = astro.videoCallCharge.toDouble();

      // 3) Agora tokens
      final auth = await AgoraService.getVideoTokens(widget.astroId);
      _channel = auth.channelName;
      _token = auth.currentUserToken;
      _account = auth.currentUserId ??
          "viewer_${DateTime.now().millisecondsSinceEpoch}";

      if (_channel.isEmpty || _token.isEmpty) {
        throw "Invalid token/channel from server";
      }

      // 4) Agora Init
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: _appId));
      _engineCreated = true;

      await _engine.setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      await _engine.enableVideo();
      await _engine.startPreview();

      // ----------------------------------------------------------
      // EVENT HANDLERS
      // ----------------------------------------------------------
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (conn, elapsed) {
            setState(() => _joined = true);
          },

          onUserJoined: (conn, remoteUid, elapsed) {
            debugPrint("⭐ Astrologer joined UID = $remoteUid");

            setState(() => _remoteUid = remoteUid);
            if (!_timerStarted) {
              _startTimer();
              _timerStarted = true;
            }
          },

          onUserOffline: (conn, remoteUid, reason) {
            setState(() => _remoteUid = null);
          },
        ),
      );

      // 5) Join Agora Channel
      await _engine.joinChannelWithUserAccount(
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
    } catch (e) {
      debugPrint('💥 Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ------------------------------------------------------------------
  // TIMER
  // ------------------------------------------------------------------
  void _startTimer() {
    debugPrint("⏳ Timer started");
    _callTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        _endSession();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  // ------------------------------------------------------------------
  // AUTO END SESSION (10 minutes)
  // ------------------------------------------------------------------
  Future<void> _endSession() async {
    debugPrint("⛔ Auto-end → Deducting ₹$_videoRate");

    _callTimer?.cancel();

    try {
      await _engine.leaveChannel();
    } catch (_) {}

    // 💰 MONEY DEDUCTION
    try {
      await FastAPIServices().sendMoney(
        astrologerId: widget.astroId,
        amount: _videoRate,
        type: "video_call",
      );

      debugPrint("💰 Money deducted successfully!");

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

    // EXIT
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.pop(context);
    }
  }

  // ------------------------------------------------------------------
  // MANUAL END SESSION (End button)
  // ------------------------------------------------------------------
  Future<void> _leave() async {
    debugPrint("👋 Manual leave → Deducting ₹$_videoRate");

    _callTimer?.cancel();

    try {
      await _engine.leaveChannel();
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

  // ------------------------------------------------------------------
  // UI
  // ------------------------------------------------------------------
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
          // ---------------- REMOTE VIDEO ----------------
          Positioned.fill(
            child: _remoteUid == null
                ? Center(
              child: Text(
                _joined
                    ? "Waiting for astrologer…"
                    : "Joining…",
                style: const TextStyle(color: Colors.white70),
              ),
            )
                : AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: RtcConnection(channelId: _channel),
              ),
            ),
          ),

          // ---------------- LOCAL PIP ----------------
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
                    rtcEngine: _engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),
          ),

          // ---------------- TIMER ----------------
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

          // ---------------- END BUTTON ----------------
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
