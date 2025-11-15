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
  int? hostUid; // astrologer UID when online
  bool isInitialized = false;
  bool _joining = true;

  // 🔹 Hardcode your Agora App ID here (you already shared this)
  static const String _agoraAppId = "3a39af44074a40bebc2fff2cba7437e5";

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    try {
      debugPrint('🎥 [Viewer] initAgora() channel=${widget.channelName}');

      _engine = createAgoraRtcEngine();

      // 1) Initialize engine with valid App ID
      await _engine.initialize(
        const RtcEngineContext(
          appId: _agoraAppId,
        ),
      );

      // 2) Live Broadcast mode
      await _engine.setChannelProfile(
        ChannelProfileType.channelProfileLiveBroadcasting,
      );

      // 3) Viewer is audience (does NOT publish)
      await _engine.setClientRole(
        role: ClientRoleType.clientRoleAudience,
      );

      // 4) Enable video (only subscribe, not publish)
      await _engine.enableVideo();

      // 5) Events
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            debugPrint("🎥 [Viewer] Joined channel as audience");
            setState(() {
              isInitialized = true;
              _joining = false;
            });
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            debugPrint("⭐ [Viewer] Host joined: UID = $remoteUid");
            setState(() {
              hostUid = remoteUid; // Save host UID
            });
          },
          onUserOffline: (connection, remoteUid, reason) {
            debugPrint("⭕ [Viewer] Host left the live (uid=$remoteUid)");
            setState(() {
              hostUid = null;
            });
          },
          onError: (err, msg) {
            debugPrint('❌ [Viewer] Agora error: $err $msg');
          },
          onConnectionStateChanged:
              (RtcConnection conn, ConnectionStateType state,
              ConnectionChangedReasonType reason) {
            debugPrint(
                '🔎 [Viewer] connectionState=$state reason=$reason channel=${conn.channelId}');
          },
        ),
      );

      // 6) Join as audience, subscribe only
      await _engine.joinChannel(
        token: widget.token,
        channelId: widget.channelName,
        uid: 0, // let Agora assign UID for viewer
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleAudience,
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
    } catch (e) {
      debugPrint('💥 [Viewer] initAgora failed: $e');
      if (mounted) {
        setState(() => _joining = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Live view failed: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final waiting = hostUid == null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // MAIN VIDEO AREA
          Center(
            child: waiting
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_joining)
                  const CircularProgressIndicator(color: Colors.white),
                if (!_joining) const SizedBox.shrink(),
                const SizedBox(height: 16),
                Text(
                  "Waiting for astrologer to go live...",
                  style:
                  const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            )
                : AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: hostUid),
                connection:
                RtcConnection(channelId: widget.channelName),
              ),
            ),
          ),

          // BACK BUTTON
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
