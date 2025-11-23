// lib/call/audio_call_page.dart
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../../fastApi/agora_audio_service.dart';

class AudioCallPage extends StatefulWidget {
  final String otherUserId;

  const AudioCallPage({super.key, required this.otherUserId});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  RtcEngine? _engine;

  String _appId = '';
  String _channel = '';
  String _token = '';
  String _account = '';

  bool _loading = true;
  bool _joined = false;
  bool _muted = false;
  bool _speakerOn = true;

  String? _remoteUserAccount;
  int? _remoteUid;

  static const _sessionLength = Duration(minutes: 10);
  Duration _remaining = _sessionLength;
  Timer? _ticker;

  void _d(Object msg) => debugPrint('🎧 [AudioCall] $msg');

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _d('Disposing...');
    _stopTicker();

    () async {
      final engine = _engine;
      if (engine != null) {
        try {
          await engine.leaveChannel();
        } catch (e) {
          _d('leaveChannel() in dispose threw: $e');
        }
        try {
          await engine.release();
        } catch (e) {
          _d('release() in dispose threw: $e');
        }
      }
    }();

    super.dispose();
  }

  String get _clock {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _statusText {
    if (_loading) return 'Initialising call…';
    if (!_joined) return 'Connecting…';
    // ✅ Consider EITHER account OR uid as proof that astrologer joined
    if (_remoteUserAccount == null && _remoteUid == null) {
      return 'Waiting for astrologer to join…';
    }
    return 'Astrologer Connected';
  }

  void _startTicker() {
    _stopTicker();
    _remaining = _sessionLength;

    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      final next = _remaining - const Duration(seconds: 1);

      if (next <= Duration.zero) {
        setState(() => _remaining = Duration.zero);
        _endSession(showSnackBar: true);
      } else {
        setState(() => _remaining = next);
      }
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  Future<void> _bootstrap() async {
    try {
      final astroId = widget.otherUserId.trim();
      if (astroId.isEmpty) throw 'Invalid astrologer ID';

      // 🔐 Mic permission
      final mic = await [Permission.microphone].request();
      if (mic[Permission.microphone] != PermissionStatus.granted) {
        throw 'Microphone permission denied';
      }

      // 🔑 Get audio auth via video API
      final auth = await AgoraVoiceService.getVoiceAuthViaVideo(
        astroId: astroId,
        role: VoiceCallerRole.customer,
      );

      _appId = auth.appId;
      _channel = auth.channelName;
      _token = auth.token;
      _account = auth.account;

      if (_appId.isEmpty ||
          _channel.isEmpty ||
          _token.isEmpty ||
          _account.isEmpty) {
        throw 'Missing fields in auth';
      }

      // 🎛️ Agora init
      final engine = createAgoraRtcEngine();
      _engine = engine;

      await engine.initialize(RtcEngineContext(appId: _appId));
      await engine.setChannelProfile(
          ChannelProfileType.channelProfileCommunication);
      await engine.enableAudio();
      await engine.disableVideo();

      await engine.setDefaultAudioRouteToSpeakerphone(true);

      // 🎧 Event handlers
      engine.registerEventHandler(
        RtcEngineEventHandler(
          onError: (ErrorCodeType code, String msg) {
            _d('onError → $code | $msg');
          },

          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            _d('Joined channel successfully: ${connection.channelId} in ${elapsed}ms');
            setState(() => _joined = true);
            _startTicker();

            Future.delayed(const Duration(milliseconds: 200), () async {
              try {
                await engine.setEnableSpeakerphone(true);
              } catch (e) {
                _d('setEnableSpeakerphone after join threw: $e');
              }
            });
          },

          // ✅ Numeric UID based detection (common path)
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            _d('onUserJoined → uid=$remoteUid elapsed=$elapsed channel=${connection.channelId}');
            setState(() {
              _remoteUid = remoteUid;
            });
          },

          // ✅ userAccount-based detection (if backend uses that)
          onUserInfoUpdated: (int uid, UserInfo info) {
            _d('onUserInfoUpdated → uid=$uid, account=${info.userAccount}');
            if (info.userAccount != _account) {
              setState(() {
                _remoteUserAccount = info.userAccount;
                // If uid is 0, keep old UID if present, else set a non-zero placeholder
                _remoteUid = uid == 0 ? (_remoteUid ?? 999999) : uid;
              });
            }
          },

          onUserOffline:
              (RtcConnection connection, int uid, UserOfflineReasonType reason) {
            _d('onUserOffline → uid=$uid reason=$reason channel=${connection.channelId}');
            setState(() {
              // Only clear if this was our remote
              if (_remoteUid == uid || _remoteUid == null) {
                _remoteUserAccount = null;
                _remoteUid = null;
              }
            });
          },

          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            _d('onLeaveChannel → channel=${connection.channelId}, stats=${stats.toJson()}');
            _stopTicker();
          },
        ),
      );

      // 🔐 Register local user account & join
      await engine.registerLocalUserAccount(appId: _appId, userAccount: _account);

      await engine.joinChannelWithUserAccount(
        token: _token,
        channelId: _channel,
        userAccount: _account,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
          autoSubscribeAudio: true,
        ),
      );
    } catch (e) {
      _d('INIT FAILED → $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Call Init Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ----------------------------------------------------------
  // 🔥 END SESSION — with SnackBar support
  // ----------------------------------------------------------
  Future<void> _endSession({bool showSnackBar = false}) async {
    try {
      await _engine?.leaveChannel();
    } catch (e) {
      _d('leaveChannel in _endSession threw: $e');
    }

    if (mounted) {
      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Your audio call session has ended."),
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.pop(context, true);
    }
  }

  // ----------------------------------------------------------

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

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Call'),
        actions: [
          if (!_loading)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                _clock,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone_in_talk, size: 80, color: Colors.blueAccent),
          const SizedBox(height: 12),

          Text(
            _statusText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          if (_remoteUserAccount != null || _remoteUid != null) ...[
            const SizedBox(height: 6),
            Text(
              _remoteUserAccount != null
                  ? 'Astrologer: $_remoteUserAccount'
                  : 'Astrologer UID: $_remoteUid',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],

          const SizedBox(height: 20),
          Text(
            _clock,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),

          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_muted ? Icons.mic_off : Icons.mic),
                onPressed: _toggleMute,
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: Icon(_speakerOn ? Icons.volume_up : Icons.hearing),
                onPressed: _toggleSpeaker,
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.call_end, color: Colors.red),
                onPressed: () => _endSession(showSnackBar: true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
