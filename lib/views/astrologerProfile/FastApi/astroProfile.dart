import 'dart:convert';
import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../fastApi/fastApiServices.dart';
import '../../../model/fastApiModel/astrologerProfileModel.dart';
import '../../../theme/appTheme.dart';
import '../../audioCall/newAudioCall.dart';
import '../../chat/newChatScreen.dart';
import '../../chat/video_call_page.dart';

class AstrologerDetailPage extends StatefulWidget {
  final String astroId;

  const AstrologerDetailPage({super.key, required this.astroId});

  @override
  State<AstrologerDetailPage> createState() => _AstrologerDetailPageState();
}

class _AstrologerDetailPageState extends State<AstrologerDetailPage> {
  late Future<Astrologer> astrologerFuture;

  /// We keep this as 10 to represent one billing block, but we DO NOT multiply price by this anymore.
  final int _defaultDurationMins = 10;

  // Optional debug holders
  String? _lastRoomId;
  String? _lastAstrologerUid;
  String? _lastMyUserId;

  // Prevent double taps
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _d("🔵 initState: astroId=${widget.astroId}");
    astrologerFuture = FastAPIServices().fetchAstrologerDetail(widget.astroId);
    fetchTokenId();
  }

  Future<void> fetchTokenId() async {
    _d("🟡 fetchTokenId() → loadFromStorage()");
    final fastApi = FastAPIServices();
    await fastApi.loadFromStorage();
    _d("🟢 fetchTokenId() done. userId=${fastApi.userId}, hasToken=${fastApi.accessToken != null}");
  }

  // ⚠️ Disclaimer Popup
  Future<bool> _showDisclaimerDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Disclaimer",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ).tr(),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "The platform will not be held responsible for any financial transactions conducted outside the platform with the astrologer.",
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ).tr(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: appColor),
              child: Text("I Accept", style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  // Simple debug printer
  void _d(Object msg) => debugPrint("🧭 [AstroDetail] $msg");

  @override
  Widget build(BuildContext context) {
    _d("🔵 build() called");
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Astrologer Profile",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.report_problem_outlined, color: Colors.grey.shade600),
            onPressed: _showReportDialog,
            tooltip: 'Report Astrologer',
          ),
          IconButton(
            icon: Icon(Icons.block, color: Colors.red.shade400),
            onPressed: _showBlockDialog,
            tooltip: 'Block Astrologer',
          ),
        ],
      ),
      body: FutureBuilder<Astrologer>(
        future: astrologerFuture,
        builder: (context, snapshot) {
          _d("📦 FutureBuilder state=${snapshot.connectionState} hasErr=${snapshot.hasError} hasData=${snapshot.hasData}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingShimmer();
          } else if (snapshot.hasError) {
            _d("❌ astrologerFuture error: ${snapshot.error}");
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData) {
            _d("⚠️ astrologerFuture returned no data");
            return _buildEmptyState();
          }
          final astrologer = snapshot.data!;
          _d("✅ astrologer loaded: id=${astrologer.astroId}, name=${astrologer.name}");
          return _buildAstrologerUI(astrologer);
        },
      ),
      floatingActionButton: FutureBuilder<Astrologer>(
        future: astrologerFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildFloatingActionButtons(snapshot.data!);
          }
          return const SizedBox();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ---------- UI ----------

  Widget _buildAstrologerUI(Astrologer astrologer) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildHeaderSection(astrologer),
          _buildProfileDetails(astrologer),
          _buildConsultationOptions(astrologer),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Astrologer astrologer) {
    final imageUrl = (astrologer.profileImage ?? '').trim();
    final hasValidImage = _isValidImageUrl(imageUrl);
    final completeImageUrl = hasValidImage ? _getCompleteImageUrl(imageUrl) : '';
    _d("🖼 header: hasValidImage=$hasValidImage url=$completeImageUrl");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [appColor.withOpacity(0.1), appColor.withOpacity(0.05), Colors.white],
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [appColor, appColor.withOpacity(0.7)]),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: hasValidImage ? NetworkImage(completeImageUrl) : null,
                  child: !hasValidImage
                      ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                      : null,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.circle, color: Colors.white, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                astrologer.name,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black87),
                maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false,
              ),
              const SizedBox(width: 8),
              Icon(
                astrologer.isVerified ? Icons.verified : Icons.verified_outlined,
                color: astrologer.isVerified ? appColor : Colors.grey, size: 22,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            astrologer.primarySkill ?? "Astrology Expert",
            style: TextStyle(fontSize: 16, color: appColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_outline, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text("${astrologer.experienceInYears ?? 0} Years Exp", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(width: 16),
              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(astrologer.currentCity ?? "Not specified", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(Astrologer astrologer) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (astrologer.loginBio != null && astrologer.loginBio!.isNotEmpty)
            _buildInfoCard(
              title: 'About Me',
              icon: Icons.info_outline,
              child: Text(astrologer.loginBio!, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5)),
            ),
          if (astrologer.loginBio != null && astrologer.loginBio!.isNotEmpty) const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Professional Background',
            icon: Icons.work_outline,
            child: Column(
              children: [
                _buildProfileRow('Primary Expertise', astrologer.primarySkill ?? 'Not specified'),
                _buildProfileRow('Experience', '${astrologer.experienceInYears ?? 0} Years'),
                _buildProfileRow('Highest Qualification', astrologer.highestQualification ?? 'Not specified'),
                _buildProfileRow('Astrology Education', astrologer.learnAstrology ?? 'Not specified'),
                _buildProfileRow('Currently Working', astrologer.currentlyworkingfulltimejob ?? 'Not specified'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Personal Information',
            icon: Icons.person_outline,
            child: Column(
              children: [
                _buildProfileRow('Languages Known', astrologer.languageKnown ?? 'Not specified'),
                _buildProfileRow('Location', '${astrologer.currentCity ?? 'Not specified'}${astrologer.country != null ? ', ${astrologer.country}' : ''}'),
                _buildProfileRow('Contact Verified', astrologer.isContactVerified ? '✅ Verified' : '❌ Not Verified'),
                _buildProfileRow('Profile Status', astrologer.isVerified ? '✅ Verified Astrologer' : '❌ Not Verified'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Consultation Rates',
            icon: Icons.attach_money_outlined,
            child: Column(
              children: [
                _buildProfileRow('Audio Call', _rateOrNA(astrologer.audioCallCharge, suffix: '/10 min')),
                _buildProfileRow('Video Call', _rateOrNA(astrologer.videoCallCharge, suffix: '/10 min')),
                _buildProfileRow('Chat', _rateOrNA(astrologer.chatCharge, suffix: '/message')),
                if (astrologer.monthlyEarning != null && astrologer.monthlyEarning!.isNotEmpty)
                  _buildProfileRow('Monthly Earnings', '₹ ${astrologer.monthlyEarning}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationOptions(Astrologer astrologer) {
    final hasAudio = (astrologer.audioCallCharge) > 0;
    final hasVideo = (astrologer.videoCallCharge) > 0;
    final hasChat = (astrologer.chatCharge) > 0;

    _d("🎛 options: audio=$hasAudio(${astrologer.audioCallCharge}) video=$hasVideo(${astrologer.videoCallCharge}) chat=$hasChat(${astrologer.chatCharge})");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildInfoCard(
        title: 'Consultation Options',
        icon: Icons.video_call_outlined,
        child: Column(
          children: [
            _buildConsultationOption(
              icon: Icons.audiotrack,
              title: 'Audio Call',
              subtitle: 'Clear voice consultation',
              price: _priceLabel(astrologer.audioCallCharge, '/10 min'),
              features: ['Best for quick guidance', 'Uninterrupted connection'],
              disabled: !hasAudio,
              onTap: () => _showCallRequestDialog(astrologer, 'Audio'),
            ),
            const SizedBox(height: 16),
            _buildConsultationOption(
              icon: Icons.videocam,
              title: 'Video Call',
              subtitle: 'Face-to-face consultation',
              price: _priceLabel(astrologer.videoCallCharge, '/10 min'),
              features: ['Better understanding', 'Screen sharing'],
              disabled: !hasVideo,
              onTap: () => _showCallRequestDialog(astrologer, 'Video'),
            ),
            const SizedBox(height: 16),
            _buildConsultationOption(
              icon: Icons.chat,
              title: 'Chat',
              subtitle: 'Text-based consultation',
              price: _priceLabel(astrologer.chatCharge, '/message'),
              features: ['24×7 availability', 'Share images'],
              disabled: !hasChat,
              onTap: () => _showCallRequestDialog(astrologer, 'Chat'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String price,
    required List<String> features,
    required bool disabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: IgnorePointer(
        ignoring: disabled,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: appColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: appColor, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Text(price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: appColor)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: features
                    .map((f) => Chip(
                  label: Text(f, style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                  backgroundColor: Colors.grey.shade100,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(backgroundColor: appColor, foregroundColor: Colors.white),
                  child: const Text("Continue"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons(Astrologer astrologer) {
    final hasAudio = (astrologer.audioCallCharge) > 0;
    final hasVideo = (astrologer.videoCallCharge) > 0;
    final hasChat = (astrologer.chatCharge) > 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Expanded(child: _buildFAB(icon: Icons.audiotrack, label: 'Audio Call', price: _priceLabel(astrologer.audioCallCharge, '/10 min'), onPressed: hasAudio ? () => _showCallRequestDialog(astrologer, 'Audio') : null, color: Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: _buildFAB(icon: Icons.videocam, label: 'Video Call', price: _priceLabel(astrologer.videoCallCharge, '/10 min'), onPressed: hasVideo ? () => _showCallRequestDialog(astrologer, 'Video') : null, color: Colors.green)),
          const SizedBox(width: 12),
          Expanded(child: _buildFAB(icon: Icons.chat, label: 'Chat', price: _priceLabel(astrologer.chatCharge, '/message'), onPressed: hasChat ? () => _showCallRequestDialog(astrologer, 'Chat') : null, color: Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildFAB({
    required IconData icon,
    required String label,
    required String price,
    required Color color,
    VoidCallback? onPressed,
  }) {
    final disabled = onPressed == null;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                const SizedBox(height: 2),
                Text(price, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w400), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Payment helper (wallet check + transfer) ----------

  Future<bool> _payIfEnoughBalance({
    required String astrologerId,
    required int amountInRupees,
    required BuildContext notifyContext,
  }) async {
    _d("💳 _payIfEnoughBalance() -> astroId=$astrologerId amount=₹$amountInRupees");
    try {
      final api = FastAPIServices();

      _d("🟡 fetchCurrentWallet()");
      final wallet = await api.fetchCurrentWallet();
      if (wallet == null) {
        _d("❌ wallet == null");
        ScaffoldMessenger.of(notifyContext).showSnackBar(const SnackBar(content: Text("Unable to fetch wallet. Please try again.")));
        return false;
      }
      final current = (wallet.amount ?? 0);
      _d("🟢 wallet.amount=$current");

      if (current < amountInRupees) {
        final short = amountInRupees - current;
        _d("⛔ insufficient balance. need +₹$short");
        ScaffoldMessenger.of(notifyContext).showSnackBar(
          SnackBar(content: Text("Insufficient balance. You need ₹$short more."), backgroundColor: Colors.red),
        );
        return false;
      }

      _d("🟡 sendMoney() → astrologerId=$astrologerId amount=₹$amountInRupees");
      await api.sendMoney(astrologerId: astrologerId, amount: amountInRupees);
      _d("✅ sendMoney success");

      ScaffoldMessenger.of(notifyContext).showSnackBar(
        SnackBar(content: Text("₹$amountInRupees paid successfully."), backgroundColor: Colors.green),
      );
      return true;
    } catch (e, st) {
      _d("💥 sendMoney failed: $e\n$st");
      ScaffoldMessenger.of(notifyContext).showSnackBar(SnackBar(content: Text("Payment failed: $e")));
      return false;
    }
  }

  // ---------- Bottom sheet / main flow ----------

  void _showCallRequestDialog(Astrologer astrologer, String callType) async {
    final BuildContext pageContext = context;

    // Show disclaimer first
    final accepted = await _showDisclaimerDialog(context);
    if (!accepted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("You must accept the disclaimer before proceeding."),
        backgroundColor: Colors.orange,
      ));
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

    _d("🟡 openSheet type=$callType (per10min=$pricedPerTenMinBlock) rate=$rate");

    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(builder: (sheetCtx, setSB) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Text('$callType Consultation', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('with ${astrologer.name}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 24),

                // Amount card — debit ONE 10-min block for audio/video (no multiplication)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: appColor.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pricedPerTenMinBlock ? 'Amount to Debit (10 min)' : 'Amount',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                      ),
                      Text(
                        '₹ ${rate.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: appColor),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: appColor),
                    child: _isProcessing
                        ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                    )
                        : Text(
                      pricedPerTenMinBlock ? "Pay & Start (10 min)" : "Pay & Start",
                      style: const TextStyle(color: Colors.white),
                    ),
                    onPressed: _isProcessing
                        ? null
                        : () async {
                      // tap guard
                      setSB(() => _isProcessing = true);
                      try {
                        _d("🟡 [SEND_REQUEST] tap → type=$callType astroId=${astrologer.astroId}");

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
                        _d("✅ mappedSessionType=$mappedSessionType");

                        // 🔑 Debit exactly 1 block for audio/video; chat as given
                        final double rawAmount = rate; // NO MULTIPLICATION
                        final int amountToCharge = rawAmount.round(); // e.g., 250

                        _d("💰 amount calc: rate=$rate per ${pricedPerTenMinBlock ? '10min' : 'message'} → charge=₹$amountToCharge");

                        if (amountToCharge <= 0) {
                          _d("⛔ amountToCharge<=0 → abort");
                          ScaffoldMessenger.of(sheetCtx).showSnackBar(const SnackBar(content: Text("Invalid amount to charge.")));
                          return;
                        }

                        // 1) Wallet pay
                        final paid = await _payIfEnoughBalance(
                          astrologerId: astrologer.astroId,
                          amountInRupees: amountToCharge,
                          notifyContext: sheetCtx,
                        );
                        if (!paid) {
                          _d("⛔ payment not done → abort createSession");
                          return;
                        }

                        // 2) Create session
                        _d("🟡 createSession()");
                        await FastAPIServices().loadFromStorage();
                        final myUserIdFromStorage = FastAPIServices().userId;
                        _d("🔑 storage userId=$myUserIdFromStorage");

                        final dynamic raw = await FastAPIServices().createSession(
                          astrologerId: astrologer.astroId,
                          sessionType: mappedSessionType,
                        );
                        _d("📩 createSession raw=$raw");

                        Map<String, dynamic>? session;
                        if (raw is Map<String, dynamic>) {
                          session = raw;
                        } else if (raw is String) {
                          try {
                            final decoded = jsonDecode(raw);
                            if (decoded is Map<String, dynamic>) session = decoded;
                          } catch (e) {
                            _d("❌ decode string to map failed: $e");
                          }
                        } else if (raw == null) {
                          _d("❌ createSession returned null");
                        } else {
                          _d("⚠️ unexpected createSession type: ${raw.runtimeType}");
                        }

                        if (session == null) {
                          _d("❌ session==null. show snack & stop");
                          ScaffoldMessenger.of(sheetCtx).showSnackBar(const SnackBar(content: Text("Failed to create session. Please try again.")));
                          return;
                        }

                        // Normalize fields
                        final Map<String, dynamic> s = Map<String, dynamic>.from(session);
                        final String roomId = (s["room_id"] ?? "").toString();
                        _d("🔎 session.room_id=$roomId");

                        // user field
                        final dynamic userField = s["user"];
                        String userUid = '';
                        if (userField is Map) {
                          final m = Map<String, dynamic>.from(userField);
                          userUid = (m['id'] ?? m['user_id'] ?? m['uid'] ?? m['uuid'] ?? '').toString();
                        } else if (userField is String) {
                          userUid = userField;
                        }
                        if (userUid.isEmpty) {
                          userUid = (s["user_id"] ?? myUserIdFromStorage ?? '').toString();
                        }
                        _d("🔎 session.userUid=$userUid");

                        // astrologer field
                        String astrologerUid = '';
                        final dynamic astroField = s["astrologer"];
                        if (astroField is Map) {
                          final m = Map<String, dynamic>.from(astroField);
                          astrologerUid = (m['id'] ?? m['astro_id'] ?? m['uid'] ?? m['uuid'] ?? '').toString();
                        }
                        if (astrologerUid.isEmpty) {
                          astrologerUid = (s["astrologer_id"] ?? astrologer.astroId).toString();
                        }
                        _d("🔎 session.astrologerUid=$astrologerUid");

                        final String apiType = (s["session_type"] ?? "").toString();
                        _d("🔎 session.session_type=$apiType");

                        final missing = <String>[];
                        if (roomId.isEmpty) missing.add('roomId');
                        if (userUid.isEmpty) missing.add('userUid');
                        if (astrologerUid.isEmpty) missing.add('astrologerUid');
                        if (missing.isNotEmpty) {
                          _d("⛔ missing: ${missing.join(', ')}");
                          ScaffoldMessenger.of(sheetCtx).showSnackBar(
                            SnackBar(content: Text("Couldn't get session details (${missing.join(', ')}). Please try again.")),
                          );
                          return;
                        }

                        // Save debug vars
                        setSB(() {
                          _lastRoomId = roomId;
                          _lastAstrologerUid = astrologerUid;
                          _lastMyUserId = userUid;
                        });
                        _d("💾 saved debug: roomId=$_lastRoomId, astro=$_lastAstrologerUid, me=$_lastMyUserId");

                        // close sheet then navigate
                        if (Navigator.of(sheetCtx).canPop()) {
                          Navigator.of(sheetCtx).pop();
                        }
                        if (!mounted) return;

                        _showRequestSentDialog(
                          callType,
                          onOk: () {
                            final type = apiType.toLowerCase();
                            _d("➡️ navigate type=$type");
                            if (type == 'chat') {
                              Navigator.of(pageContext, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) => CustomerChatPage(
                                    astrologerUid: astrologerUid,
                                    myUserId: userUid,
                                    roomId: roomId,
                                    astrologerName: astrologer.name,
                                  ),
                                ),
                              );
                            } else if (type == 'video_call') {
                              Navigator.of(pageContext, rootNavigator: true).push(
                                MaterialPageRoute(builder: (_) => CustomerVideoCallPage(astroId: astrologerUid)),
                              );
                            } else if (type == 'audio_call') {
                              Navigator.of(pageContext, rootNavigator: true).push(
                                MaterialPageRoute(builder: (_) => AudioCallPage(otherUserId: astrologerUid)),
                              );
                            } else {
                              _d("⚠️ unknown session_type=$type, fallback chat");
                              Navigator.of(pageContext, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (_) => CustomerChatPage(
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
                        _d("💥 Exception in SEND_REQUEST: $e\n$st");
                        if (mounted) {
                          ScaffoldMessenger.of(sheetCtx).showSnackBar(SnackBar(content: Text("Something went wrong: $e")));
                        }
                      } finally {
                        if (mounted) setSB(() => _isProcessing = false);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ---------- Helpers / misc ----------

  String _priceLabel(double value, String suffix) {
    if (value <= 0) return 'Not available';
    return '₹ ${value.toStringAsFixed(0)}$suffix';
  }

  String _rateOrNA(double value, {String suffix = ''}) {
    if (value <= 0) return 'Not available';
    return '₹ ${value.toStringAsFixed(0)} $suffix'.trim();
  }

  Widget _buildInfoCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: appColor, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87))]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text('$label:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700))),
          Expanded(flex: 3, child: Text(value.isNotEmpty ? value : 'Not specified', style: TextStyle(fontSize: 14, color: Colors.grey.shade800, fontWeight: FontWeight.w400))),
        ],
      ),
    );
  }

  // States

  Widget _buildLoadingShimmer() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
              const SizedBox(height: 20),
              Container(width: 150, height: 24, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              Container(width: 200, height: 16, color: Colors.grey.shade300),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text("Unable to load profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _d("🔁 Try Again tapped → refetch astrologer");
                setState(() => astrologerFuture = FastAPIServices().fetchAstrologerDetail(widget.astroId));
              },
              style: ElevatedButton.styleFrom(backgroundColor: appColor),
              child: const Text("Try Again", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text("No astrologer found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          Text("The requested astrologer profile is not available", style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  // Utilities

  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    if (url.toLowerCase().contains('null')) return false;
    if (url.startsWith('file://')) return url.length > 7;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return !url.contains('/astro/null') && !url.contains('undefined') && !url.contains('placeholder');
    }
    return url.isNotEmpty;
  }

  String _getCompleteImageUrl(String imageUrl) {
    if (imageUrl.startsWith('file://')) {
      final String fileName = imageUrl.split('/').last;
      return 'https://fastapi.jyotishionline.com/static/uploads/$fileName';
    }
    if (imageUrl.startsWith('http')) return imageUrl;
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      return 'https://fastapi.jyotishionline.com${imageUrl.startsWith('/') ? imageUrl : '/$imageUrl'}';
    }
    return imageUrl;
  }

  void _showRequestSentDialog(String requestType, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text("Request Sent!")]),
        content: Text("Your $requestType request has been sent successfully. You will be notified when the astrologer accepts your request."),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (onOk != null) onOk();
            },
            style: ElevatedButton.styleFrom(backgroundColor: appColor),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    String? selectedReason;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text("Report Astrologer"),
            content: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Please select the reason for reporting:"),
                const SizedBox(height: 16),
                ...['Inappropriate behavior', 'Fake profile', 'Poor service', 'Other'].map(
                      (reason) => RadioListTile<String>(
                    title: Text(reason),
                    value: reason,
                    groupValue: selectedReason,
                    onChanged: (value) => setState(() => selectedReason = value),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  if (selectedReason == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a reason before submitting."), backgroundColor: Colors.orange));
                    return;
                  }
                  Navigator.pop(context);
                  try {
                    final astrologer = await astrologerFuture;
                    final apiService = FastAPIServices();
                    final response = await apiService.reportAstrologer(astrologerId: astrologer.astroId, reason: selectedReason!);
                    if (response != null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Astrologer reported successfully."), backgroundColor: Colors.green));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to report astrologer."), backgroundColor: Colors.red));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                  }
                },
                child: const Text("Submit Report", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBlockDialog() {
    final apiService = FastAPIServices();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Block Astrologer"),
        content: const Text("Are you sure you want to block this astrologer? You will no longer be able to chat or call them."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final astrologer = await astrologerFuture;
                final response = await apiService.blockAstrologer(astrologerId: astrologer.astroId);
                if (response != null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Astrologer blocked successfully."), backgroundColor: Colors.green));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to block astrologer."), backgroundColor: Colors.red));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
              }
            },
            child: const Text("Block", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}