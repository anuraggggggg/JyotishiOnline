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
  bool _chargeFailed = false;

  bool _muted = false;
  bool _speakerOn = true;

  // Dynamic Astrologer Data
  String? _displayName;
  String? _profileImageUrl;
  double _audioRate = 0;

  // Timer
  Duration _remaining = const Duration(minutes: 10);
  Timer? _timer;
  bool _timerStarted = false;

  // Disconnection handling - 2 minutes waiting time
  bool _isRemoteUserDisconnected = false;
  Timer? _reconnectTimer;
  int _reconnectCountdown = 120; // 120 seconds = 2 minutes
  bool _showReconnectTimer = false;

  // Waiting time tracking for initial join
  DateTime? _joinAttemptStartTime;
  Timer? _waitingTimer;
  int _waitingSeconds = 0;
  bool _showWaitingTimer = false;

  // Connection Quality
  String _connectionQuality = "Good";
  Color _qualityColor = Colors.green;

  // Disclaimer flag
  bool _disclaimerShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Show disclaimer first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDisclaimerDialog();
    });

    // Keep screen awake during call
    WakelockPlus.enable();

    // Force portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Show disclaimer dialog
  void _showDisclaimerDialog() {
    if (_disclaimerShown) return;
    _disclaimerShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Audio Call Rules',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 50,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Audio Call Session',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        '⚠️ IMPORTANT NOTES:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• You will be charged immediately upon entering\n'
                            '• Timer starts only when astrologer joins\n'
                            '• If astrologer disconnects, wait 2 minutes for reconnection\n'
                            '• If astrologer doesn\'t join in 2 minutes, contact support\n'
                            '• DO NOT minimize or close the app\n'
                            '• DO NOT switch to other apps\n'
                            '• Ensure stable internet connection',
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '🚫 SHARING CONTACT INFO IS PROHIBITED',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Do not share phone numbers, email, or social media handles. '
                            'All conversations are monitored for your safety.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _bootstrap();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  'I Understand & Continue',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _reconnectTimer?.cancel();
    _waitingTimer?.cancel();
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
      if (mounted && !_isRemoteUserDisconnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Timer is still running! Please stay on this screen.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
      debugPrint("💰 Charging customer: ₹$_audioRate");
      await _api.sendMoney(
        astrologerId: widget.astroId,
        amount: _audioRate,
        type: "audio_call",
      );
      if (mounted) {
        _showSnackBar("₹$_audioRate charged for the session", Colors.green);
      }
    } catch (e) {
      debugPrint("💥 Charge failed: $e");
      _chargeFailed = true;
      _showSnackBar("Failed to charge. Call may not start.", Colors.red);

      // Show charge failed dialog
      _showChargeFailedDialog();
    }
  }

  void _showChargeFailedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text(
                'Payment Failed',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Unable to charge your account.\n\n'
                    'Please check your balance and try again.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        );
      },
    );
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
        // Charge user immediately when entering
        await _deductBalance();
      } catch (e) {
        debugPrint("⚠️ Could not fetch details/charge: $e");
      }

      // If charge failed, don't proceed
      if (_chargeFailed) {
        if (mounted) {
          setState(() => _loading = false);
        }
        return;
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

            // Start waiting timer when joined but no astrologer
            _startWaitingTimer();
          },
          onUserJoined: (_, uid, __) {
            setState(() {
              _remoteUid = uid;
              _isRemoteUserDisconnected = false;
              _showReconnectTimer = false;
              _showWaitingTimer = false; // Hide waiting timer
            });
            debugPrint("👤 Remote user joined audio: $uid");

            // Start timer ONLY when astrologer joins
            if (!_timerStarted) {
              _startTimer();
              _timerStarted = true;
              debugPrint("⏱️ Timer started - astrologer joined");
            }

            // Cancel waiting timer
            _waitingTimer?.cancel();

            // Cancel any pending reconnect timer
            _reconnectTimer?.cancel();
          },
          onUserOffline: (_, uid, __) {
            debugPrint("👋 Remote user left audio: $uid");
            setState(() {
              _remoteUid = null;
              _isRemoteUserDisconnected = true;
              _showReconnectTimer = true;
              _reconnectCountdown = 120; // Reset to 2 minutes
            });

            // Start reconnection countdown (2 minutes)
            _startReconnectionCountdown();
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

  // Start waiting timer (2 minutes max for astrologer to join)
  void _startWaitingTimer() {
    _showWaitingTimer = true;
    _waitingSeconds = 0;

    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _waitingSeconds++;

          // If waiting for more than 2 minutes (120 seconds), show support message
          if (_waitingSeconds >= 120 && _remoteUid == null) {
            timer.cancel();
            _showSupportDialog();
          }
        });
      }
    });
  }

  // Show support dialog if astrologer doesn't join
  void _showSupportDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.support_agent, color: Colors.blue, size: 28),
              SizedBox(width: 8),
              Text(
                'Astrologer Not Joining',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.timer_off,
                      size: 50,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'The astrologer hasn\'t joined yet.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Please contact support with this information:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        'Astrologer ID: ${widget.astroId}\n'
                            'Channel: $_channel\n'
                            'Time: ${DateTime.now().toString()}\n'
                            'Amount Charged: ₹$_audioRate',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Screenshot this and send to:\n'
                          '📱 WhatsApp: +91 1234567890\n'
                          '📧 Email: support@astroway.com',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // End the call
                    Navigator.of(context).pop();
                    _leave();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('End Call'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // Continue waiting
                    Navigator.of(context).pop();
                    _startWaitingTimer(); // Restart waiting timer
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Wait Longer'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Start reconnection countdown (2 minutes)
  void _startReconnectionCountdown() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_reconnectCountdown > 0) {
            _reconnectCountdown--;
          } else {
            // Time's up - end the session
            timer.cancel();
            _showSnackBar("Astrologer didn't reconnect. Ending call...", Colors.red);
            Future.delayed(const Duration(seconds: 2), () {
              _leave();
            });
          }
        });
      }
    });
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
    // Show confirmation dialog when trying to leave
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('End Audio Call?'),
        content: const Text(
            'Are you sure you want to end the call?\n\n'
                'You have been charged for this session.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue Call'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Call'),
          ),
        ],
      ),
    );

    if (shouldLeave != true) return;

    _timer?.cancel();
    _reconnectTimer?.cancel();
    _waitingTimer?.cancel();
    await _stopAgora();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mm = _remaining.inMinutes.toString().padLeft(2, "0");
    final ss = (_remaining.inSeconds % 60).toString().padLeft(2, "0");
    final imageUrl = buildImageUrl(_profileImageUrl);

    // Format reconnect time as minutes:seconds
    final reconnectMinutes = (_reconnectCountdown ~/ 60).toString().padLeft(2, '0');
    final reconnectSeconds = (_reconnectCountdown % 60).toString().padLeft(2, '0');

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
          : _chargeFailed
          ? _buildChargeFailedScreen()
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

              // Timer - Only show when astrologer has joined
              if (_timerStarted && _remoteUid != null)
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

              // Waiting Timer
              if (_showWaitingTimer && _remoteUid == null && !_timerStarted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_empty, color: Colors.orange, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        "Waiting: $_waitingSeconds/120 sec",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

          // Disconnected Message with Reconnection Timer (2 minutes)
          if (_isRemoteUserDisconnected && _showReconnectTimer)
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
                        Text(
                          "Waiting for reconnection...",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            "Reconnecting in $reconnectMinutes:$reconnectSeconds",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "The astrologer has 2 minutes to rejoin.\nYou will not be charged for this waiting time.",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
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

  Widget _buildChargeFailedScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 80,
          ),
          const SizedBox(height: 20),
          const Text(
            'Payment Failed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Unable to charge your account.\nPlease check your balance.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Go Back'),
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