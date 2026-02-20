// lib/call/audio_call_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../fastApi/agora_service.dart';
import '../../fastApi/fastApiServices.dart';

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

class _AudioCallPageState extends State<AudioCallPage> with WidgetsBindingObserver {
  final FastAPIServices _api = FastAPIServices();
  RtcEngine? _engine;

  String _appId = "";
  String _channel = "";
  String _token = "";
  String _account = "";

  bool _loading = true;
  bool _joined = false;
  int? _remoteUid;
  bool _isCharged = false;

  bool _muted = false;
  bool _speakerOn = true;

  // Dynamic Astrologer Data
  String? _displayName;
  String? _profileImageUrl;
  double _audioRate = 0;

  // Timer
  Duration _remaining = const Duration(minutes: 10);
  Timer? _timer;

  // Disconnection handling
  bool _isRemoteUserDisconnected = false;
  Timer? _disconnectTimer;

  // Connection Quality
  String _connectionQuality = "Good";
  Color _qualityColor = Colors.green;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();

    // Keep screen awake during call
    WakelockPlus.enable();

    // Force portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _disconnectTimer?.cancel();
    _stopAgora();

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
    if (state == AppLifecycleState.resumed) {
      debugPrint("📱 Audio call app resumed");
    } else if (state == AppLifecycleState.paused) {
      debugPrint("📱 Audio call app paused");
    }
  }

  Future<void> _stopAgora() async {
    try {
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (_) {}
  }

  // -------------------------------------------------------------------
  // DEDUCTION LOGIC
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
        _showSnackBar("₹$_audioRate deducted for the session start", Colors.green);
      }
    } catch (e) {
      debugPrint("💥 Audio deduction failed: $e");
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

  // -------------------------------------------------------------------
  // CALL INITIALIZATION
  // -------------------------------------------------------------------
  Future<void> _bootstrap() async {
    try {
      final mic = await Permission.microphone.request();
      if (mic != PermissionStatus.granted) {
        throw "Microphone permission denied";
      }

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
        // Charge user immediately
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

      if (_account.isEmpty) {
        _account = "user_${DateTime.now().millisecondsSinceEpoch}";
      }

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
            debugPrint("✅ Joined audio channel successfully");
            _startTimer();
          },
          onUserJoined: (_, uid, __) {
            setState(() {
              _remoteUid = uid;
              _isRemoteUserDisconnected = false;
            });
            debugPrint("👤 Remote user joined audio: $uid");

            // Cancel any pending disconnect timer
            _disconnectTimer?.cancel();
          },
          onUserOffline: (_, uid, __) {
            debugPrint("👋 Remote user left audio: $uid");
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
                  _leave();
                });
              }
            });
          },
          onNetworkQuality: (_, uid, txQuality, rxQuality) {
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
          onConnectionStateChanged: (_, state, reason) {
            debugPrint("🔌 Audio connection state changed: $state, reason: $reason");

            if (state == ConnectionStateType.connectionStateReconnecting) {
              _showSnackBar("Reconnecting...", Colors.orange);
            } else if (state == ConnectionStateType.connectionStateConnected) {
              _showSnackBar("Connected", Colors.green);
            } else if (state == ConnectionStateType.connectionStateFailed) {
              _showSnackBar("Connection lost", Colors.red);
              // End session after connection failure
              Future.delayed(const Duration(seconds: 2), () {
                _leave();
              });
            }
          },
        ),
      );

      await _engine!.registerLocalUserAccount(appId: _appId, userAccount: _account);
      await _engine!.joinChannelWithUserAccount(
        token: _token,
        channelId: _channel,
        userAccount: _account,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
        ),
      );
    } catch (e) {
      debugPrint("❌ Audio bootstrap error: $e");
      if (mounted) {
        _showSnackBar("Audio call failed: $e", Colors.red);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
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
        _showSnackBar("Call time ended", Colors.orange);
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
    _timer?.cancel();
    _disconnectTimer?.cancel();
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
        title: const Text(
          "Audio Call",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _leave,
        ),
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFFC31F),
        ),
      )
          : Stack(
        children: [
          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Image
              CircleAvatar(
                radius: 70,
                backgroundColor: const Color(0xFFFFC31F),
                backgroundImage: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl.isEmpty
                    ? const Icon(
                  Icons.person,
                  size: 70,
                  color: Colors.black,
                )
                    : null,
              ),

              const SizedBox(height: 24),

              // Name
              Text(
                _displayName ?? "Astrologer",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Connection Status
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _remoteUid == null
                          ? Colors.orange
                          : Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _remoteUid == null
                        ? "Connecting..."
                        : "Connected",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Connection Quality
              if (_remoteUid != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _qualityColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.signal_cellular_alt,
                        color: _qualityColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _connectionQuality,
                        style: TextStyle(
                          color: _qualityColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 40),

              // Timer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "$mm:$ss",
                  style: const TextStyle(
                    color: Color(0xFFFFC31F),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Call Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: _muted ? Icons.mic_off : Icons.mic,
                    label: _muted ? "Unmute" : "Mute",
                    color: _muted ? Colors.red : Colors.white,
                    onTap: _toggleMute,
                  ),
                  const SizedBox(width: 20),
                  _buildControlButton(
                    icon: _speakerOn
                        ? Icons.volume_up
                        : Icons.hearing,
                    label: _speakerOn ? "Speaker" : "Earpiece",
                    color: Colors.white,
                    onTap: _toggleSpeaker,
                  ),
                  const SizedBox(width: 20),
                  _buildControlButton(
                    icon: Icons.call_end,
                    label: "End",
                    color: Colors.red,
                    onTap: _leave,
                    isEndCall: true,
                  ),
                ],
              ),
            ],
          ),

          // Disconnected Overlay
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEndCall ? Colors.red : Colors.black54,
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}