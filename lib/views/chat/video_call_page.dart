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
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../services/location_services.dart';


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
  bool _chargeFailed = false;

  Timer? _callTimer;
  int _secondsLeft = 600; // 10 minutes
  bool _timerStarted = false;

  double _videoRateInr = 0;
  double _videoRateUsd = 0;

  // UI States
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _showControls = true;
  Timer? _controlsTimer;

  // Connection Quality
  String _connectionQuality = "Good";
  Color _qualityColor = Colors.green;

  // Disconnection handling - UPDATED to 2 minutes (120 seconds)
  bool _isRemoteUserDisconnected = false;
  Timer? _reconnectTimer;
  int _reconnectCountdown = 120; // 120 seconds = 2 minutes to reconnect
  bool _showReconnectTimer = false;

  // Waiting time tracking
  DateTime? _joinAttemptStartTime;
  Timer? _waitingTimer;
  int _waitingSeconds = 0;
  bool _showWaitingTimer = false;

  // Disclaimer flag
  bool _disclaimerShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Show disclaimer first, then bootstrap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDisclaimerDialog();
    });

    // Keep screen awake during call
    WakelockPlus.enable();

    // Force portrait mode only
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
                  'Video Call Rules',
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
                        'Video Call Session',
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
    _callTimer?.cancel();
    _controlsTimer?.cancel();
    _reconnectTimer?.cancel();
    _waitingTimer?.cancel();
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
    if (state == AppLifecycleState.resumed) {
      debugPrint("📱 App resumed");
    } else if (state == AppLifecycleState.paused) {
      debugPrint("📱 App paused");
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
      double chargeAmount;
      double displayAmount;
      String currency;

      if (LocationService.isIndianUser) {

        chargeAmount = _videoRateInr;
        displayAmount = _videoRateInr;
        currency = "₹";

        debugPrint("🇮🇳 Indian user → ₹$chargeAmount");

      } else {

        double usdAmount = _videoRateUsd > 0 ? _videoRateUsd : _videoRateInr;

        displayAmount = usdAmount;
        currency = "\$";

        debugPrint("🌍 International user → \$${usdAmount}");

        final response =
        await http.get(Uri.parse("https://open.er-api.com/v6/latest/USD"));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          double rate = data["rates"]["INR"];

          chargeAmount = usdAmount * rate;

          debugPrint("💱 Converted: \$${usdAmount} → ₹$chargeAmount");

        } else {
          chargeAmount = usdAmount * 83;
        }
      }

      debugPrint("📤 Sending to backend: ₹$chargeAmount");

      await FastAPIServices().sendMoney(
        astrologerId: widget.astroId,
        amount: chargeAmount.round(),
        type: "video_call",
      );

      if (mounted) {
        _showSnackBar(
          "$currency${displayAmount.toStringAsFixed(2)} charged for the session",
          Colors.green,
        );
      }

    } catch (e) {
      debugPrint("💥 Charge failed: $e");

      _chargeFailed = true;

      _showSnackBar("Failed to charge. Call may not start.", Colors.red);

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

  Future<void> _bootstrap() async {
    try {
      final statuses = await [Permission.camera, Permission.microphone].request();
      if (statuses[Permission.camera] != PermissionStatus.granted ||
          statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Camera/Microphone permission denied';
      }

      // Fetch Rate and Charge immediately
      try {
        final astro = await FastAPIServices().fetchAstrologerDetail(widget.astroId);
        _videoRateInr = (astro.videoCallCharge ?? 0).toDouble();
        _videoRateUsd = (astro.videoCallChargeUSD ?? 0).toDouble();

        debugPrint("💰 Video INR rate: $_videoRateInr");
        debugPrint("💰 Video USD rate: $_videoRateUsd");
        await _deductBalance(); // Charge immediately when entering
      } catch (e) {
        debugPrint("⚠️ Could not process charge: $e");
      }

      // If charge failed, don't proceed
      if (_chargeFailed) {
        if (mounted) {
          setState(() => _loading = false);
        }
        return;
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

            // Start waiting timer when joined but no astrologer
            _startWaitingTimer();
          },
          onUserJoined: (conn, remoteUid, elapsed) {
            if (mounted) {
              setState(() {
                _remoteUid = remoteUid;
                _isRemoteUserDisconnected = false;
                _showReconnectTimer = false;
                _showWaitingTimer = false; // Hide waiting timer
              });
            }
            // Start timer ONLY when astrologer joins
            if (!_timerStarted) {
              _startTimer();
              _timerStarted = true;
              debugPrint("⏱️ Timer started - astrologer joined");
            }
            debugPrint("👤 Remote user joined: $remoteUid");

            // Cancel waiting timer
            _waitingTimer?.cancel();

            // Cancel reconnection timer when user rejoins
            _reconnectTimer?.cancel();
          },
          onUserOffline: (conn, remoteUid, reason) {
            debugPrint("👋 Remote user left: $remoteUid, reason: $reason");
            if (mounted) {
              setState(() {
                _remoteUid = null;
                _isRemoteUserDisconnected = true;
                _showReconnectTimer = true;
                _reconnectCountdown = 120; // Reset countdown to 2 minutes
              });

              // Start countdown for reconnection (2 minutes)
              _startReconnectionCountdown();
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

  // Start waiting timer (2 minutes max)
  void _startWaitingTimer() {
    _joinAttemptStartTime = DateTime.now();
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
                            'Amount Charged: ${LocationService.isIndianUser ? "₹$_videoRateInr" : "\$$_videoRateUsd"}',
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
                    _endSession();
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
              _endSession();
            });
          }
        });
      }
    });
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
    _reconnectTimer?.cancel();
    _waitingTimer?.cancel();

    if (mounted) {
      _showSnackBar("Call ended", Colors.orange);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _leave() async {
    // Show confirmation dialog when trying to leave
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('End Video Call?'),
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

    _callTimer?.cancel();
    _reconnectTimer?.cancel();
    _waitingTimer?.cancel();

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

    // Format reconnect time as minutes:seconds
    final reconnectMinutes = (_reconnectCountdown ~/ 60).toString().padLeft(2, '0');
    final reconnectSeconds = (_reconnectCountdown % 60).toString().padLeft(2, '0');

    return WillPopScope(
      onWillPop: () async {
        if (!_loading) {
          await _leave();
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _loading
            ? _buildLoadingScreen()
            : _chargeFailed
            ? _buildChargeFailedScreen()
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

              // Timer - Only show when astrologer has joined
              if (_timerStarted && _remoteUid != null)
                Positioned(
                  top: 20,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: _buildTimerDisplay(minutes, seconds),
                ),

              // Waiting Timer
              if (_showWaitingTimer && _remoteUid == null && !_timerStarted)
                Positioned(
                  top: 20,
                  left: MediaQuery.of(context).size.width / 2 - 100,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.hourglass_empty, color: Colors.orange, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Waiting: $_waitingSeconds/120 sec",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                            Text(
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

              // Call Controls
              if (_showControls && !_isRemoteUserDisconnected && !_chargeFailed)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 8),
                        _buildControlButton(
                          icon: _isMuted ? Icons.mic_off : Icons.mic,
                          label: _isMuted ? "Unmute" : "Mute",
                          color: _isMuted ? Colors.red : Colors.white,
                          onTap: _toggleMute,
                        ),
                        const SizedBox(width: 12),
                        _buildControlButton(
                          icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                          label: _isCameraOff ? "Camera On" : "Camera Off",
                          color: _isCameraOff ? Colors.red : Colors.white,
                          onTap: _toggleCamera,
                        ),
                        const SizedBox(width: 12),
                        _buildControlButton(
                          icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                          label: _isSpeakerOn ? "Speaker" : "Earpiece",
                          color: Colors.white,
                          onTap: _toggleSpeaker,
                        ),
                        const SizedBox(width: 12),
                        _buildControlButton(
                          icon: Icons.flip_camera_ios,
                          label: "Switch",
                          color: Colors.white,
                          onTap: _switchCamera,
                        ),
                        const SizedBox(width: 12),
                        _buildControlButton(
                          icon: Icons.call_end,
                          label: "End",
                          color: Colors.red,
                          onTap: _leave,
                          isEndCall: true,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
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
            padding: const EdgeInsets.all(12),
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
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}