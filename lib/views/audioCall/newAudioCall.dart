// lib/call/audio_call_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../fastApi/agora_audio_service.dart';


class AudioCallPage extends StatefulWidget {
  /// Pass the astrologer ID here (the one customer wants to call)
  final String otherUserId;

  const AudioCallPage({super.key, required this.otherUserId});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  late RtcEngine _engine;

  String _appId = '';
  String _channel = '';
  String _token = '';
  String _account = '';

  bool _loading = true;
  bool _joined = false;
  bool _muted = false;
  bool _speakerOn = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final incoming = widget.otherUserId.trim();
      debugPrint('🎧 [CustomerVC] Bootstrapping with astrologer="$incoming"');

      if (incoming.isEmpty || incoming.toLowerCase() == 'null') {
        throw 'Invalid astrologer id';
      }

      // ── Request microphone permission ───────────────────────────────────────
      final statuses = await [Permission.microphone].request();
      if (statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Microphone permission denied';
      }

      // ── Fetch voice token from API ─────────────────────────────────────────
      debugPrint('🌐 [CustomerVC] Fetching voice token for other_user_id=$incoming');
      final auth = await AgoraVoiceService.getVoiceToken(incoming);

      _appId = auth.appId;
      _channel = auth.channelName;
      _token = auth.token;
      _account = auth.account;

      debugPrint('✅ [CustomerVC] Voice token OK:');
      debugPrint('   • appId   = $_appId');
      debugPrint('   • channel = $_channel');
      debugPrint('   • account = $_account');
      debugPrint('   • ttl     = ${auth.ttl}s');

      if (_appId.isEmpty || _channel.isEmpty || _token.isEmpty || _account.isEmpty) {
        throw 'Missing required voice auth fields (appId/channel/token/account)';
      }

      // ── Initialize Agora engine ────────────────────────────────────────────
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: _appId));
      debugPrint('⚙️ [CustomerVC] Agora engine initialized');

      await _engine.setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _engine.enableAudio();
      await _engine.disableVideo();
      debugPrint('🎛️ [CustomerVC] Audio enabled, video disabled');

      // ── Register Agora event handlers ──────────────────────────────────────
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onError: (ErrorCodeType code, String msg) {
            debugPrint('💥 [CustomerVC] Agora error: $code $msg');
          },
          onJoinChannelSuccess: (RtcConnection conn, int elapsed) {
            debugPrint('🎉 [CustomerVC] Joined channel ${conn.channelId}');
            setState(() => _joined = true);
            _setSpeaker(true);
          },
          onUserJoined: (RtcConnection conn, int uid, int elapsed) {
            debugPrint('👋 [CustomerVC] Remote user joined uid=$uid');
          },
          onUserOffline:
              (RtcConnection conn, int uid, UserOfflineReasonType reason) {
            debugPrint('👋 [CustomerVC] Remote user left uid=$uid reason=$reason');
          },
          onLeaveChannel: (RtcConnection conn, RtcStats stats) {
            debugPrint('👋 [CustomerVC] Left channel stats=$stats');
            setState(() => _joined = false);
          },
          onConnectionStateChanged: (RtcConnection conn,
              ConnectionStateType state, ConnectionChangedReasonType reason) {
            debugPrint('🔎 [CustomerVC] connState=$state reason=$reason');
          },
          onTokenPrivilegeWillExpire: (RtcConnection conn, String token) async {
            debugPrint('⌛ [CustomerVC] Token will expire soon — refresh if needed');
          },
        ),
      );

      // ── Register local user account & join channel ──────────────────────────
      await _engine.registerLocalUserAccount(appId: _appId, userAccount: _account);
      debugPrint('🪪 [CustomerVC] registerLocalUserAccount($_account) OK');

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
      debugPrint('📞 [CustomerVC] joinChannelWithUserAccount() called');
    } catch (e) {
      debugPrint('💥 [CustomerVC] init failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio init failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _leave() async {
    try {
      await _engine.leaveChannel();
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    () async {
      try {
        await _engine.leaveChannel();
      } catch (_) {}
      try {
        await _engine.release();
      } catch (_) {}
    }();
    super.dispose();
  }

  Future<void> _toggleMute() async {
    _muted = !_muted;
    await _engine.muteLocalAudioStream(_muted);
    debugPrint('🎙️ [CustomerVC] muteLocalAudioStream($_muted)');
    setState(() {});
  }

  Future<void> _setSpeaker(bool on) async {
    _speakerOn = on;
    await _engine.setEnableSpeakerphone(_speakerOn);
    debugPrint('🔊 [CustomerVC] setEnableSpeakerphone($_speakerOn)');
    setState(() {});
  }

  Future<void> _toggleSpeaker() => _setSpeaker(!_speakerOn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Call')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone_in_talk, size: 80, color: Colors.blueAccent),
          const SizedBox(height: 12),
          Text(_joined ? 'Connected • $_channel' : 'Connecting…'),
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