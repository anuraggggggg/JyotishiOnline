// lib/call/customer_video_call_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../../fastApi/agora_service.dart';
import '../../fastApi/fastApiServices.dart';

class CustomerVideoCallPage extends StatefulWidget {
  final String astroId;
  final String? overrideRoomId;
  final String? overrideToken;
  final String? overrideAccount;
  final String? overrideAppId;

  const CustomerVideoCallPage({
    super.key,
    required this.astroId,
    this.overrideRoomId,
    this.overrideToken,
    this.overrideAccount,
    this.overrideAppId,
  });

  @override
  State<CustomerVideoCallPage> createState() => _CustomerVideoCallPageState();
}

class _CustomerVideoCallPageState extends State<CustomerVideoCallPage> {
  RtcEngine? _engine;
  bool _engineCreated = false;

  String _appId = "3a39af44074a40bebc2fff2cba7437e5";
  String _channel = '';
  String _token = '';
  String _account = '';

  bool _loading = true;
  bool _joined = false;
  int? _remoteUid;
  bool _isCharged = false; // Prevents double charging

  Timer? _callTimer;
  int _secondsLeft = 600;
  bool _timerStarted = false;

  double _videoRate = 0;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _stopEngine();
    super.dispose();
  }

  Future<void> _stopEngine() async {
    try {
      await _engine?.leaveChannel();
      await _engine?.stopPreview();
      await _engine?.release();
    } catch (_) {}
  }

  // ------------------------------------------------------------------
  // DEDUCTION LOGIC (Now called at start)
  // ------------------------------------------------------------------
  Future<void> _deductBalance() async {
    if (_isCharged) return;
    _isCharged = true;

    try {
      debugPrint("💰 Initializing upfront deduction: ₹$_videoRate");
      await FastAPIServices().sendMoney(
        astrologerId: widget.astroId,
        amount: _videoRate,
        type: "video_call",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("₹$_videoRate deducted for the session start"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("💥 Deduction failed: $e");
      // Optional: You could Navigator.pop(context) here if you want to prevent
      // the call from continuing if they don't have enough balance.
    }
  }

  Future<void> _bootstrap() async {
    try {
      final statuses = await [Permission.camera, Permission.microphone].request();
      if (statuses[Permission.camera] != PermissionStatus.granted ||
          statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Camera/Microphone permission denied';
      }

      // Fetch Rate and Deduct Money Upfront
      try {
        final astro = await FastAPIServices().fetchAstrologerDetail(widget.astroId);
        _videoRate = (astro.videoCallCharge ?? 0).toDouble();

        // 🔥 MONEY DEDUCTS HERE AS USER ENTERS
        await _deductBalance();
      } catch (e) {
        debugPrint("⚠️ Could not process upfront deduction: $e");
      }

      // Decide join params
      final hasOverrideChannel = (widget.overrideRoomId ?? '').trim().isNotEmpty;
      if (hasOverrideChannel) {
        _channel = widget.overrideRoomId!.trim();
        _token = widget.overrideToken?.trim() ?? '';
        _account = widget.overrideAccount?.trim() ?? '';
        _appId = widget.overrideAppId?.trim().isNotEmpty == true ? widget.overrideAppId!.trim() : _appId;
      }

      if (_channel.isEmpty || _token.isEmpty || _account.isEmpty) {
        final auth = await AgoraService.getTokens(widget.astroId);
        _channel = _channel.isNotEmpty ? _channel : auth.channelName;
        _token = _token.isNotEmpty ? _token : auth.currentUserToken;
        _account = _account.isNotEmpty ? _account : (auth.currentUserId.isNotEmpty ? auth.currentUserId : 'viewer_${DateTime.now().millisecondsSinceEpoch}');
        _appId = _appId.isNotEmpty ? _appId : auth.appId;
      }

      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(appId: _appId));
      _engineCreated = true;

      await _engine!.setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine!.enableVideo();
      await _engine!.startPreview();

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (conn, elapsed) {
            if (mounted) setState(() => _joined = true);
          },
          onUserJoined: (conn, remoteUid, elapsed) {
            if (mounted) setState(() => _remoteUid = remoteUid);
            if (!_timerStarted) {
              _startTimer();
              _timerStarted = true;
            }
          },
          onUserOffline: (conn, remoteUid, reason) {
            if (mounted) setState(() => _remoteUid = null);
          },
        ),
      );

      await _engine!.joinChannelWithUserAccount(
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Video init failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        _endSession();
      } else {
        if (mounted) setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _endSession() async {
    _callTimer?.cancel();
    try { await _engine?.leaveChannel(); } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  Future<void> _leave() async {
    _callTimer?.cancel();
    try { await _engine?.leaveChannel(); } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, "0");
    final seconds = (_secondsLeft % 60).toString().padLeft(2, "0");

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Video Call', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(
            child: _remoteUid == null
                ? const Center(child: Text("Waiting for astrologer…", style: TextStyle(color: Colors.white70)))
                : AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine!,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: RtcConnection(channelId: _channel),
              ),
            ),
          ),
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
                    rtcEngine: _engine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text("$minutes:$seconds", style: const TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ),
          Positioned(
            bottom: 25,
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: _leave,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
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