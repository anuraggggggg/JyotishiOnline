// lib/call/customer_video_call_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../fastApi/agora_service.dart';

class CustomerVideoCallPage extends StatefulWidget {
  final String astroId;

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

  String _appId = "3a39af44074a40bebc2fff2cba7437e5";
  String _channel = '';
  String _token = '';
  String _account = '';

  bool _loading = true;
  bool _joined = false;
  int? _remoteUid;

  Timer? _pulse;
  Timer? _callTimer;

  int _secondsLeft = 600;      // 🔥 10 mins total
  bool _timerStarted = false;  // 🔥 Start only when astrologer joins

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _pulse?.cancel();
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

  /// ---------------- INIT CALL ----------------
  Future<void> _bootstrap() async {
    try {
      final statuses =
      await [Permission.camera, Permission.microphone].request();

      if (statuses[Permission.camera] != PermissionStatus.granted ||
          statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Camera/Microphone permission denied';
      }

      final auth = await AgoraService.getVideoTokens(widget.astroId);

      _channel = auth.channelName;
      _token = auth.currentUserToken;
      _account = auth.currentUserId ??
          "viewer_${DateTime.now().millisecondsSinceEpoch}";

      if (_channel.isEmpty || _token.isEmpty) {
        throw "Missing channel/token from API.";
      }

      // Agora engine setup
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: _appId));
      _engineCreated = true;

      await _engine.setChannelProfile(
        ChannelProfileType.channelProfileCommunication,
      );

      await _engine.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster,
      );

      await _engine.enableVideo();
      await _engine.startPreview();

      // -------- EVENT HANDLERS ----------
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (conn, elapsed) {
            setState(() => _joined = true);
          },

          // 🔥 START TIMER WHEN ASTROLOGER JOINS
          onUserJoined: (conn, remoteUid, elapsed) {
            debugPrint("⭐ Astrologer joined = $remoteUid");
            setState(() => _remoteUid = remoteUid);

            if (!_timerStarted) {
              _startTimer();   // START TIMER HERE 🔥
              _timerStarted = true;
            }
          },

          onUserOffline: (conn, remoteUid, reason) {
            setState(() => _remoteUid = null);
          },
        ),
      );

      // -------- JOIN --------
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

  /// ---------------- TIMER START ----------------
  void _startTimer() {
    debugPrint("⏳ Timer started");

    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        _endSession();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  /// ---------------- AUTO END ----------------
  Future<void> _endSession() async {
    debugPrint("⛔ CALL AUTO ENDED");
    _callTimer?.cancel();

    try {
      await _engine.leaveChannel();
    } catch (_) {}

    if (mounted) {
      Navigator.pop(context); // Go back
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session ended (10 minutes over).")));
    }
  }

  Future<void> _leave() async {
    _callTimer?.cancel();
    try {
      await _engine.leaveChannel();
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  /// ---------------- UI ----------------
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
          // REMOTE VIDEO ======================
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
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: RtcConnection(channelId: _channel),
              ),
            ),
          ),

          // LOCAL VIDEO PiP ==================
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

          // ⏳ TIMER DISPLAY ==================
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$minutes:$seconds",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // END CALL BUTTON ==================
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
