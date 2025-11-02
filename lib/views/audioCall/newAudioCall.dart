// lib/call/audio_call_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../../fastApi/agora_audio_service.dart';



/// A single audio-call page usable by BOTH apps.
/// Pass the astrologerId as [otherUserId] in BOTH apps (as you requested).
class AudioCallPage extends StatefulWidget {
  final String otherUserId; // you said: pass astro_id from both sides

  const AudioCallPage({
    super.key,
    required this.otherUserId,
  });

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  late RtcEngine _engine;
  bool _engineReady = false;

  String _appId = '';
  String _channel = '';
  String _token = '';
  String _account = ''; // MUST be the "user" returned by API
  int _ttl = 0;

  bool _joined = false;
  int? _remoteUid;
  bool _micOn = true;
  bool _speakerOn = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    () async {
      try { await _engine.leaveChannel(); } catch (_) {}
      try { await _engine.release(); } catch (_) {}
    }();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      // 1) mic permission
      final statuses = await [Permission.microphone].request();
      if (statuses[Permission.microphone] != PermissionStatus.granted) {
        throw 'Microphone permission denied';
      }

      // 2) fetch voice token
      final auth = await AgoraVoiceService.getVoiceToken(widget.otherUserId);
      _appId = auth.appId;
      _channel = auth.channelName;
      _token = auth.token;
      _account = auth.account; // CRITICAL: userAccount to join with
      _ttl = auth.ttl;

      final tokPreview = _token.length > 12
          ? '${_token.substring(0, 6)}…${_token.substring(_token.length - 6)}'
          : _token;

      debugPrint('🔑 [AUDIO] appId=$_appId  channel=$_channel');
      debugPrint('🔑 [AUDIO] account(from API user)=$_account  ttl=$_ttl');
      debugPrint('🔑 [AUDIO] token=$tokPreview');
      if (_appId.isEmpty || _channel.isEmpty || _token.isEmpty || _account.isEmpty) {
        throw 'Missing appId/channel/token/account from API';
      }

      // 3) init engine
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: _appId));
      _engineReady = true;

      await _engine.setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _engine.enableAudio();
      await _engine.disableVideo(); // audio-only
      await _engine.setEnableSpeakerphone(true);

      // 4) events
      _engine.registerEventHandler(RtcEngineEventHandler(
        onConnectionStateChanged: (RtcConnection conn, ConnectionStateType state, ConnectionChangedReasonType reason) {
          debugPrint('🔎 [AUDIO] onConnectionStateChanged ch=${conn.channelId} state=$state reason=$reason');
        },
        onJoinChannelSuccess: (RtcConnection conn, int elapsed) {
          debugPrint('🎉 [AUDIO] onJoinChannelSuccess ch=${conn.channelId} elapsed=${elapsed}ms');
          setState(() => _joined = true);
        },
        onUserJoined: (RtcConnection conn, int remoteUid, int elapsed) {
          debugPrint('👋 [AUDIO] onUserJoined uid=$remoteUid elapsed=${elapsed}ms');
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection conn, int remoteUid, UserOfflineReasonType reason) {
          debugPrint('👋 [AUDIO] onUserOffline uid=$remoteUid reason=$reason');
          setState(() => _remoteUid = null);
        },
        onLeaveChannel: (RtcConnection conn, RtcStats stats) {
          debugPrint('👋 [AUDIO] onLeaveChannel duration=${stats.duration}');
          setState(() {
            _joined = false;
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection conn, String token) async {
          debugPrint('⏰ [AUDIO] Token expiring soon; call your API to refresh and _engine.renewToken(newToken).');
        },
        onError: (ErrorCodeType code, String msg) {
          debugPrint('❗ [AUDIO] Agora error: $code $msg');
          if (code == ErrorCodeType.errInvalidToken) {
            debugPrint('🚨 [AUDIO] INVALID TOKEN. Ensure joinChannelWithUserAccount(account=$_account) matches the token.');
          }
        },
      ));

      // 5) join by ACCOUNT (CRITICAL)
      debugPrint('➡️ [AUDIO] joinChannelWithUserAccount(channel=$_channel, account=$_account)');
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
    } catch (e) {
      debugPrint('💥 [AUDIO] init failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio init failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleMic() async {
    _micOn = !_micOn;
    await _engine.muteLocalAudioStream(!_micOn);
    debugPrint('🎙 [AUDIO] micOn=$_micOn');
    setState(() {});
  }

  Future<void> _toggleSpeaker() async {
    _speakerOn = !_speakerOn;
    await _engine.setEnableSpeakerphone(_speakerOn);
    debugPrint('🔊 [AUDIO] speakerOn=$_speakerOn');
    setState(() {});
  }

  Future<void> _hangup() async {
    debugPrint('↩️ [AUDIO] Leaving channel…');
    try { await _engine.leaveChannel(); } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Audio Call', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone_in_talk, color: Colors.white70, size: 72),
          const SizedBox(height: 12),
          Text(
            _joined
                ? (_remoteUid == null ? 'Waiting for the other user…' : 'Connected to $_remoteUid')
                : 'Joining…',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _roundBtn(
                icon: _micOn ? Icons.mic : Icons.mic_off,
                color: _micOn ? Colors.white : Colors.redAccent,
                onTap: _toggleMic,
              ),
              const SizedBox(width: 16),
              _roundBtn(
                icon: _speakerOn ? Icons.volume_up : Icons.volume_off,
                color: _speakerOn ? Colors.white : Colors.redAccent,
                onTap: _toggleSpeaker,
              ),
              const SizedBox(width: 16),
              _roundBtn(
                icon: Icons.call_end,
                color: Colors.white,
                bg: Colors.redAccent,
                onTap: _hangup,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roundBtn({
    required IconData icon,
    Color color = Colors.white,
    Color bg = const Color(0x44000000),
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
    );
  }
}
