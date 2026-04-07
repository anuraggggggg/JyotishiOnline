// lib/controllers/liveController.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../fastApi/fastApiServices.dart';
import '../model/fastApiModel/LiveAstrologerModel.dart';
import '../model/fastApiModel/astrologerProfileModel.dart';
import '../model/fastApiModel/currentUserWalletModel.dart';
import '../model/fastApiModel/giftModel.dart';

// ─── Chat Message Model ──────────────────────────────────────────────────────

enum SenderType { me, host, viewer, giftAnnounce }

class LiveChatMessage {
  final String displayName;
  final String text;
  final DateTime at;
  final SenderType type;
  final String? giftEmoji;
  final int? giftQty;
  final int? giftTotal;

  LiveChatMessage({
    required this.displayName,
    required this.text,
    required this.at,
    required this.type,
    this.giftEmoji,
    this.giftQty,
    this.giftTotal,
  });
}

// ─── Live Controller ─────────────────────────────────────────────────────────

class NewLiveController extends GetxController {
  final FastAPIServices _api = FastAPIServices();

  // ── Observables ─────────────────────────────────────────────────────────────
  final RxList<LiveChatMessage> messages = <LiveChatMessage>[].obs;
  final RxList<GiftModel> gifts = <GiftModel>[].obs;
  final RxBool isLoadingGifts = false.obs;
  final RxBool isSendingGift = false.obs;
  final RxBool isSessionEnded = false.obs;

  final RxInt viewerCount = 0.obs;
  final RxInt selectedGiftIdx = 0.obs;
  final RxInt giftQty = 1.obs;

  final RxDouble walletBalance = 0.0.obs;
  final RxString myName = 'You'.obs;
  final RxString astrologerName = 'Astrologer'.obs;
  final Rx<Astrologer?> astrologer = Rx<Astrologer?>(null);
  final Rx<CurrentUserWalletModel?> wallet = Rx<CurrentUserWalletModel?>(null);

  final RxBool isJoining = true.obs;
  final RxBool isRoleSwitching = false.obs;
  final RxBool showChat = true.obs;
  final RxBool showConsultButtons = true.obs;

  // ── Gift animation trigger ───────────────────────────────────────────────
  // Listeners in the view subscribe to this stream
  final _giftAnimStream = StreamController<_GiftAnimEvent>.broadcast();
  Stream<_GiftAnimEvent> get giftAnimStream => _giftAnimStream.stream;

  // ── Internal ─────────────────────────────────────────────────────────────
  final Map<int, String> _uidNameCache = {};
  final Map<String, List<String?>> _recvParts = {};

  String get astroId => astrologer.value?.astroId ?? '';

  int get giftTotal {
    if (gifts.isEmpty || selectedGiftIdx.value >= gifts.length) return 0;
    return gifts[selectedGiftIdx.value].price * giftQty.value;
  }

  GiftModel? get selectedGift {
    if (gifts.isEmpty || selectedGiftIdx.value >= gifts.length) return null;
    return gifts[selectedGiftIdx.value];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> init(String astroId) async {
    await Future.wait([
      _loadProfile(astroId),
      _loadGifts(),
      _loadWallet(),
    ]);
  }

  Future<void> _loadProfile(String astroId) async {
    try {
      final user = await _api.fetchCurrentUserDetails();
      myName.value = (user.name?.trim().isNotEmpty ?? false) ? user.name!.trim() : 'Guest';

      final astro = await _api.fetchAstrologerDetail(astroId);
      astrologer.value = astro;
      astrologerName.value = astro.name.trim();
    } catch (e) {
      debugPrint('❌ [LiveController] _loadProfile error: $e');
    }
  }

  Future<void> _loadGifts() async {
    isLoadingGifts.value = true;
    try {
      final result = await _api.getCosmicServices();
      // getCosmicServices returns List<dynamic>; map to GiftModel
      // If you have a dedicated gift endpoint, use that instead.
      gifts.value = result
          .map((e) => GiftModel.fromJson(e as Map<String, dynamic>))
          .where((g) => g.isActive)
          .toList();
    } catch (e) {
      debugPrint('❌ [LiveController] _loadGifts error: $e');
    } finally {
      isLoadingGifts.value = false;
    }
  }

  Future<void> _loadWallet() async {
    try {
      final w = await _api.fetchCurrentWallet();
      wallet.value = w;
      walletBalance.value = (w?.amount ?? 0).toDouble();
    } catch (e) {
      debugPrint('❌ [LiveController] _loadWallet error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GIFT SELECTION
  // ─────────────────────────────────────────────────────────────────────────

  void selectGift(int idx) {
    selectedGiftIdx.value = idx;
    giftQty.value = 1;
  }

  void incrementQty() {
    if (giftQty.value < 10) giftQty.value++;
  }

  void decrementQty() {
    if (giftQty.value > 1) giftQty.value--;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SEND GIFT
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> sendGift() async {
    final gift = selectedGift;
    if (gift == null) return false;

    final total = giftTotal;

    if (total > walletBalance.value) {
      Get.snackbar(
        'Insufficient Balance',
        'Please recharge your wallet to send gifts.',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    isSendingGift.value = true;
    try {
      await _api.loadFromStorage();
      await _api.sendMoney(
        astrologerId: astrologer.value!.astroId,
        amount: total,
        type: 'gift',
      );

      // Deduct locally for instant UI feedback
      walletBalance.value -= total;

      // Add gift announce message to chat
      _addGiftAnnounce(
        name: myName.value,
        emoji: gift.icon,
        giftName: gift.name,
        qty: giftQty.value,
        total: total,
      );

      // Fire animation event
      _giftAnimStream.add(_GiftAnimEvent(
        emoji: gift.icon,
        qty: giftQty.value,
      ));

      isSendingGift.value = false;
      return true;
    } catch (e) {
      isSendingGift.value = false;
      debugPrint('❌ [LiveController] sendGift error: $e');
      Get.snackbar(
        'Failed',
        'Could not send gift. ${e.toString()}',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CHAT
  // ─────────────────────────────────────────────────────────────────────────

  void addMyMessage(String text) {
    if (text.trim().isEmpty) return;
    messages.add(LiveChatMessage(
      displayName: myName.value,
      text: text,
      at: DateTime.now(),
      type: SenderType.me,
    ));
  }

  void handleIncomingChunk(int senderUid, Uint8List data, int? hostAgoraUid) {
    try {
      final trimmed = _trimNulls(Uint8List.fromList(data));
      final envelope = jsonDecode(utf8.decode(trimmed));
      final m = envelope['m'];
      final d = envelope['d'];
      if (m == null || d == null) return;

      final id = m['id'] as String;
      final part = m['part'] as int;
      final total = m['total'] as int;

      _recvParts.putIfAbsent(id, () => List<String?>.filled(total, null));
      _recvParts[id]![part] = d as String;
      if (_recvParts[id]!.any((p) => p == null)) return;

      final combined = <int>[];
      for (final p in _recvParts[id]!) {
        combined.addAll(base64.decode(p!));
      }
      _recvParts.remove(id);

      final obj = jsonDecode(utf8.decode(combined)) as Map<String, dynamic>;

      final String senderName;
      final SenderType senderType;

      if (senderUid == hostAgoraUid) {
        senderName = astrologerName.value;
        senderType = SenderType.host;
      } else {
        final payloadName = (obj['user'] as String?)?.trim() ?? '';
        senderName = _uidNameCache.putIfAbsent(
          senderUid,
              () => payloadName.isNotEmpty ? payloadName : 'Viewer',
        );
        senderType = SenderType.viewer;
      }

      messages.add(LiveChatMessage(
        displayName: senderName,
        text: obj['text'] as String? ?? '',
        at: DateTime.now(),
        type: senderType,
      ));
    } catch (e) {
      debugPrint('❌ [LiveController] handleIncomingChunk: $e');
    }
  }

  void _addGiftAnnounce({
    required String name,
    required String emoji,
    required String giftName,
    required int qty,
    required int total,
  }) {
    messages.add(LiveChatMessage(
      displayName: name,
      text: 'sent ${qty}x $giftName to ${astrologerName.value}!',
      at: DateTime.now(),
      type: SenderType.giftAnnounce,
      giftEmoji: emoji,
      giftQty: qty,
      giftTotal: total,
    ));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SESSION
  // ─────────────────────────────────────────────────────────────────────────

  void onJoined() => isJoining.value = false;
  void onSessionEnded() => isSessionEnded.value = true;
  void setViewerCount(int count) => viewerCount.value = count;
  void setRoleSwitching(bool v) => isRoleSwitching.value = v;
  void setBroadcaster(bool v) {} // internal, tracked in view

  void toggleChat() => showChat.toggle();
  void hideConsultButtons() => showConsultButtons.value = false;

  // ─────────────────────────────────────────────────────────────────────────
  // CONSULTATION NOTIFY
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> sendNotification(String callType) async {
    if (astrologer.value == null) return;
    try {
      String title, body, screen;
      switch (callType.toLowerCase()) {
        case 'audio':
          title = 'Incoming Audio Call 📞';
          body = '${myName.value} wants audio.';
          screen = 'AudioCallScreen';
          break;
        case 'video':
          title = 'Incoming Video Call 🎥';
          body = '${myName.value} wants video.';
          screen = 'VideoCallScreen';
          break;
        default:
          title = 'New Chat Request 💬';
          body = '${myName.value} wants to chat.';
          screen = 'ChatScreen';
      }
      await _api.sendNotificationToAstrologer(
        astrologerId: astrologer.value!.astroId,
        title: title,
        body: body,
        screen: screen,
        data: {
          'client_name': myName.value,
          'timestamp': DateTime.now().toIso8601String(),
          'call_type': callType,
          'astro_id': astrologer.value!.astroId,
        },
      );
    } catch (e) {
      debugPrint('❌ [LiveController] sendNotification: $e');
    }
  }

  Future<Map<String, dynamic>?> createConsultSession(String callType) async {
    await _api.loadFromStorage();
    final mapped = callType.toLowerCase() == 'audio'
        ? 'audio_call'
        : callType.toLowerCase() == 'video'
        ? 'video_call'
        : 'chat';
    return _api.createSession(
      astrologerId: astrologer.value!.astroId,
      sessionType: mapped,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Uint8List _trimNulls(Uint8List b) {
    int s = 0, e = b.length;
    while (s < e && b[s] == 0) s++;
    while (e > s && b[e - 1] == 0) e--;
    return b.sublist(s, e);
  }

  @override
  void onClose() {
    _giftAnimStream.close();
    super.onClose();
  }
}

// ─── Internal event ──────────────────────────────────────────────────────────

class _GiftAnimEvent {
  final String emoji;
  final int qty;
  const _GiftAnimEvent({required this.emoji, required this.qty});
}