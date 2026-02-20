// lib/views/chat/video_call_page.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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

class _CustomerVideoCallPageState extends State<CustomerVideoCallPage> with WidgetsBindingObserver {
  RtcEngine? _engine;
  bool _engineCreated = false;

  String _appId = "3a39af44074a40bebc2fff2cba7437e5";
  String _channel = '';
  String _token = '';
  String _account = '';

  bool _loading = true;
  bool _joined = false;
  int? _remoteUid;
  bool _isCharged = false;

  Timer? _callTimer;
  int _secondsLeft = 600; // 10 minutes
  bool _timerStarted = false;

  double _videoRate = 0;

  // UI States
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _showControls = true;
  Timer? _controlsTimer;

  // Connection Quality
  String _connectionQuality = "Good";
  Color _qualityColor = Colors.green;

  // Disconnection handling
  bool _isRemoteUserDisconnected = false;
  Timer? _disconnectTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();

    // Keep screen awake during call
    WakelockPlus.enable();

    // Force portrait mode only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _callTimer?.cancel();
    _controlsTimer?.cancel();
    _disconnectTimer?.cancel();
    _stopEngine();

    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Allow screen to sleep again
    WakelockPlus.disable();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Just track app state but don't do PiP
    if (state == AppLifecycleState.resumed) {
      debugPrint("📱 App resumed");
    } else if (state == AppLifecycleState.paused) {
      debugPrint("📱 App paused");
    }
  }

  Future<void> _stopEngine() async {
    try {
      await _engine?.leaveChannel();
      await _engine?.stopPreview();
      await _engine?.release();
    } catch (_) {}
  }

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
        _showSnackBar("₹$_videoRate deducted for the session start", Colors.green);
      }
    } catch (e) {
      debugPrint("💥 Deduction failed: $e");
      _showSnackBar("Failed to deduct balance. Call may be interrupted.", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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

      // Set video configuration for portrait mode
      await _engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 360, height: 640),
          frameRate: 30,
          bitrate: 0,
          orientationMode: OrientationMode.orientationModeFixedPortrait,
        ),
      );

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (conn, elapsed) {
            if (mounted) setState(() => _joined = true);
            debugPrint("✅ Joined channel successfully");
          },
          onUserJoined: (conn, remoteUid, elapsed) {
            if (mounted) {
              setState(() {
                _remoteUid = remoteUid;
                _isRemoteUserDisconnected = false;
              });
            }
            if (!_timerStarted) {
              _startTimer();
              _timerStarted = true;
            }
            debugPrint("👤 Remote user joined: $remoteUid");

            // Cancel any pending disconnect timer
            _disconnectTimer?.cancel();
          },
          onUserOffline: (conn, remoteUid, reason) {
            debugPrint("👋 Remote user left: $remoteUid, reason: $reason");
            if (mounted) {
              setState(() {
                _remoteUid = null;
                _isRemoteUserDisconnected = true;
              });

              // Start timer to end session if remote user doesn't return
              _disconnectTimer?.cancel();
              _disconnectTimer = Timer(const Duration(seconds: 5), () {
                if (mounted && _remoteUid == null) {
                  _showSnackBar("Astrologer disconnected. Ending call...", Colors.red);
                  Future.delayed(const Duration(seconds: 2), () {
                    _endSession();
                  });
                }
              });
            }
          },
          onNetworkQuality: (conn, uid, txQuality, rxQuality) {
            int rxQualityValue = rxQuality.index;

            String quality = "Good";
            Color color = Colors.green;

            if (rxQualityValue >= 4) {
              quality = "Poor";
              color = Colors.red;
            } else if (rxQualityValue >= 2) {
              quality = "Fair";
              color = Colors.orange;
            }

            if (mounted) {
              setState(() {
                _connectionQuality = quality;
                _qualityColor = color;
              });
            }
          },
          onConnectionStateChanged: (conn, state, reason) {
            debugPrint("🔌 Connection state changed: $state, reason: $reason");

            if (state == ConnectionStateType.connectionStateReconnecting) {
              _showSnackBar("Reconnecting...", Colors.orange);
            } else if (state == ConnectionStateType.connectionStateConnected) {
              _showSnackBar("Connected", Colors.green);
            } else if (state == ConnectionStateType.connectionStateFailed) {
              _showSnackBar("Connection lost", Colors.red);
              // End session after connection failure
              Future.delayed(const Duration(seconds: 2), () {
                _endSession();
              });
            }
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

      _showControlsTemporarily();
    } catch (e) {
      debugPrint("❌ Bootstrap error: $e");
      if (mounted) {
        _showSnackBar('Video call failed: $e', Colors.red);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
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
    _disconnectTimer?.cancel();

    if (mounted) {
      _showSnackBar("Call ended", Colors.orange);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _leave() async {
    _callTimer?.cancel();
    _disconnectTimer?.cancel();

    try {
      await _engine?.leaveChannel();
    } catch (_) {}

    if (mounted) Navigator.pop(context);
  }

  void _toggleMute() {
    _engine?.muteLocalAudioStream(!_isMuted);
    setState(() => _isMuted = !_isMuted);
    _showControlsTemporarily();
  }

  void _toggleCamera() {
    _engine?.muteLocalVideoStream(!_isCameraOff);
    setState(() => _isCameraOff = !_isCameraOff);
    _showControlsTemporarily();
  }

  void _toggleSpeaker() {
    _engine?.setEnableSpeakerphone(!_isSpeakerOn);
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    _showControlsTemporarily();
  }

  void _switchCamera() {
    _engine?.switchCamera();
    _showControlsTemporarily();
  }

  void _showControlsTemporarily() {
    setState(() => _showControls = true);
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, "0");
    final seconds = (_secondsLeft % 60).toString().padLeft(2, "0");

    return Scaffold(
      backgroundColor: Colors.black,
      body: _loading
          ? _buildLoadingScreen()
          : GestureDetector(
        onTap: _showControlsTemporarily,
        child: Stack(
          children: [
            // Remote Video (Main)
            Positioned.fill(
              child: _remoteUid == null
                  ? _buildWaitingScreen()
                  : Container(
                color: Colors.black,
                child: AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine!,
                    canvas: VideoCanvas(uid: _remoteUid),
                    connection: RtcConnection(channelId: _channel),
                  ),
                ),
              ),
            ),

            // Local Video
            Positioned(
              top: 20,
              right: 20,
              width: 100,
              height: 150,
              child: _buildLocalVideo(),
            ),

            // Connection Quality Badge
            if (_remoteUid != null)
              Positioned(
                top: 20,
                left: 20,
                child: _buildQualityBadge(),
              ),

            // Timer
            Positioned(
              top: 20,
              left: MediaQuery.of(context).size.width / 2 - 50,
              child: _buildTimerDisplay(minutes, seconds),
            ),

            // Disconnected Message
            if (_isRemoteUserDisconnected)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Astrologer disconnected",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Ending call in a moment...",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Call Controls
            if (_showControls)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: _buildCallControls(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(
              "Setting up video call...",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              "Waiting for astrologer to join...",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalVideo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _engine!,
                canvas: const VideoCanvas(uid: 0),
              ),
            ),
            if (_isCameraOff)
              Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.videocam_off, color: Colors.white, size: 30),
                ),
              ),
            if (_isMuted)
              const Positioned(
                bottom: 5,
                right: 5,
                child: Icon(Icons.mic_off, color: Colors.red, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _qualityColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.signal_cellular_alt, color: _qualityColor, size: 16),
          const SizedBox(width: 4),
          Text(
            _connectionQuality,
            style: TextStyle(color: _qualityColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(String minutes, String seconds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            "$minutes:$seconds",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? "Unmute" : "Mute",
            color: _isMuted ? Colors.red : Colors.white,
            onTap: _toggleMute,
          ),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
            label: _isCameraOff ? "Camera On" : "Camera Off",
            color: _isCameraOff ? Colors.red : Colors.white,
            onTap: _toggleCamera,
          ),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
            label: _isSpeakerOn ? "Speaker" : "Earpiece",
            color: Colors.white,
            onTap: _toggleSpeaker,
          ),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: Icons.flip_camera_ios,
            label: "Switch",
            color: Colors.white,
            onTap: _switchCamera,
          ),
          const SizedBox(width: 16),
          _buildControlButton(
            icon: Icons.call_end,
            label: "End",
            color: Colors.red,
            onTap: _leave,
            isEndCall: true,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isEndCall = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isEndCall ? Colors.red : Colors.black54,
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}