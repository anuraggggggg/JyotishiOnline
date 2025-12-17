// lib/call/audio_call_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../fastApi/agora_service.dart';

class AudioCallPage extends StatefulWidget {
  final String astroId;

  final String? overrideChannel;
  final String? overrideToken;
  final String? overrideAccount;
  final String? overrideAppId;
  final int? overrideTimerSeconds;

  const AudioCallPage({
    super.key,
    required this.astroId,
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

  String _appId = "";
  String _channel = "";
  String _token = "";
  String _account = "";

  bool _loading = true;
  bool _joined = false;
  int? _remoteUid;

  bool _muted = false;
  bool _speakerOn = true;

  Duration _remaining = const Duration(minutes: 10);
  Timer? _timer;

  void logm(String m) => debugPrint("🎧 [AudioCall] $m");

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _timer?.cancel();
    () async {
      try { await _engine?.leaveChannel(); } catch (_) {}
    try { await _engine?.release(); } catch (_) {}
    }();
    super.dispose();
  }

  // -------------------------------------------------------------------
  // CALL INITIALIZATION
  // -------------------------------------------------------------------
  Future<void> _bootstrap() async {
    try {
      final mic = await Permission.microphone.request();
      if (mic != PermissionStatus.granted) throw "Microphone permission denied";

      if ((widget.overrideChannel ?? "").trim().isNotEmpty) {
        _channel = widget.overrideChannel!.trim();
        _token = widget.overrideToken?.trim() ?? "";
        _account = widget.overrideAccount?.trim() ?? "";
        _appId = widget.overrideAppId?.trim() ?? "";

        if (widget.overrideTimerSeconds != null) {
          _remaining = Duration(seconds: widget.overrideTimerSeconds!);
        }
      }

      if (_channel.isEmpty || _token.isEmpty || _account.isEmpty || _appId.isEmpty) {
        final auth = await AgoraService.getTokens(widget.astroId);

        _channel = _channel.isNotEmpty ? _channel : auth.channelName;
        _token = _token.isNotEmpty ? _token : auth.currentUserToken;
        _account = _account.isNotEmpty ? _account : auth.currentUserId;
        _appId = _appId.isNotEmpty ? _appId : auth.appId;

        if (auth.expireIn != null) {
          _remaining = Duration(seconds: auth.expireIn!);
        }
      }

      if (_account.isEmpty) _account = "user_${DateTime.now().millisecondsSinceEpoch}";

      // AGORA ENGINE
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(appId: _appId));

      await _engine!.setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      await _engine!.enableAudio();
      await _engine!.disableVideo();
      await _engine!.setDefaultAudioRouteToSpeakerphone(true);

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (_, __) {
            setState(() => _joined = true);
            _startTimer();
          },
          onUserJoined: (_, uid, __) {
            setState(() => _remoteUid = uid);
          },
          onUserOffline: (_, uid, __) {
            setState(() => _remoteUid = null);
          },
        ),
      );

      await _engine!.registerLocalUserAccount(appId: _appId, userAccount: _account);

      await _engine!.joinChannelWithUserAccount(
        token: _token,
        channelId: _channel,
        userAccount: _account,
        options: const ChannelMediaOptions(
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
          autoSubscribeAudio: true,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Audio call failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // -------------------------------------------------------------------
  // TIMER
  // -------------------------------------------------------------------
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining > Duration.zero) {
        setState(() => _remaining -= const Duration(seconds: 1));
      } else {
        _leave();
      }
    });
  }

  // -------------------------------------------------------------------
  // ACTION BUTTONS
  // -------------------------------------------------------------------
  Future<void> _toggleMute() async {
    _muted = !_muted;
    await _engine?.muteLocalAudioStream(_muted);
    setState(() {});
  }

  Future<void> _toggleSpeaker() async {
    _speakerOn = !_speakerOn;
    await _engine?.setEnableSpeakerphone(_speakerOn);
    setState(() {});
  }

  Future<void> _leave() async {
    try { await _engine?.leaveChannel(); } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  // -------------------------------------------------------------------
  // UI
  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final mm = _remaining.inMinutes.toString().padLeft(2, "0");
    final ss = (_remaining.inSeconds % 60).toString().padLeft(2, "0");

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Audio Call"),
        backgroundColor: Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _remoteUid == null ? Icons.call : Icons.call_merge,
            color: Colors.white,
            size: 100,
          ),

          const SizedBox(height: 10),

          Text(
            _remoteUid == null ? "Connecting…" : "Connected",
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),

          const SizedBox(height: 8),

          Text(
            "$mm:$ss",
            style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 30),

          // ACTION BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mute Button
              _circleButton(
                icon: _muted ? Icons.mic_off : Icons.mic,
                color: _muted ? Colors.red : Colors.white,
                onTap: _toggleMute,
              ),

              const SizedBox(width: 25),

              // Speaker Button
              _circleButton(
                icon: _speakerOn ? Icons.volume_up : Icons.hearing,
                color: Colors.white,
                onTap: _toggleSpeaker,
              ),

              const SizedBox(width: 25),

              // End Call Button
              _circleButton(
                icon: Icons.call_end,
                color: Colors.red,
                onTap: _leave,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          color: Color(0x22FFFFFF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}
