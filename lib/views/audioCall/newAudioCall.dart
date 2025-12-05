// lib/call/audio_call_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../fastApi/agora_service.dart';

class AudioCallPage extends StatefulWidget {
  final String otherUserId;  // astrologer ID

  const AudioCallPage({super.key, required this.otherUserId});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  RtcEngine? _engine;

  String appId = "";
  String channel = "";
  String token = "";
  String account = "";

  bool loading = true;
  bool joined = false;
  int? remoteUid;

  Duration remaining = Duration(minutes: 10);
  Timer? ticker;

  @override
  void initState() {
    super.initState();
    initCall();
  }

  @override
  void dispose() {
    ticker?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  Future<void> initCall() async {
    try {
      await Permission.microphone.request();

      // 🔥 Fetch correct AUDIO token
      final voice = await AgoraService.getVoiceToken(widget.otherUserId);

      appId = voice.appId;
      channel = voice.channelName;
      token = voice.token;
      account = voice.userAccount; // MUST MATCH BACKEND

      final engine = createAgoraRtcEngine();
      await engine.initialize(RtcEngineContext(appId: appId));
      await engine.enableAudio();
      await engine.disableVideo();
      await engine.setDefaultAudioRouteToSpeakerphone(true);

      _engine = engine;

      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (_, __) {
            setState(() => joined = true);
            startTimer();
          },
          onUserJoined: (_, uid, __) {
            setState(() => remoteUid = uid);
          },
          onUserOffline: (_, __, ___) {
            setState(() => remoteUid = null);
          },
        ),
      );

      await engine.registerLocalUserAccount(
        appId: appId,
        userAccount: account,
      );

      await engine.joinChannelWithUserAccount(
        token: token,
        channelId: channel,
        userAccount: account,
        options: const ChannelMediaOptions(
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
          autoSubscribeAudio: true,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void startTimer() {
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        remaining -= const Duration(seconds: 1);
        if (remaining <= Duration.zero) leave();
      });
    });
  }

  Future<void> leave() async {
    await _engine?.leaveChannel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mm = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: const Text("Audio Call")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone_in_talk, size: 90),
          const SizedBox(height: 10),
          Text(remoteUid == null ? "Waiting..." : "Connected"),
          const SizedBox(height: 20),
          Text("$mm:$ss", style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.mic),
                onPressed: () {
                  _engine?.muteLocalAudioStream(true);
                },
              ),
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () {
                  _engine?.setEnableSpeakerphone(true);
                },
              ),
              IconButton(
                icon: const Icon(Icons.call_end, color: Colors.red),
                onPressed: leave,
              ),
            ],
          )
        ],
      ),
    );
  }
}
