// lib/call/audio_call_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../fastApi/agora_service.dart';

class AudioCallPage extends StatefulWidget {
  final String otherUserId;

  final String? overrideChannel;
  final String? overrideToken;
  final String? overrideAccount;
  final String? overrideAppId;
  final int? overrideTimerSeconds;

  const AudioCallPage({
    super.key,
    required this.otherUserId,
    this.overrideChannel,
    this.overrideToken,
    this.overrideAccount,
    this.overrideAppId,
    this.overrideTimerSeconds,
  });

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  RtcEngine? engine;

  String appId = "";
  String channel = "";
  String token = "";
  String account = "";

  bool loading = true;
  bool joined = false;
  int? remoteUid;

  Duration remaining = const Duration(minutes: 15);
  Timer? timer;

  void logm(String msg) => debugPrint("🎧 [AudioCallPage] $msg");

  @override
  void initState() {
    super.initState();
    initCall();
  }

  @override
  void dispose() {
    timer?.cancel();
    () async {
      try {
        await engine?.leaveChannel();
    await engine?.release();
    } catch (_) {}
    engine = null;
    }();
    super.dispose();
  }

  Future<void> initCall() async {
    try {
      logm("initCall started…");

      final mic = await Permission.microphone.request();
      if (mic != PermissionStatus.granted) {
        throw "Microphone permission denied";
      }

      // FIRST PRIORITY → OVERRIDE FROM PUSH
      if (widget.overrideChannel != null &&
          widget.overrideChannel!.trim().isNotEmpty) {
        channel = widget.overrideChannel!.trim();
        token = widget.overrideToken ?? "";
        account = widget.overrideAccount ?? "";
        appId = widget.overrideAppId ?? "";

        if (widget.overrideTimerSeconds != null) {
          remaining = Duration(seconds: widget.overrideTimerSeconds!);
        }

        logm("Using PUSH override → channel=$channel account=$account");
      } else {
        // OTHERWISE → USE VIDEO TOKEN API (UNIVERSAL)
        logm("Fetching universal token → astro = ${widget.otherUserId}");

        final auth = await AgoraService.getTokens(widget.otherUserId);

        final params =
        AgoraService.buildJoinParams(auth: auth, isAstrologer: false);

        appId = params["appId"]!;
        channel = params["channel"]!;
        token = params["token"]!;
        account = params["account"]!;

        remaining = Duration(seconds: auth.expireIn);

        logm("Token fetched → channel=$channel user=$account");
      }

      engine = createAgoraRtcEngine();
      await engine!.initialize(RtcEngineContext(appId: appId));
      await engine!.enableAudio();
      await engine!.disableVideo();
      await engine!.setDefaultAudioRouteToSpeakerphone(true);

      engine!.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection c, int elapsed) {
          logm("onJoinChannelSuccess");
          setState(() => joined = true);
          startTimer();
        },
        onUserJoined: (RtcConnection c, int uid, int elapsed) {
          logm("Remote user joined: $uid");
          remoteUid = uid;
          setState(() {});
        },
        onUserOffline: (RtcConnection c, int uid, UserOfflineReasonType r) {
          logm("Remote left");
          remoteUid = null;
          setState(() {});
        },
      ));

      await engine!.registerLocalUserAccount(
        appId: appId,
        userAccount: account,
      );

      await engine!.joinChannelWithUserAccount(
        token: token,
        channelId: channel,
        userAccount: account,
        options: const ChannelMediaOptions(
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
          autoSubscribeAudio: true,
        ),
      );

      logm("joinChannelWithUserAccount complete");
    } catch (e, st) {
      logm("ERROR: $e\n$st");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Call failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void startTimer() {
    timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (remaining > Duration.zero) {
        setState(() => remaining -= const Duration(seconds: 1));
      } else {
        timer?.cancel();
        leave();
      }
    });
  }

  Future<void> leave() async {
    try {
      await engine?.leaveChannel();
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mm = remaining.inMinutes.remainder(60).toString().padLeft(2, "0");
    final ss = remaining.inSeconds.remainder(60).toString().padLeft(2, "0");

    return Scaffold(
      appBar: AppBar(title: const Text("Audio Call")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone_in_talk, size: 90),
          Text(remoteUid == null ? "Connecting…" : "Connected"),
          const SizedBox(height: 12),
          Text("$mm:$ss", style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 20),
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            iconSize: 48,
            onPressed: leave,
          ),
        ],
      ),
    );
  }
}
