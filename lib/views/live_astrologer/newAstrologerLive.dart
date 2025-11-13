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

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    _engine = createAgoraRtcEngine();

    await _engine.initialize(RtcEngineContext(
      appId: "YOUR_AGORA_APP_ID", // TODO: <==== Put your App ID here
    ));

    // Event Handlers
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          print("🎥 Joined channel as audience");
          setState(() {
            isInitialized = true;
          });
        },

        onUserJoined: (connection, remoteUid, elapsed) {
          print("⭐ Host joined: UID = $remoteUid");
          setState(() {
            hostUid = remoteUid; // Save host UID
          });
        },

        onUserOffline: (connection, remoteUid, reason) {
          print("⭕ Host left the live");
          setState(() {
            hostUid = null;
          });
        },
      ),
    );

    await _engine.enableVideo();

    // Viewer joins as audience
    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: 0, // audience does not need unique UID
      options: ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
      ),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          // MAIN VIDEO AREA
          Center(
            child: hostUid != null
                ? AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: hostUid),
                connection: RtcConnection(channelId: widget.channelName),
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  "Waiting for astrologer to go live...",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),

          // BACK BUTTON
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
