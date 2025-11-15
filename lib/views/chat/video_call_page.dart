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

  String _appId = "3a39af44074a40bebc2fff2cba7437e5";   // ✔ Hardcoded APP ID
  String _channel = '';
  String _token = '';
  String _account = '';  // viewer ID

  bool _loading = true;
  bool _joined = false;
  int? _remoteUid;

  Timer? _pulse;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _pulse?.cancel();
    () async {
      try { await _engine.leaveChannel(); } catch (_) {}
      try { await _engine.release(); } catch (_) {}
    }();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    debugPrint('📲 [CustomerVC] bootstrap() astroId=${widget.astroId}');

    try {
      // 🔐 Permissions
      final statuses = await [Permission.camera, Permission.microphone].request();
      if (statuses[Permission.camera] != PermissionStatus.granted ||
          statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Camera/Microphone permission denied';
      }

      // 🌐 Fetch LIVE JOIN TOKEN (Customer / Audience API)
      final auth = await AgoraService.getVideoTokens(widget.astroId);

      _channel = auth.channelName;
      _token = auth.currentUserToken;

      // Viewer ID (API does not return it → generate locally)
      _account = auth.currentUserId ??
          "viewer_${DateTime.now().millisecondsSinceEpoch}";

      debugPrint("APP ID: $_appId");
      debugPrint("CHANNEL: $_channel");
      debugPrint("TOKEN: $_token");
      debugPrint("ACCOUNT: $_account");

      if (_channel.isEmpty || _token.isEmpty) {
        throw "Missing channel/token from API.";
      }

      // 🧠 Initialize Agora Engine
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: _appId));
      _engineCreated = true;

      // ⭐ LIVE MODE (host + audience)
      await _engine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);

      // ⭐ CUSTOMER IS AUDIENCE (just watching)
      await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);

      // Enable video (creates renderer)
      await _engine.enableVideo();

      // 🎧 Event Listeners
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (conn, elapsed) {
            debugPrint("🎉 Joined channel successfully");
            setState(() => _joined = true);
          },
          onUserJoined: (conn, remoteUid, elapsed) {
            debugPrint("👋 Host UID joined = $remoteUid");
            setState(() => _remoteUid = remoteUid);
          },
          onUserOffline: (conn, remoteUid, reason) {
            setState(() => _remoteUid = null);
          },
        ),
      );

      // ⭐ JOIN as AUDIENCE (Do NOT publish audio/video)
      await _engine.joinChannelWithUserAccount(
        token: _token,
        channelId: _channel,
        userAccount: _account,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleAudience,
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );

      // Debug timer
      _pulse = Timer.periodic(
        Duration(seconds: 6),
            (_) => debugPrint("💓 Audience heartbeat | remoteUid=$_remoteUid"),
      );

    } catch (e) {
      debugPrint('💥 CustomerVC error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _leave() async {
    try {
      await _engine.leaveChannel();
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Live Video (Customer)', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Remote Video (HOST)
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

          // CALL END BUTTON
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
