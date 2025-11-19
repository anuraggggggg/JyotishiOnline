// lib/views/LiveViewerPage.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class LiveViewerPage extends StatefulWidget {
  final String channelName;
  final String token;
  final String astroId;

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
  int? _dataStreamId;
  bool _streamReady = false;
  bool _joining = true;
  late final int _myUid;

  // reassembly buffers
  final Map<String, List<String?>> _recvParts = {};
  final Map<String, int> _recvTotal = {};

  final List<_Comment> _comments = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputCtrl = TextEditingController();

  // use the same static appId you had earlier (keep as-is)
  static const String _agoraAppId = "3a39af44074a40bebc2fff2cba7437e5";

  bool get _canSend => !_joining && _inputCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _myUid = Random().nextInt(900000) + 2000;
    _initRTC();
  }

  Future<void> _initRTC() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: _agoraAppId));

    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) async {
        debugPrint('[Viewer] joined channel (uid=$_myUid)');
        setState(() => _joining = false);
      },

      onUserJoined: (connection, uid, elapsed) {
        debugPrint('[Viewer] user joined uid=$uid');
        setState(() => hostUid = uid);
      },

      onUserOffline: (connection, uid, reason) {
        if (hostUid == uid) setState(() => hostUid = null);
      },

      onStreamMessage: (connection, uid, streamId, data, offset, length) {
        try {
          // FIX: Use the entire received data buffer to form the JSON envelope,
          // resolving the 'invalid offset/length' errors.
          final cleaned = _trimNulls(Uint8List.fromList(data));
          final envelopeText = utf8.decode(cleaned);

          // envelope parse
          final Map<String, dynamic> envelope = jsonDecode(envelopeText) as Map<String, dynamic>;
          final m = envelope['m'] as Map<String, dynamic>?;
          final d = envelope['d'] as String?;
          if (m == null || d == null) {
            debugPrint('[Viewer] envelope missing; ignoring');
            return;
          }

          final id = m['id']?.toString() ?? '';
          final part = (m['part'] is int) ? m['part'] as int : int.tryParse(m['part']?.toString() ?? '') ?? 0;
          final total = (m['total'] is int) ? m['total'] as int : int.tryParse(m['total']?.toString() ?? '') ?? 1;

          _recvParts.putIfAbsent(id, () => List<String?>.filled(total, null));
          _recvTotal[id] = total;
          if (part >= 0 && part < total) {
            _recvParts[id]![part] = d;
          } else {
            debugPrint('[Viewer] invalid part index $part for id $id total $total');
            return;
          }

          final parts = _recvParts[id]!;
          final completed = parts.every((p) => p != null);
          if (!completed) {
            debugPrint('[Viewer] received part $part/$total for id=$id (waiting)');
            return;
          }

          // assemble
          final combined = <int>[];
          for (final b64 in parts) combined.addAll(base64.decode(b64!));
          _recvParts.remove(id);
          _recvTotal.remove(id);

          final payload = utf8.decode(combined);
          debugPrint('[Viewer] assembled payload: $payload');

          final Map<String, dynamic> obj = jsonDecode(payload) as Map<String, dynamic>;
          setState(() {
            _comments.add(_Comment(obj["user"] ?? "User", obj["text"] ?? "", DateTime.tryParse(obj["ts"] ?? "") ?? DateTime.now()));
          });
          _scrollDown();
        } catch (e, st) {
          debugPrint("[Viewer] JSON decode / assemble error: $e\n$st");
        }
      },

      onConnectionStateChanged: (connection, state, reason) {
        debugPrint('[Viewer] connection state $state reason $reason');
      },

      onError: (err, msg) {
        debugPrint('[Viewer] Agora error $err $msg');
      },
    ));

    await _engine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await _engine.enableVideo();

    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: _myUid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  Uint8List _trimNulls(Uint8List bytes) {
    int start = 0;
    int end = bytes.length;
    while (start < end && bytes[start] == 0) start++;
    while (end > start && bytes[end - 1] == 0) end--;
    return bytes.sublist(start, end);
  }

  // prepare data stream for viewer sending (temporary broadcaster role)
  Future<void> _prepareStreamForSend() async {
    if (_streamReady && _dataStreamId != null) return;
    try {
      // Step 1: Temporarily switch role to Broadcaster
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      debugPrint('[Viewer] Role set to Broadcaster. Waiting briefly...');

      // *** CRITICAL FIX: Add a delay to let the role change propagate on the server ***
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Create the data stream
      final id = await _engine.createDataStream(const DataStreamConfig(syncWithAudio: false, ordered: true));
      _dataStreamId = id;
      _streamReady = true;
      debugPrint('[Viewer] created data stream id=$_dataStreamId');
    } catch (e) {
      debugPrint('[Viewer] Stream creation failed: $e');
      _streamReady = false;
      _dataStreamId = null;
      // Step 3: Ensure role is reverted if creation fails
      await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    }
  }

  // send message (envelope+chunking)
  Future<void> _sendMessage([String? maybeText]) async {
    final text = (maybeText ?? _inputCtrl.text).trim();
    if (text.isEmpty) return;

    try {
      await _prepareStreamForSend();
      if (_dataStreamId == null) {
        debugPrint('[Viewer] no data stream id, abort send');
        return;
      }

      final payloadMap = {"user": "Viewer", "text": text, "ts": DateTime.now().toIso8601String()};
      final payloadBytes = utf8.encode(jsonEncode(payloadMap));
      final msgId = DateTime.now().millisecondsSinceEpoch.toString() + '-' + Random().nextInt(9999).toString();
      const int chunkSize = 900;
      final int total = ((payloadBytes.length + chunkSize - 1) / chunkSize).floor();

      int sent = 0;
      int part = 0;
      while (sent < payloadBytes.length) {
        final take = min(chunkSize, payloadBytes.length - sent);
        final chunk = payloadBytes.sublist(sent, sent + take);
        final envelope = jsonEncode({"m": {"id": msgId, "part": part, "total": total}, "d": base64.encode(chunk)});
        final bytesToSend = Uint8List.fromList(utf8.encode(envelope));
        await _engine.sendStreamMessage(streamId: _dataStreamId!, data: bytesToSend, length: bytesToSend.length);
        sent += take;
        part++;
        await Future.delayed(const Duration(milliseconds: 6));
      }

      setState(() {
        _comments.add(_Comment('You', text, DateTime.now()));
        _inputCtrl.clear();
      });
      _scrollDown();
    } catch (e) {
      debugPrint('[Viewer] Send ERROR: $e');
    } finally {
      // Step 3: Revert role back to audience regardless of send success/failure
      try {
        await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
      } catch (e) {
        debugPrint('[Viewer] revert role FAILED: $e');
      }
      _dataStreamId = null;
      _streamReady = false;
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent + 80,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollController.dispose();
    try {
      _engine.leaveChannel();
      _engine.release();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waiting = hostUid == null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: waiting
                ? const Text("Waiting for host...", style: TextStyle(color: Colors.white))
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
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
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
                      hintStyle: const TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: Colors.black38,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (s) => setState(() {}),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _canSend ? Colors.purpleAccent : Colors.grey,
                  child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: _canSend ? _sendMessage : null),
                )
              ],
            ),
          ),

          Positioned(
            top: 40,
            left: 12,
            child: CircleAvatar(child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
          ),
        ],
      ),
    );
  }
}

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
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text("${c.user}: ${c.text}", style: const TextStyle(color: Colors.white)));
  }
}