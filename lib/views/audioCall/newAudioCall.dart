// lib/call/audio_call_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../fastApi/agora_service.dart';
import '../../fastApi/fastApiServices.dart'; // Import your API service

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
  final FastAPIServices _api = FastAPIServices();
  RtcEngine? _engine;

  String _appId = "";
  String _channel = "";
  String _token = "";
  String _account = "";

  bool _loading = true;
  bool _joined = false;
  int? _remoteUid;
  bool _isCharged = false; // Flag to prevent double charging

  bool _muted = false;
  bool _speakerOn = true;

  // Dynamic Astrologer Data
  String? _displayName;
  String? _profileImageUrl;
  double _audioRate = 0;

  // Set default to 10 minutes
  Duration _remaining = const Duration(minutes: 10);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopAgora();
    super.dispose();
  }

  Future<void> _stopAgora() async {
    try { await _engine?.leaveChannel(); } catch (_) {}
    try { await _engine?.release(); } catch (_) {}
  }

  // -------------------------------------------------------------------
  // DEDUCTION LOGIC (Money deducts as user enters)
  // -------------------------------------------------------------------
  Future<void> _deductBalance() async {
    if (_isCharged) return;
    _isCharged = true;

    try {
      debugPrint("💰 Upfront Audio Call Deduction: ₹$_audioRate");
      await _api.sendMoney(
        astrologerId: widget.astroId,
        amount: _audioRate,
        type: "audio_call",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("₹$_audioRate deducted for the session start"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("💥 Audio deduction failed: $e");
      // Optional: Navigator.pop(context) if balance is mandatory to start
    }
  }

  // -------------------------------------------------------------------
  // CALL INITIALIZATION
  // -------------------------------------------------------------------
  Future<void> _bootstrap() async {
    try {
      final mic = await Permission.microphone.request();
      if (mic != PermissionStatus.granted) throw "Microphone permission denied";

      // 1. Fetch Astrologer Details & Charge Upfront
      try {
        final astro = await _api.fetchAstrologerDetail(widget.astroId);
        if (mounted) {
          setState(() {
            _displayName = astro.name;
            _profileImageUrl = astro.profileImage;
            _audioRate = (astro.audioCallCharge ?? 0).toDouble();
          });
        }
        // 🔥 CHARGE USER IMMEDIATELY
        await _deductBalance();
      } catch (e) {
        debugPrint("⚠️ Could not fetch details/charge: $e");
      }

      // 2. Agora Credential Logic
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
        _remaining = const Duration(minutes: 10);
      }

      if (_account.isEmpty) _account = "user_${DateTime.now().millisecondsSinceEpoch}";

      // 3. AGORA ENGINE SETUP
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(appId: _appId));

      await _engine!.setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine!.enableAudio();
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
          autoSubscribeAudio: true,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Audio call failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining > Duration.zero) {
        setState(() => _remaining -= const Duration(seconds: 1));
      } else {
        _leave();
      }
    });
  }

  String buildImageUrl(String? rawPath) {
    if (rawPath == null) return '';
    final cleaned = rawPath.replaceAll('\n', '').replaceAll('\r', '').replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty || cleaned.toLowerCase().contains('null')) return '';
    if (cleaned.startsWith('http')) return cleaned;
    return 'https://fastapi.jyotishionline.com${cleaned.startsWith('/') ? cleaned : '/$cleaned'}';
  }

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
    await _stopAgora();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mm = _remaining.inMinutes.toString().padLeft(2, "0");
    final ss = (_remaining.inSeconds % 60).toString().padLeft(2, "0");
    final imageUrl = buildImageUrl(_profileImageUrl);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text("Audio Call", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFC31F)))
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dynamic Profile Image
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFFFFC31F),
            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            child: imageUrl.isEmpty
                ? const Icon(Icons.person, size: 60, color: Colors.black)
                : null,
          ),

          const SizedBox(height: 20),

          Text(
            _displayName ?? "Astrologer",
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            _remoteUid == null ? "Connecting…" : "Connected",
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),

          const SizedBox(height: 30),

          Text(
            "$mm:$ss",
            style: const TextStyle(color: Color(0xFFFFC31F), fontSize: 40, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 50),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _circleButton(
                icon: _muted ? Icons.mic_off : Icons.mic,
                color: _muted ? Colors.red : Colors.white,
                onTap: _toggleMute,
              ),
              const SizedBox(width: 30),
              _circleButton(
                icon: _speakerOn ? Icons.volume_up : Icons.hearing,
                color: Colors.white,
                onTap: _toggleSpeaker,
              ),
              const SizedBox(width: 30),
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
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white10,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}