// lib/views/LiveViewerPage.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class LiveViewerPage extends StatefulWidget {
  final String channelName;
  final String token; // pass '' if no token
  final String astroId; // optional use

  const LiveViewerPage({
    super.key,
    required this.channelName,
    required this.token,
    required this.astroId,
  });

  @override
  State<LiveViewerPage> createState() => _LiveViewerPageState();
}

class _LiveViewerPageState extends State<LiveViewerPage> {
  late RtcEngine _engine;

  int? hostUid;
  bool _joining = true;
  int? _dataStreamId;
  bool _streamReady = false;

  // Replace with your Agora App ID
  static const String _agoraAppId = "3a39af44074a40bebc2fff2cba7437e5";

  // CHAT
  final List<_Comment> _comments = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputCtrl = TextEditingController();

  // UI helpers
  bool get _canSend => !_joining && _streamReady && _inputCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initRTC();
  }

  // -------------------------
  // Init RTC & Handlers
  // -------------------------
  Future<void> _initRTC() async {
    try {
      _engine = createAgoraRtcEngine();
      await _engine.initialize(RtcEngineContext(appId: _agoraAppId));

      // Recommended: register handlers BEFORE join
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) async {
            debugPrint('[Viewer] onJoinChannelSuccess channel=${connection.channelId} uid=${connection.localUid}');
            if (!mounted) return;
            setState(() {
              _joining = false;
            });

            // create data stream so this client can both send & be compatible
            await _createDataStream();
          },

          onUserJoined: (connection, uid, elapsed) {
            debugPrint('[Viewer] onUserJoined uid=$uid');
            if (!mounted) return;
            setState(() {
              hostUid = uid;
            });
          },

          onUserOffline: (connection, uid, reason) {
            debugPrint('[Viewer] onUserOffline uid=$uid reason=$reason');
            if (!mounted) return;
            setState(() {
              if (hostUid == uid) hostUid = null;
            });
          },

          onStreamMessage: (connection, uid, streamId, data, offset, length) {
            // Accept packets from any streamId — don't filter by local _dataStreamId
            try {
              final raw = data.sublist(offset, offset + length);
              String msg = utf8
                  .decode(raw, allowMalformed: true)
                  .replaceAll('\u0000', '')
                  .replaceAll('\n', '')
                  .replaceAll('\r', '')
                  .replaceAll('\t', '')
                  .trim();

              if (msg.isEmpty) {
                debugPrint('[Viewer] Ignored empty packet from uid=$uid streamId=$streamId');
                return;
              }

              // Optionally log non-JSON packets for debugging
              if (!msg.startsWith('{') || !msg.endsWith('}')) {
                debugPrint('[Viewer] IGNORED NON-JSON packet from uid=$uid streamId=$streamId msg="$msg"');
                return;
              }

              final json = jsonDecode(msg);

              if (!mounted) return;
              setState(() {
                _comments.add(
                  _Comment(
                    json['user']?.toString() ?? 'User',
                    json['text']?.toString() ?? '',
                    DateTime.tryParse(json['ts']?.toString() ?? '') ?? DateTime.now(),
                  ),
                );
              });

              _scrollDown();
            } catch (e, st) {
              debugPrint('[Viewer] onStreamMessage decode error: $e\n$st');
            }
          },

          onError: (err, msg) {
            debugPrint('[Viewer] Agora error: $err $msg');
          },

          onConnectionStateChanged: (connection, state, reason) {
            debugPrint('[Viewer] connection state: $state reason: $reason');
          },
        ),
      );

      // Use live broadcasting profile
      await _engine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);

      // NOTE: to allow sending data stream messages from viewers, we set broadcaster role.
      // If you prefer viewer to be audience (no sending), change to clientRoleAudience.
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      await _engine.enableVideo();

      // Now join
      await _engine.joinChannel(
        token: widget.token,
        channelId: widget.channelName,
        uid: 0, // let SDK assign
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
          publishMediaPlayerAudioTrack: false,
          publishMediaPlayerVideoTrack: false,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );

      debugPrint('[Viewer] joinChannel called for ${widget.channelName}');
    } catch (e, st) {
      debugPrint('[Viewer] RTC INIT FAILED: $e\n$st');
    }
  }

  // -------------------------
  // Create Data Stream
  // -------------------------
  Future<void> _createDataStream() async {
    if (_dataStreamId != null) return;

    try {
      _dataStreamId = await _engine.createDataStream(
        const DataStreamConfig(syncWithAudio: false, ordered: true),
      );
      debugPrint('[Viewer] DataStream created id=$_dataStreamId');
      if (!mounted) return;
      setState(() {
        _streamReady = true;
      });
    } catch (e, st) {
      debugPrint('[Viewer] createDataStream error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _streamReady = false;
      });
    }
  }

  // -------------------------
  // Send message
  // -------------------------
  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    if (!_streamReady) {
      debugPrint('[Viewer] stream not ready, attempting to create...');
      await _createDataStream();
      if (!_streamReady) {
        debugPrint('[Viewer] stream creation failed, cannot send');
        return;
      }
    }

    // Keep payload small (avoid very large messages)
    final payloadMap = {
      'user': 'Viewer',
      'text': text,
      'ts': DateTime.now().toIso8601String(),
    };

    final payload = jsonEncode(payloadMap);
    final bytes = Uint8List.fromList(utf8.encode(payload));
    if (bytes.length > 1024) {
      debugPrint('[Viewer] payload too large (${bytes.length}), truncating text');
      // truncate text safely
      final truncated = payload.substring(0, 900);
      final bytes2 = Uint8List.fromList(utf8.encode(truncated));
      try {
        await _engine.sendStreamMessage(
          streamId: _dataStreamId ?? 0,
          data: bytes2,
          length: bytes2.length,
        );
      } catch (e) {
        debugPrint('[Viewer] sendStreamMessage ERROR after truncate: $e');
      }
    } else {
      try {
        await _engine.sendStreamMessage(
          streamId: _dataStreamId ?? 0,
          data: bytes,
          length: bytes.length,
        );

        // Show locally
        if (!mounted) return;
        setState(() {
          _comments.add(_Comment('You', text, DateTime.now()));
        });
        _inputCtrl.clear();
        _scrollDown();
      } catch (e) {
        debugPrint('[Viewer] sendStreamMessage ERROR: $e');
      }
    }
  }

  // -------------------------
  // Scroll helper
  // -------------------------
  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollController.dispose();

    // cleanup: leave & release safely
    (() async {
      try {
        await _engine.leaveChannel();
      } catch (e) {
        debugPrint('[Viewer] leaveChannel error: $e');
      }
      try {
        await _engine.release();
      } catch (e) {
        debugPrint('[Viewer] engine release error: $e');
      }
    })();

    super.dispose();
  }

  // -------------------------
  // UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    final waiting = hostUid == null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: waiting
                ? const Text(
              "Waiting for astrologer...",
              style: TextStyle(color: Colors.white),
            )
                : AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: hostUid),
                connection: RtcConnection(channelId: widget.channelName),
              ),
            ),
          ),

          // Chat list
          Positioned(
            left: 12,
            right: 12,
            bottom: 100,
            child: Container(
              height: 170,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _comments.length,
                itemBuilder: (_, i) => _CommentTile(c: _comments[i]),
              ),
            ),
          ),

          // Input
          Positioned(
            left: 12,
            right: 12,
            bottom: 18,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type a comment...",
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _canSend ? Colors.purple : Colors.grey,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _canSend ? _sendMessage : null,
                  ),
                ),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: 40,
            left: 12,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------
// Comment model & tile
// -------------------------
class _Comment {
  final String user;
  final String text;
  final DateTime at;
  _Comment(this.user, this.text, this.at);
}

class _CommentTile extends StatelessWidget {
  final _Comment c;
  const _CommentTile({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const CircleAvatar(radius: 10, child: Icon(Icons.person, size: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "${c.user}: ${c.text}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}