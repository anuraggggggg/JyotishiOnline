// lib/views/LiveViewerPage.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../../fastApi/fastApiServices.dart';
import '../../model/fastApiModel/astrologerProfileModel.dart';
import '../../theme/appTheme.dart';
import '../audioCall/newAudioCall.dart';
import '../chat/newChatScreen.dart';
import '../chat/video_call_page.dart';

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

  // USER + ASTROLOGER NAMES
  String myName = "You";
  String astrologerName = "Astrologer";

  // FULL ASTROLOGER OBJECT (needed for charges, ids, etc.)
  Astrologer? _astrologer;

  // to avoid double-tap on Pay & Start
  bool _isProcessing = false;

  // CHUNK REASSEMBLY BUFFERS
  final Map<String, List<String?>> _recvParts = {};
  final Map<String, int> _recvTotal = {};

  final List<_Comment> _comments = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputCtrl = TextEditingController();

  static const String _agoraAppId = "3a39af44074a40bebc2fff2cba7437e5";

  bool get _canSend => !_joining && _inputCtrl.text.trim().isNotEmpty;

  // UI State
  bool _showChat = true;
  bool _showConsultButtons = true;

  // simple logger
  void _d(Object msg) => debugPrint("🧭 [LiveViewer] $msg");

  @override
  void initState() {
    super.initState();
    _myUid = Random().nextInt(900000) + 2000;
    _d("initState → myUid=$_myUid channel=${widget.channelName} astroId=${widget.astroId}");

    _loadNamesAndAstrologer();
    _initRTC();
  }

  // ==========================================================
  // LOAD USER NAME + ASTROLOGER DETAIL
  // ==========================================================
  Future<void> _loadNamesAndAstrologer() async {
    try {
      final svc = FastAPIServices();
      await svc.loadFromStorage();

      // LOAD VIEWER NAME from prefs
      myName = await svc.getUserName() ?? "You";

      // LOAD ASTROLOGER DETAIL (name + charges)
      final astro = await svc.fetchAstrologerDetail(widget.astroId);
      _astrologer = astro;
      astrologerName = astro.name.trim();

      _d("Loaded astrologer: id=${astro.astroId}, name=${astro.name}, "
          "audio=${astro.audioCallCharge}, video=${astro.videoCallCharge}, chat=${astro.chatCharge}");

      if (mounted) setState(() {});
    } catch (e, st) {
      _d("Error loading names/astrologer: $e\n$st");
      astrologerName = "Astrologer";
      myName = "You";
      if (mounted) setState(() {});
    }
  }

  // ==========================================================
  // INIT AGORA RTC
  // ==========================================================
  Future<void> _initRTC() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: _agoraAppId));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) async {
          _d("Joined channel as audience, uid=$_myUid");
          if (mounted) setState(() => _joining = false);
        },
        onUserJoined: (connection, uid, elapsed) {
          _d("Host joined: uid=$uid");
          if (mounted) setState(() => hostUid = uid);
        },
        onUserOffline: (connection, uid, reason) {
          _d("User offline: uid=$uid, reason=$reason");
          if (hostUid == uid && mounted) {
            setState(() => hostUid = null);
          }
        },
        onStreamMessage: (connection, uid, streamId, data, offset, length) {
          _handleIncomingChunk(uid, data);
        },
        onError: (err, msg) {
          _d("Agora error $err $msg");
        },
      ),
    );

    await _engine.setChannelProfile(
      ChannelProfileType.channelProfileLiveBroadcasting,
    );
    await _engine.setClientRole(
      role: ClientRoleType.clientRoleAudience,
    );
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

  // ==========================================================
  // CLEAN NULL PADDING
  // ==========================================================
  Uint8List _trimNulls(Uint8List bytes) {
    int start = 0;
    int end = bytes.length;
    while (start < end && bytes[start] == 0) start++;
    while (end > start && bytes[end - 1] == 0) end--;
    return bytes.sublist(start, end);
  }

  // ==========================================================
  // HANDLE RECEIVED CHUNKED JSON
  // ==========================================================
  void _handleIncomingChunk(int senderUid, Uint8List data) {
    try {
      final cleaned = _trimNulls(Uint8List.fromList(data));
      final envelopeText = utf8.decode(cleaned);
      final envelope = jsonDecode(envelopeText);

      final m = envelope["m"];
      final d = envelope["d"];

      if (m == null || d == null) return;

      final id = m["id"];
      final part = m["part"];
      final total = m["total"];

      _recvParts.putIfAbsent(id, () => List<String?>.filled(total, null));
      _recvParts[id]![part] = d;
      _recvTotal[id] = total;

      final parts = _recvParts[id]!;
      if (parts.any((p) => p == null)) return;

      final combinedBytes = <int>[];
      for (var p in parts) {
        combinedBytes.addAll(base64.decode(p!));
      }

      _recvParts.remove(id);
      _recvTotal.remove(id);

      final payload = utf8.decode(combinedBytes);
      final obj = jsonDecode(payload);

      final senderName =
      (senderUid == hostUid) ? astrologerName : (obj["user"] ?? "User");

      setState(() {
        _comments.add(_Comment(senderName, obj["text"] ?? "", DateTime.now()));
      });

      _scrollDown();
    } catch (e, st) {
      _d("Incoming chunk error: $e\n$st");
    }
  }

  // ==========================================================
  // PREPARE STREAM FOR SEND
  // ==========================================================
  Future<void> _prepareStreamForSend() async {
    if (_streamReady && _dataStreamId != null) return;

    try {
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await Future.delayed(const Duration(milliseconds: 500));

      _dataStreamId = await _engine.createDataStream(
        const DataStreamConfig(
          syncWithAudio: false,
          ordered: true,
        ),
      );

      _streamReady = true;
      _d("Data stream created: id=$_dataStreamId");
    } catch (e) {
      _d("createDataStream failed: $e");
      await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    }
  }

  // ==========================================================
  // SEND COMMENT (CHUNKED)
  // ==========================================================
  Future<void> _sendMessage([String? maybeText]) async {
    final text = (maybeText ?? _inputCtrl.text).trim();
    if (text.isEmpty) return;

    try {
      await _prepareStreamForSend();
      if (_dataStreamId == null) return;

      final payloadMap = {
        "user": myName,
        "text": text,
        "ts": DateTime.now().toIso8601String()
      };

      final bytes = utf8.encode(jsonEncode(payloadMap));
      final msgId =
          "${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}";

      const chunkSize = 900;
      final total = ((bytes.length + chunkSize - 1) / chunkSize).floor();

      int sent = 0;
      int part = 0;

      while (sent < bytes.length) {
        final take = min(chunkSize, bytes.length - sent);
        final chunk = bytes.sublist(sent, sent + take);

        final envelope = jsonEncode({
          "m": {"id": msgId, "part": part, "total": total},
          "d": base64.encode(chunk),
        });

        final encoded = utf8.encode(envelope);

        await _engine.sendStreamMessage(
          streamId: _dataStreamId!,
          data: Uint8List.fromList(encoded),
          length: encoded.length,
        );

        sent += take;
        part++;
        await Future.delayed(const Duration(milliseconds: 5));
      }

      setState(() {
        _comments.add(_Comment("$myName (You)", text, DateTime.now()));
      });

      _inputCtrl.clear();
      _scrollDown();
    } catch (e, st) {
      _d("Send error: $e\n$st");
    } finally {
      await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
      _dataStreamId = null;
      _streamReady = false;
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
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

  // ==========================================================
  // DISCLAIMER POPUP (same as detail page logic)
  // ==========================================================
  Future<bool> _showDisclaimerDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Disclaimer",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Text(
              "The platform will not be held responsible for any financial transactions conducted outside the platform with the astrologer.",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: appColor),
              child: const Text(
                "I Accept",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  // ==========================================================
  // SEND FCM NOTIFICATION TO ASTROLOGER (after session creation)
  // ==========================================================
  Future<void> _sendAstrologerNotification(
      Astrologer astrologer,
      String type,
      ) async {
    try {
      final api = FastAPIServices();
      String title, body, screen;

      switch (type.toLowerCase()) {
        case 'audio':
          title = "Incoming Audio Call 📞";
          body = "A client wants to start an audio consultation with you.";
          screen = "AudioCallScreen";
          break;
        case 'video':
          title = "Incoming Video Call 🎥";
          body = "A client wants to start a video consultation with you.";
          screen = "VideoCallScreen";
          break;
        default:
          title = "New Chat Request 💬";
          body = "A client wants to start a chat consultation with you.";
          screen = "ChatScreen";
      }

      final payload = {
        "client_name": myName,
        "timestamp": DateTime.now().toIso8601String(),
        "call_type": type,
      };

      _d("Sending notification to ${astrologer.name} (${astrologer.astroId}) → $title");
      final res = await api.sendNotificationToAstrologer(
        astrologerId: astrologer.astroId,
        title: title,
        body: body,
        screen: screen,
        data: payload,
      );

      if (res["success"] == true) {
        _d("Notification sent successfully to ${astrologer.name}");
      } else {
        _d("Failed to send notification: ${res['error']}");
      }
    } catch (e, st) {
      _d("Exception in _sendAstrologerNotification: $e\n$st");
    }
  }

  // ==========================================================
  // PAYMENT: WALLET CHECK + SEND MONEY
  // ==========================================================
  Future<bool> _payIfEnoughBalance({
    required String astrologerId,
    required int amountInRupees,
    required BuildContext notifyContext,
  }) async {
    _d("payIfEnoughBalance() astroId=$astrologerId amount=₹$amountInRupees");
    try {
      final api = FastAPIServices();

      final wallet = await api.fetchCurrentWallet();
      if (wallet == null) {
        _d("wallet == null");
        ScaffoldMessenger.of(notifyContext).showSnackBar(
          const SnackBar(
            content: Text("Unable to fetch wallet. Please try again."),
          ),
        );
        return false;
      }

      final current = (wallet.amount ?? 0);
      _d("wallet.amount=$current");

      if (current < amountInRupees) {
        final short = amountInRupees - current;
        _d("insufficient balance. need +₹$short");
        ScaffoldMessenger.of(notifyContext).showSnackBar(
          SnackBar(
            content: Text("Insufficient balance. You need ₹$short more."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      _d("sendMoney() → astrologerId=$astrologerId amount=₹$amountInRupees");
      await api.sendMoney(
        astrologerId: astrologerId,
        amount: amountInRupees,
      );
      _d("sendMoney success");

      ScaffoldMessenger.of(notifyContext).showSnackBar(
        SnackBar(
          content: Text("₹$amountInRupees paid successfully."),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } catch (e, st) {
      _d("sendMoney failed: $e\n$st");
      ScaffoldMessenger.of(notifyContext).showSnackBar(
        SnackBar(content: Text("Payment failed: $e")),
      );
      return false;
    }
  }

  // ==========================================================
  // MAIN FLOW: PAY + CREATE SESSION + NOTIFY + NAVIGATE
  // ==========================================================
  void _onConsultTap(String callType) async {
    if (_astrologer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Astrologer details are still loading. Please wait."),
        ),
      );
      return;
    }

    await _showCallRequestDialog(_astrologer!, callType);
  }

  _showCallRequestDialog(Astrologer astrologer, String callType) async {
    final BuildContext pageContext = context;

    // Step 1: Disclaimer
    final accepted = await _showDisclaimerDialog(context);
    if (!accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must accept the disclaimer before proceeding."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final isAudio = callType.toLowerCase().startsWith('audio');
    final isVideo = callType.toLowerCase().startsWith('video');
    final isChat = callType.toLowerCase().startsWith('chat');

    final double rate = isAudio
        ? astrologer.audioCallCharge
        : isVideo
        ? astrologer.videoCallCharge
        : astrologer.chatCharge;

    // For audio/video we bill per 10-minute block at `rate`. Chat is per message.
    final bool pricedPerTenMinBlock = isAudio || isVideo;

    _d("open bottom sheet type=$callType rate=$rate per ${pricedPerTenMinBlock ? '10min' : 'message'}");

    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetCtx, setSB) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$callType Consultation',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'with ${astrologer.name}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Amount card — debit ONE 10-min block for audio/video (no multiplication)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: appColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: appColor.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pricedPerTenMinBlock
                              ? 'Amount to Debit (10 min)'
                              : 'Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '₹ ${rate.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: appColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isProcessing
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                          : Text(
                        pricedPerTenMinBlock
                            ? "Pay & Start (10 min)"
                            : "Pay & Start",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _isProcessing
                          ? null
                          : () async {
                        setSB(() => _isProcessing = true);
                        try {
                          _d("[SEND_REQUEST] type=$callType astroId=${astrologer.astroId}");

                          // Map callType → backend enum
                          String mappedSessionType;
                          switch (callType.toLowerCase()) {
                            case "audio":
                            case "audio call":
                              mappedSessionType = "audio_call";
                              break;
                            case "video":
                            case "video call":
                              mappedSessionType = "video_call";
                              break;
                            case "chat":
                            default:
                              mappedSessionType = "chat";
                          }
                          _d("mappedSessionType=$mappedSessionType");

                          final double rawAmount = rate;
                          final int amountToCharge = rawAmount.round();

                          if (amountToCharge <= 0) {
                            _d("amountToCharge<=0, abort");
                            ScaffoldMessenger.of(sheetCtx).showSnackBar(
                              const SnackBar(
                                content:
                                Text("Invalid amount to charge."),
                              ),
                            );
                            return;
                          }

                          // Step 1: Wallet debit
                          final paid = await _payIfEnoughBalance(
                            astrologerId: astrologer.astroId,
                            amountInRupees: amountToCharge,
                            notifyContext: sheetCtx,
                          );
                          if (!paid) {
                            _d("payment failed / insufficient, abort");
                            return;
                          }

                          // Step 2: Create session
                          await FastAPIServices().loadFromStorage();
                          final myUserIdFromStorage =
                              FastAPIServices().userId;
                          _d("storage userId=$myUserIdFromStorage");

                          final dynamic raw =
                          await FastAPIServices().createSession(
                            astrologerId: astrologer.astroId,
                            sessionType: mappedSessionType,
                          );
                          _d("createSession raw=$raw");

                          Map<String, dynamic>? session;
                          if (raw is Map<String, dynamic>) {
                            session = raw;
                          } else if (raw is String) {
                            try {
                              final decoded = jsonDecode(raw);
                              if (decoded is Map<String, dynamic>) {
                                session = decoded;
                              }
                            } catch (e) {
                              _d("decode string->map failed: $e");
                            }
                          }

                          if (session == null) {
                            _d("session==null");
                            ScaffoldMessenger.of(sheetCtx).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Failed to create session. Please try again.",
                                ),
                              ),
                            );
                            return;
                          }

                          final Map<String, dynamic> s =
                          Map<String, dynamic>.from(session);
                          final String roomId =
                          (s["room_id"] ?? "").toString();
                          _d("session.room_id=$roomId");

                          // user field
                          final dynamic userField = s["user"];
                          String userUid = '';
                          if (userField is Map) {
                            final m =
                            Map<String, dynamic>.from(userField);
                            userUid = (m['id'] ??
                                m['user_id'] ??
                                m['uid'] ??
                                m['uuid'] ??
                                '')
                                .toString();
                          } else if (userField is String) {
                            userUid = userField;
                          }
                          if (userUid.isEmpty) {
                            userUid = (s["user_id"] ??
                                myUserIdFromStorage ??
                                '')
                                .toString();
                          }
                          _d("session.userUid=$userUid");

                          // astrologer field
                          String astrologerUid = '';
                          final dynamic astroField = s["astrologer"];
                          if (astroField is Map) {
                            final m =
                            Map<String, dynamic>.from(astroField);
                            astrologerUid = (m['id'] ??
                                m['astro_id'] ??
                                m['uid'] ??
                                m['uuid'] ??
                                '')
                                .toString();
                          }
                          if (astrologerUid.isEmpty) {
                            astrologerUid =
                                (s["astrologer_id"] ?? astrologer.astroId)
                                    .toString();
                          }
                          _d("session.astrologerUid=$astrologerUid");

                          final String apiType =
                          (s["session_type"] ?? "").toString();
                          _d("session.session_type=$apiType");

                          final missing = <String>[];
                          if (roomId.isEmpty) missing.add('roomId');
                          if (userUid.isEmpty) missing.add('userUid');
                          if (astrologerUid.isEmpty) {
                            missing.add('astrologerUid');
                          }
                          if (missing.isNotEmpty) {
                            _d("missing: ${missing.join(', ')}");
                            ScaffoldMessenger.of(sheetCtx).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Couldn't get session details (${missing.join(', ')}). Please try again.",
                                ),
                              ),
                            );
                            return;
                          }

                          // Step 3: send notification AFTER payment + session
                          _d("send notification now...");
                          await _sendAstrologerNotification(
                            astrologer,
                            callType,
                          );

                          // Close sheet
                          if (Navigator.of(sheetCtx).canPop()) {
                            Navigator.of(sheetCtx).pop();
                          }
                          if (!mounted) return;

                          // Step 4: navigate to chat / audio / video screen
                          _showRequestSentDialog(
                            callType,
                            onOk: () {
                              final type = apiType.toLowerCase();
                              _d("navigate type=$type");
                              if (type == 'chat') {
                                Navigator.of(
                                  pageContext,
                                  rootNavigator: true,
                                ).push(
                                  MaterialPageRoute(
                                    builder: (_) => CustomerChatPage(
                                      chatRate: astrologer.chatCharge,
                                      astrologerUid: astrologerUid,
                                      myUserId: userUid,
                                      roomId: roomId,
                                      astrologerName: astrologer.name,
                                    ),
                                  ),
                                );
                              } else if (type == 'video_call') {
                                Navigator.of(
                                  pageContext,
                                  rootNavigator: true,
                                ).push(
                                  MaterialPageRoute(
                                    builder: (_) => CustomerVideoCallPage(
                                      astroId: astrologerUid,
                                    ),
                                  ),
                                );
                              } else if (type == 'audio_call') {
                                Navigator.of(
                                  pageContext,
                                  rootNavigator: true,
                                ).push(
                                  MaterialPageRoute(
                                    builder: (_) => AudioCallPage(
                                      otherUserId: astrologerUid,
                                    ),
                                  ),
                                );
                              } else {
                                // fallback to chat
                                Navigator.of(
                                  pageContext,
                                  rootNavigator: true,
                                ).push(
                                  MaterialPageRoute(
                                    builder: (_) => CustomerChatPage(
                                      chatRate: astrologer.chatCharge,
                                      astrologerUid: astrologerUid,
                                      myUserId: userUid,
                                      roomId: roomId,
                                      astrologerName: astrologer.name,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        } catch (e, st) {
                          _d("Exception in SEND_REQUEST: $e\n$st");
                          if (mounted) {
                            ScaffoldMessenger.of(sheetCtx).showSnackBar(
                              SnackBar(
                                content:
                                Text("Something went wrong: $e"),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setSB(() => _isProcessing = false);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRequestSentDialog(
      String requestType, {
        VoidCallback? onOk,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              Text(
                "Request Sent!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Your $requestType request has been sent successfully. "
                    "You will be notified when the astrologer accepts your request.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    if (onOk != null) onOk();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // UPDATED UI WITH VERTICAL BUTTONS
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    final waiting = hostUid == null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // VIDEO STREAM
            Center(
              child: waiting
                  ? Container(
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Waiting for $astrologerName...",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
                  : AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine,
                  canvas: VideoCanvas(uid: hostUid),
                  connection: RtcConnection(
                    channelId: widget.channelName,
                  ),
                ),
              ),
            ),

            // ENHANCED HEADER
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            astrologerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Live Session",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!waiting)
                      Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.red, Colors.orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "LIVE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ENHANCED CHAT PANEL
            if (_showChat && _comments.isNotEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 180, // Increased bottom margin to accommodate vertical buttons
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                    minHeight: 80,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        // Chat header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Live Chat (${_comments.length})",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  _showChat ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showChat = !_showChat;
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: _comments.length,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemBuilder: (_, i) => _CommentTile(c: _comments[i]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // VERTICAL CONSULTATION BUTTONS (Video, Audio, Chat)
            if (_showConsultButtons && _astrologer != null)
              Positioned(
                right: 16,
                bottom: 100, // Positioned above the input bar
                child: _buildVerticalConsultButtons(),
              ),

            // TOGGLE BUTTONS FOR UI ELEMENTS
            Positioned(
              left: 16,
              bottom: 100, // Moved up to make space for vertical buttons
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    _buildToggleButton(
                      icon: Icons.chat,
                      isActive: _showChat,
                      onTap: () => setState(() => _showChat = !_showChat),
                    ),
                    const SizedBox(width: 8),
                    _buildToggleButton(
                      icon: Icons.phone_in_talk,
                      isActive: _showConsultButtons,
                      onTap: () => setState(() => _showConsultButtons = !_showConsultButtons),
                    ),
                  ],
                ),
              ),
            ),

            // ENHANCED INPUT BAR
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: "Send a message...",
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _canSend
                            ? const LinearGradient(
                          colors: [
                            Color(0xFF667EEA),
                            Color(0xFF764BA2),
                          ],
                        )
                            : LinearGradient(
                          colors: [
                            Colors.grey.shade600,
                            Colors.grey.shade600,
                          ],
                        ),
                        boxShadow: _canSend
                            ? [
                          BoxShadow(
                            color: const Color(0xFF667EEA).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                            : [],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: _canSend ? _sendMessage : null,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? appColor.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isActive ? appColor : Colors.white.withOpacity(0.3),
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? appColor : Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // VERTICAL CONSULTATION BUTTONS (Video, Audio, Chat)
  // ==========================================================
  Widget _buildVerticalConsultButtons() {
    if (_astrologer == null) {
      return const SizedBox.shrink();
    }
    final astro = _astrologer!;

    final hasAudio = astro.audioCallCharge > 0;
    final hasVideo = astro.videoCallCharge > 0;
    final hasChat = astro.chatCharge > 0;

    String _price(double v, String suffix) {
      if (v <= 0) return 'N/A';
      return '₹${v.toStringAsFixed(0)}$suffix';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasVideo)
            _buildVerticalConsultButton(
              icon: Icons.videocam,
              label: "Video Call",
              price: _price(astro.videoCallCharge, "/10m"),
              color: Colors.greenAccent,
              onTap: () => _onConsultTap("Video"),
            ),
          if (hasVideo && hasAudio) const SizedBox(height: 12),
          if (hasAudio)
            _buildVerticalConsultButton(
              icon: Icons.call,
              label: "Audio Call",
              price: _price(astro.audioCallCharge, "/10m"),
              color: Colors.blueAccent,
              onTap: () => _onConsultTap("Audio"),
            ),
          if ((hasVideo || hasAudio) && hasChat) const SizedBox(height: 12),
          if (hasChat)
            _buildVerticalConsultButton(
              icon: Icons.chat,
              label: "Chat",
              price: _price(astro.chatCharge, "/msg"),
              color: Colors.orangeAccent,
              onTap: () => _onConsultTap("Chat"),
            ),
        ],
      ),
    );
  }

  Widget _buildVerticalConsultButton({
    required IconData icon,
    required String label,
    required String price,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 120,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// ENHANCED COMMENT MODELS + TILE
// ==========================================================
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
    final isYou = c.user.contains("(You)");
    final time = "${c.at.hour.toString().padLeft(2, '0')}:${c.at.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isYou
            ? appColor.withOpacity(0.15)
            : Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isYou
              ? appColor.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                c.user.split(' (You)').first,
                style: TextStyle(
                  color: isYou ? appColor : Colors.blue.shade200,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            c.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}