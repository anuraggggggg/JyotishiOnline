// lib/call/customer_video_call_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../../fastApi/agora_service.dart';

/// Customer-side video call page (joins with current_user_token + current_user_id)
class CustomerVideoCallPage extends StatefulWidget {
  final String astroId; // used by your token API

  // Optional: skip network fetch if you already have these
  final String? preFetchedAppId;
  final String? preFetchedChannel;
  final String? preFetchedCustomerToken;
  final String? preFetchedCustomerAccount; // <- current_user_id

  const CustomerVideoCallPage({
    super.key,
    required this.astroId,
    this.preFetchedAppId,
    this.preFetchedChannel,
    this.preFetchedCustomerToken,
    this.preFetchedCustomerAccount,
  });

  @override
  State<CustomerVideoCallPage> createState() => _CustomerVideoCallPageState();
}

class _CustomerVideoCallPageState extends State<CustomerVideoCallPage> {
  late RtcEngine _engine;
  bool _engineCreated = false;

  // From server
  String _appId = '';
  String _channel = '';
  String _token = '';
  String _account = ''; // <-- join by userAccount (must match token’s account)

  // Local state
  bool _loading = true;
  bool _joined = false;
  int? _remoteUid;
  bool _micOn = true;
  bool _camOn = true;

  // Optional: small ticker to show liveness
  Timer? _pulse;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _pulse?.cancel();
    () async {
      try { await _engine.leaveChannel(); } catch (_) {}
      try { await _engine.stopPreview(); } catch (_) {}
      try { await _engine.release(); } catch (_) {}
    }();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    debugPrint('📲 [CustomerVC] bootstrap() astroId=${widget.astroId}');

    try {
      // 1) Permissions
      debugPrint('🔐 [CustomerVC] Requesting camera/mic permissions…');
      final statuses = await [Permission.camera, Permission.microphone].request();
      final camOK = statuses[Permission.camera] == PermissionStatus.granted;
      final micOK = statuses[Permission.microphone] == PermissionStatus.granted;
      debugPrint('🔐 [CustomerVC] camera=$camOK, mic=$micOK');
      if (!camOK || !micOK) {
        throw 'Camera/Microphone permission denied';
      }

      // 2) Tokens & channel/appId
      if (widget.preFetchedAppId != null &&
          widget.preFetchedChannel != null &&
          widget.preFetchedCustomerToken != null &&
          widget.preFetchedCustomerAccount != null) {
        _appId   = widget.preFetchedAppId!;
        _channel = widget.preFetchedChannel!;
        _token   = widget.preFetchedCustomerToken!;
        _account = widget.preFetchedCustomerAccount!;
        debugPrint('🔑 [CustomerVC] Using pre-fetched creds');
      } else {
        debugPrint('🌐 [CustomerVC] Fetching tokens from API for astroId=${widget.astroId}…');
        final auth = await AgoraService.getVideoTokens(widget.astroId);
        _appId   = auth.appId;
        _channel = auth.channelName;
        _token   = auth.currentUserToken; // customer token
        // IMPORTANT: this must be the SAME account the token was generated for
        // Make sure your AgoraVideoAuth exposes this field (current_user_id)
        try {
          // If your model already exposes currentUserId, use it:
          // ignore: invalid_use_of_protected_member
          final currentUserIdField = (auth as dynamic).currentUserId as String?;
          _account = currentUserIdField ?? '';
        } catch (_) {
          // fallback if your model name differs
          debugPrint('⚠️ [CustomerVC] auth.currentUserId not found on model. Add it to AgoraVideoAuth!');
        }
      }

      // Trim for log safety (don’t print full token)
      final tokPreview = _token.length > 12 ? '${_token.substring(0, 6)}…${_token.substring(_token.length - 6)}' : _token;
      debugPrint('✅ [CustomerVC] appId=$_appId');
      debugPrint('✅ [CustomerVC] channel=$_channel');
      debugPrint('✅ [CustomerVC] account(current_user_id)=$_account');
      debugPrint('✅ [CustomerVC] token(current_user_token)=$tokPreview');

      if (_appId.isEmpty || _channel.isEmpty || _token.isEmpty || _account.isEmpty) {
        throw 'Missing required join fields (appId/channel/token/account). Check your API response.';
      }

      // 3) Engine
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: _appId));
      _engineCreated = true;
      debugPrint('🧠 [CustomerVC] Engine initialized');

      await _engine.setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _engine.enableVideo();

      // OPTIONAL: set encoder (helps some devices)
      await _engine.setVideoEncoderConfiguration(const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 15,
        bitrate: 0,
        orientationMode: OrientationMode.orientationModeAdaptive,
      ));

      // 4) Events
      _engine.registerEventHandler(RtcEngineEventHandler(
        onConnectionStateChanged: (RtcConnection conn, ConnectionStateType state, ConnectionChangedReasonType reason) {
          debugPrint('🔎 [CustomerVC] onConnectionStateChanged state=$state reason=$reason');
        },
        onJoinChannelSuccess: (RtcConnection conn, int elapsed) {
          debugPrint('🎉 [CustomerVC] onJoinChannelSuccess (elapsed=${elapsed}ms)  ch=${conn.channelId}');
          setState(() => _joined = true);
        },
        onUserJoined: (RtcConnection conn, int remoteUid, int elapsed) {
          debugPrint('👋 [CustomerVC] onUserJoined uid=$remoteUid elapsed=${elapsed}ms');
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection conn, int remoteUid, UserOfflineReasonType reason) {
          debugPrint('👋 [CustomerVC] onUserOffline uid=$remoteUid reason=$reason');
          setState(() => _remoteUid = null);
        },
        onLeaveChannel: (RtcConnection conn, RtcStats stats) {
          debugPrint('👋 [CustomerVC] onLeaveChannel duration=${stats.duration}');
          setState(() {
            _joined = false;
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection conn, String oldToken) async {
          debugPrint('⏰ [CustomerVC] Token will expire soon; consider refreshing.');
          // If you want auto-refresh:
          // final fresh = await AgoraService.getVideoTokens(widget.astroId);
          // await _engine.renewToken(fresh.currentUserToken);
        },
        onError: (ErrorCodeType code, String msg) {
          debugPrint('❗ [CustomerVC] Agora error: $code $msg');
          if (code == ErrorCodeType.errInvalidToken) {
            debugPrint('🚨 [CustomerVC] INVALID TOKEN. Make sure:');
            debugPrint('   • You are calling joinChannelWithUserAccount (not joinChannel with uid)');
            debugPrint('   • The account you pass == token’s userId (current_user_id)');
            debugPrint('   • Channel name matches exactly on both sides');
          }
        },
      ));

      await _engine.startPreview();
      debugPrint('🎥 [CustomerVC] Local preview started');

      // 5) Join by USER ACCOUNT (NOT numeric uid)
      debugPrint('➡️ [CustomerVC] joinChannelWithUserAccount '
          '(channel=$_channel, account=$_account, token=$tokPreview)');
      await _engine.joinChannelWithUserAccount(
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

      // Optional pulse to prove UI is alive
      _pulse = Timer.periodic(const Duration(seconds: 10), (_) {
        debugPrint('💓 [CustomerVC] pulse joined=$_joined remoteUid=$_remoteUid');
      });
    } catch (e) {
      debugPrint('💥 [CustomerVC] init failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video init failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _leave() async {
    debugPrint('↩️ [CustomerVC] Leaving channel…');
    try {
      if (_engineCreated) {
        await _engine.leaveChannel();
        await _engine.stopPreview();
      }
    } catch (e) {
      debugPrint('⚠️ [CustomerVC] leave error: $e');
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _toggleMic() async {
    _micOn = !_micOn;
    await _engine.muteLocalAudioStream(!_micOn);
    debugPrint('🎙 [CustomerVC] micOn=$_micOn');
    setState(() {});
  }

  Future<void> _toggleCam() async {
    _camOn = !_camOn;
    await _engine.muteLocalVideoStream(!_camOn);
    debugPrint('📷 [CustomerVC] camOn=$_camOn');
    setState(() {});
  }

  Future<void> _switchCam() async {
    await _engine.switchCamera();
    debugPrint('🔁 [CustomerVC] switchCamera()');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Video Call (Customer)', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Remote (full screen)
          Positioned.fill(
            child: _remoteUid == null
                ? Center(
              child: Text(
                _joined ? 'Waiting for astrologer…' : 'Joining…',
                style: const TextStyle(color: Colors.white70),
              ),
            )
                : AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: RtcConnection(channelId: _channel),
              ),
            ),
          ),

          // Local PiP
          Positioned(
            right: 12,
            top: 12,
            width: 120,
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.black54,
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine,
                    canvas: const VideoCanvas(uid: 0), // local view
                  ),
                ),
              ),
            ),
          ),

          // Controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _roundBtn(
                  icon: _micOn ? Icons.mic : Icons.mic_off,
                  color: _micOn ? Colors.white : Colors.redAccent,
                  onTap: _toggleMic,
                ),
                const SizedBox(width: 16),
                _roundBtn(
                  icon: _camOn ? Icons.videocam : Icons.videocam_off,
                  color: _camOn ? Colors.white : Colors.redAccent,
                  onTap: _toggleCam,
                ),
                const SizedBox(width: 16),
                _roundBtn(
                  icon: Icons.cameraswitch,
                  onTap: _switchCam,
                ),
                const SizedBox(width: 16),
                _roundBtn(
                  icon: Icons.call_end,
                  color: Colors.white,
                  bg: Colors.redAccent,
                  onTap: _leave,
                ),
              ],
            ),
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
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
    );
  }
}
