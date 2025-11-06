// lib/call/audio_call_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// If your file is named differently, adjust this import:
import '../../fastApi/agora_audio_service.dart';

class AudioCallPage extends StatefulWidget {
  /// Pass the astrologer (other) user id here.
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
  String _account = ''; // Agora user account from backend

  bool _loading = true;
  bool _joined = false;
  bool _muted = false;
  bool _speakerOn = true;

  void _d(Object msg) => debugPrint('🎧 [CustomerVC] $msg');

  @override
  void initState() {
    super.initState();
    _bootstrap();
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

      // 2) Fetch voice auth (appID, channelName, voice_token?, user, timer)
      _d('Fetching voice token from API for other_user_id=$incoming…');
      final auth = await AgoraVoiceService.getVoiceToken(otherUserId: incoming);

      _appId = auth.appId;
      _channel = auth.channelName;
      _token = auth.token ?? ''; // keep empty string if no token
      _account = auth.account;

      _d('Auth OK → appId=$_appId | channel=$_channel | account=$_account | ttl=${auth.ttl}s');
      if (_appId.isEmpty || _channel.isEmpty || _account.isEmpty) {
        throw 'Missing voice auth (appId/channel/account)';
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

      // Set default route BEFORE join (this doesn’t flip speaker immediately)
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

            // Flip speaker AFTER join; -3 occurs if you call this too early.
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

            // Nudge a tick later to let audio stack settle
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
            _d('TotalVolume=$totalVolume | SpeakerCount=$speakerNumber');
          },

          onRemoteAudioStateChanged: (RtcConnection connection, int remoteUid,
              RemoteAudioState state, RemoteAudioStateReason reason, int elapsed) {
            _d('RemoteAudio uid=$remoteUid state=$state reason=$reason t=${elapsed}ms');
          },

          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            _d('Token will expire soon');
          },
        ),
      );

      // 5) Register & join
      _d('Registering local user account "$_account"…');
      await _engine.registerLocalUserAccount(appId: _appId, userAccount: _account);
      _d('registerLocalUserAccount ✅');

      final safeToken = _token; // keep as "" when you have no token
      _d('Joining channel "$_channel" (token: ${safeToken.isEmpty ? 'EMPTY' : 'PRESENT'})…');

      await _engine.joinChannelWithUserAccount(
        token: safeToken,
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

  Future<void> _leave() async {
    _d('Leaving channel…');
    try {
      await _engine.leaveChannel();
    } catch (e) {
      _d('leaveChannel error: $e');
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    () async {
      _d('Disposing engine…');
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
    _d('muteLocalAudioStream($_muted)');
    setState(() {});
  }

  Future<void> _setSpeaker(bool on) async {
    _speakerOn = on;
    // Keep default route toward speaker; flip speaker after join.
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
