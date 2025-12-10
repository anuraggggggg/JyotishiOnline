// lib/call/audio_call_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../fastApi/agora_service.dart';

class AudioCallPage extends StatefulWidget {
  final String otherUserId;  // astrologer ID

  // Optional overrides provided by push notification:
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

  void _d(Object m) => debugPrint('🎧 [AudioCallPage] $m');

  @override
  void initState() {
    super.initState();
    initCall();
  }

  @override
  void dispose() {
    ticker?.cancel();
    try {
      _engine?.leaveChannel();
    } catch (_) {}
    try {
      _engine?.release();
    } catch (_) {}
    super.dispose();
  }

  Future<void> initCall() async {
    try {
      _d('initCall start — prefer overrides if present');

      await Permission.microphone.request();
      if (await Permission.microphone.isDenied) {
        throw 'Microphone permission denied';
      }

      // Use overrides from notification if provided
      final ovCh = (widget.overrideChannel ?? '').trim();
      final ovTok = (widget.overrideToken ?? '').trim();
      final ovAcc = (widget.overrideAccount ?? '').trim();
      final ovApp = (widget.overrideAppId ?? '').trim();
      final ovTimer = widget.overrideTimerSeconds;

      if (ovTimer != null && ovTimer > 0) {
        remaining = Duration(seconds: ovTimer);
        _d('Using override timer: ${remaining.inSeconds}s');
      }

      if (ovCh.isNotEmpty && ovAcc.isNotEmpty) {
        // use overrides
        _d('Overrides present — using push params channel=$ovCh account=$ovAcc tokenPresent=${ovTok.isNotEmpty} appId=${ovApp.isNotEmpty}');
        channel = ovCh;
        token = ovTok;
        account = ovAcc;
        if (ovApp.isNotEmpty) appId = ovApp;
      } else {
        // fallback: ask server for voice token
        _d('Overrides missing/incomplete — fetching voice token from server for astro=${widget.otherUserId}');
        final voice = await AgoraService.getVoiceToken(widget.otherUserId);
        appId = voice.appId;
        channel = voice.channelName;
        token = voice.token;
        account = voice.userAccount;
        if (voice.duration != null && voice.duration! > 0) remaining = Duration(seconds: voice.duration!);
        _d('Voice token fetched: channel=$channel user=$account timer=${remaining.inSeconds}s appId=$appId tokenPresent=${token.isNotEmpty}');
      }

      if (appId.isEmpty) {
        _d('WARN: appId empty — trying default from AgoraService or continue if SDK allows');
      }
      if (channel.isEmpty || account.isEmpty) {
        throw 'Missing required join fields (channel/account)';
      }

      final engine = createAgoraRtcEngine();
      await engine.initialize(RtcEngineContext(appId: appId));
      await engine.enableAudio();
      await engine.disableVideo();
      await engine.setDefaultAudioRouteToSpeakerphone(true);

      _engine = engine;

      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (_, __) {
            _d('joined channel success');
            if (mounted) setState(() => joined = true);
            _startTimerIfNeeded();
          },
          onUserJoined: (_, uid, __) {
            _d('remote user joined uid=$uid');
            if (mounted) setState(() => remoteUid = uid);
            _startTimerIfNeeded();
          },
          onUserOffline: (_, uid, __) {
            _d('remote user offline uid=$uid');
            if (mounted) setState(() => remoteUid = null);
          },
          onError: (err, msg) => _d('Agora error: $err $msg'),
        ),
      );

      // register local account (ensures joinChannelWithUserAccount works)
      await engine.registerLocalUserAccount(appId: appId, userAccount: account);

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

      _d('joinChannelWithUserAccount called (channel=$channel account=$account)');

    } catch (e, st) {
      _d('INIT FAILED: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Audio init failed: $e')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _startTimerIfNeeded() {
    if (ticker != null) return;
    // Start only when somebody joined (or immediately if we already joined)
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (remaining > Duration.zero) {
          remaining -= const Duration(seconds: 1);
        } else {
          ticker?.cancel();
          leave();
        }
      });
    });
  }

  Future<void> leave() async {
    _d('leave called');
    try {
      await _engine?.leaveChannel();
    } catch (_) {}
    if (mounted) Navigator.pop(context);
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
