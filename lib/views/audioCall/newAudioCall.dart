// lib/call/audio_call_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// If your service file name differs, adjust this import.
// This expects getVoiceAuthViaVideo(...) and VoiceCallerRole.
import '../../fastApi/agora_audio_service.dart';

class AudioCallPage extends StatefulWidget {
  /// Pass the astrologer (other) user id here (same id you use for the video API).
  final String otherUserId;

  const AudioCallPage({super.key, required this.otherUserId});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  late RtcEngine _engine;

  String _appId = '';
  String _channel = '';
  String _token = '';   // may be empty when App Certificate is disabled
  String _account = ''; // Agora user account from backend (must match token)

  bool _loading = true;
  bool _joined = false;
  bool _muted = false;
  bool _speakerOn = true;

  // ---------- 10-minute session timer ----------
  static const _sessionLength = Duration(minutes: 10);
  Duration _remaining = _sessionLength;
  Timer? _ticker;

  void _d(Object msg) => debugPrint('🎧 [CustomerVC] $msg');

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _stopTicker();
    () async {
      _d('Disposing engine…');
      try { await _engine.leaveChannel(); } catch (_) {}
      try { await _engine.release(); } catch (_) {}
    }();
    super.dispose();
  }

  // Format mm:ss
  String get _clock {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startTicker() {
    _stopTicker();
    _remaining = _sessionLength;
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      final next = _remaining - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        setState(() => _remaining = Duration.zero);
        _d('⏱️ Session time over → ending call');
        _endSession(); // auto-end
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
      final incoming = widget.otherUserId.trim();
      _d('Bootstrapping… otherUserId="$incoming"');
      if (incoming.isEmpty || incoming.toLowerCase() == 'null') {
        throw 'Invalid otherUserId';
      }

      // 1) Request mic permission
      _d('Requesting microphone permission…');
      final statuses = await [Permission.microphone].request();
      if (statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Microphone permission denied';
      }
      _d('Microphone permission ✅');

      // 2) Fetch voice auth **using your VIDEO TOKEN API**
      // We pick the correct token/account for the CUSTOMER side.
      _d('Fetching *video-based* voice auth for astroId=$incoming…');
      final auth = await AgoraVoiceService.getVoiceAuthViaVideo(
        astroId: incoming,
        role: VoiceCallerRole.customer,
      );

      _appId = auth.appId;
      _channel = auth.channelName;
      _token = auth.token;     // required string for joinChannelWithUserAccount
      _account = auth.account; // the exact userAccount that token targets

      _d('Auth OK → appId=$_appId | channel=$_channel | account=$_account | ttl=${auth.ttl}s');
      if (_appId.isEmpty || _channel.isEmpty || _token.isEmpty || _account.isEmpty) {
        throw 'Missing join fields (appId/channel/token/account). Check your video-token API response.';
      }

      // 3) Init Agora
      _d('Creating Agora engine…');
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: _appId));
      _d('Engine initialized');

      // Communication profile + audio only
      await _engine.setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _engine.enableAudio();
      await _engine.disableVideo();
      _d('ChannelProfile=Communication, audio ✅, video ❌');

      // Pre-route to speaker by default; actual speaker flip after join to avoid -3
      await _engine.setDefaultAudioRouteToSpeakerphone(true);
      _speakerOn = true;
      _d('Default route set to speaker ✅');

      // 4) Events (v5 signatures)
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onError: (ErrorCodeType code, String msg) {
            _d('ERROR $code $msg');
          },

          onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
            _d('Joined ${connection.channelId} in ${elapsed}ms');
            setState(() => _joined = true);

            // Start 10-min countdown when we are in the channel
            _startTicker();

            // Flip speaker AFTER join; retry once if -3 occurs.
            Future<void> trySpeaker() async {
              try {
                await _engine.setEnableSpeakerphone(true);
                _d('Speakerphone ON ✅');
              } catch (e) {
                _d('setEnableSpeakerphone threw ($e) → retrying once…');
                await Future.delayed(const Duration(milliseconds: 250));
                try {
                  await _engine.setEnableSpeakerphone(true);
                  _d('Speakerphone ON after retry ✅');
                } catch (e2) {
                  _d('Speakerphone still failed (BT/wired route likely).');
                }
              }
            }

            Future.delayed(const Duration(milliseconds: 100), trySpeaker);
          },

          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            _d('Remote JOINED uid=$remoteUid (in ${elapsed}ms)');
          },

          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            _d('Remote OFFLINE uid=$remoteUid reason=$reason');
          },

          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            _d('Left channel. stats=${stats.toJson()}');
            _stopTicker();
            setState(() => _joined = false);
          },

          onConnectionStateChanged: (RtcConnection connection,
              ConnectionStateType state, ConnectionChangedReasonType reason) {
            _d('ConnState=$state reason=$reason');
          },

          // v5 signature: (connection, speakers, speakerNumber, totalVolume)
          onAudioVolumeIndication: (
              RtcConnection connection,
              List<AudioVolumeInfo> speakers,
              int speakerNumber,
              int totalVolume,
              ) {
            for (final s in speakers) {
              _d('VOLUME uid=${s.uid} vol=${s.volume} vad=${s.vad}');
            }
            // _d('TotalVolume=$totalVolume | SpeakerCount=$speakerNumber');
          },

          onRemoteAudioStateChanged: (RtcConnection connection, int remoteUid,
              RemoteAudioState state, RemoteAudioStateReason reason, int elapsed) {
            _d('RemoteAudio uid=$remoteUid state=$state reason=$reason t=${elapsed}ms');
          },

          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            _d('Token will expire soon (refresh via video API if needed)');
          },
        ),
      );

      // 5) Register & join (userAccount-based)
      _d('Registering local user account "$_account"…');
      await _engine.registerLocalUserAccount(appId: _appId, userAccount: _account);
      _d('registerLocalUserAccount ✅');

      final previewToken = _token.length > 12
          ? '${_token.substring(0, 6)}…${_token.substring(_token.length - 6)}'
          : _token;
      _d('Joining channel "$_channel" (token: $previewToken)…');

      await _engine.joinChannelWithUserAccount(
        token: _token,
        channelId: _channel,
        userAccount: _account,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
          autoSubscribeAudio: true,
          autoSubscribeVideo: false,
        ),
      );
      _d('joinChannelWithUserAccount() sent');
    } catch (e) {
      _d('INIT FAILED: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio init failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _endSession() async {
    _d('Ending session…');
    _stopTicker();
    try { await _engine.leaveChannel(); } catch (e) { _d('leave error: $e'); }
    if (mounted) Navigator.pop(context, true); // return to request page
  }

  Future<void> _leave() => _endSession();

  Future<void> _toggleMute() async {
    _muted = !_muted;
    await _engine.muteLocalAudioStream(_muted);
    _d('muteLocalAudioStream($_muted)');
    setState(() {});
  }

  Future<void> _setSpeaker(bool on) async {
    _speakerOn = on;
    try {
      await _engine.setEnableSpeakerphone(_speakerOn);
    } catch (e) {
      _d('setEnableSpeakerphone($_speakerOn) failed: $e');
    }
    _d('Speaker ${_speakerOn ? 'ON' : 'OFF'}');
    setState(() {});
  }

  Future<void> _toggleSpeaker() => _setSpeaker(!_speakerOn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Call'),
        actions: [
          // Countdown in the app bar for clear visibility
          if (!_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Text(
                _clock,
                style: const TextStyle(fontWeight: FontWeight.w600),
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
          const SizedBox(height: 8),
          Text(_joined ? 'Connected • $_channel' : 'Connecting…'),
          const SizedBox(height: 6),
          // Large timer display
          Text(
            _clock,
            style: const TextStyle(
              fontSize: 28,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_muted ? Icons.mic_off : Icons.mic),
                onPressed: _toggleMute,
                tooltip: _muted ? 'Unmute' : 'Mute',
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: Icon(_speakerOn ? Icons.volume_up : Icons.hearing),
                onPressed: _toggleSpeaker,
                tooltip: _speakerOn ? 'Speaker off' : 'Speaker on',
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.call_end, color: Colors.red),
                onPressed: _leave,
                tooltip: 'Hang up',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
