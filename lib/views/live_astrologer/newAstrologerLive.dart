import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class LiveViewerPage extends StatefulWidget {
  final String channelName;
  final String token;
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

class _LiveViewerPageState extends State<LiveViewerPage> {
  late RtcEngine _engine;

  int? hostUid;               // Stores astrologer UID when live
  bool _joining = true;       // First-time join loader
  bool isInitialized = false; // Engine ready flag

  // 🔹 Static Agora App ID (customer side uses static AppID)
  static const String _agoraAppId = "3a39af44074a40bebc2fff2cba7437e5";

  @override
  void initState() {
    super.initState();
    _initAgoraEngine();
  }

  // ---------------------------------------------------------------------------
  // 🔥 1. Initialize Agora Engine + Join Channel
  // ---------------------------------------------------------------------------
  Future<void> _initAgoraEngine() async {
    try {
      debugPrint(
          "🎥 [Viewer] Initializing Agora\n"
              "→ channel: ${widget.channelName}\n"
              "→ token: ${widget.token.substring(0, 10)}...\n"
              "→ astroId: ${widget.astroId}"
      );

      // Create engine
      _engine = createAgoraRtcEngine();

      // ENGINE INIT
      await _engine.initialize(
        const RtcEngineContext(appId: _agoraAppId),
      );
      debugPrint("✅ [Viewer] Engine initialized");

      // SET CHANNEL PROFILE
      await _engine.setChannelProfile(
        ChannelProfileType.channelProfileLiveBroadcasting,
      );

      // VIEWER IS AUDIENCE (NO PUBLISHING)
      await _engine.setClientRole(
        role: ClientRoleType.clientRoleAudience,
      );

      // Enable video
      await _engine.enableVideo();

      // REGISTER EVENT HANDLER
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            debugPrint("🎉 [Viewer] Joined channel as AUDIENCE in ${elapsed}ms");
            setState(() {
              _joining = false;
              isInitialized = true;
            });
          },

          onUserJoined: (connection, remoteUid, elapsed) {
            debugPrint("⭐ [Viewer] Host joined → UID=$remoteUid");
            setState(() => hostUid = remoteUid);
          },

          onUserOffline: (connection, remoteUid, reason) {
            debugPrint(
                "⭕ [Viewer] Host offline → uid=$remoteUid reason=$reason");
            setState(() => hostUid = null);
          },

          onConnectionStateChanged:
              (RtcConnection conn, ConnectionStateType state,
              ConnectionChangedReasonType reason) {
            debugPrint(
                "🔎 [Viewer] Connection state changed → $state (reason: $reason)");
          },

          onError: (err, msg) {
            debugPrint("❌ [Viewer] Agora ERROR $err → $msg");
          },
        ),
      );

      // JOIN CHANNEL
      debugPrint("📡 [Viewer] Joining channel…");
      await _engine.joinChannel(
        token: widget.token,
        channelId: widget.channelName,
        uid: 0, // Audience = UID auto-assigned
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleAudience,
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
    } catch (e) {
      debugPrint("💥 [Viewer] initAgora FAILED → $e");
      if (mounted) {
        setState(() => _joining = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Live failed: $e')));
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 🔥 2. Cleanup Agora resources
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    debugPrint("🧹 [Viewer] Disposing viewer engine…");
    () async {
      try {
        await _engine.leaveChannel();
        debugPrint("↩️ [Viewer] Left channel");
      } catch (_) {}
      try {
        await _engine.release();
        debugPrint("🧹 [Viewer] Engine released");
      } catch (_) {}
    }();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 🔥 3. UI Rendering
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final waitingForHost = hostUid == null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🔹 MAIN VIEW AREA
          Center(
            child: waitingForHost
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_joining)
                  const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  "Waiting for astrologer to go live…",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            )
                : AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: hostUid),
                connection: RtcConnection(
                  channelId: widget.channelName,
                ),
              ),
            ),
          ),

          // 🔹 BACK BUTTON
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
