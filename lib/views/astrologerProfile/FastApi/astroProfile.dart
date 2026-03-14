import 'dart:async';
import 'dart:convert';
import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../fastApi/fastApiServices.dart';
import '../../../model/fastApiModel/astrologerProfileModel.dart';
import '../../../services/location_services.dart';
import '../../../theme/appTheme.dart';
import '../../audioCall/newAudioCall.dart';
import '../../chat/newChatScreen.dart';
import '../../chat/video_call_page.dart';
import '../../wallet/walletRechargeScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


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

  void _showReviewBottomSheet(Astrologer astrologer) {
    int rating = 5;
    bool isSubmitting = false;

    final TextEditingController reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSB) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery
                    .of(ctx)
                    .viewInsets
                    .bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rate & Review",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// ⭐ STAR RATING
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () => setSB(() => rating = index + 1),
                      );
                    }),
                  ),

                  /// 📝 REVIEW TEXT
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    enabled: !isSubmitting,
                    decoration: const InputDecoration(
                      hintText: "Write your experience...",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 🚀 SUBMIT
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColor,
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                        if (reviewController.text
                            .trim()
                            .isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                              Text("Please write a review"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        setSB(() => isSubmitting = true);

                        final success =
                        await FastAPIServices().submitUserReview(
                          astrologerId: astrologer.astroId,
                          rating: rating,
                          review: reviewController.text.trim(),
                        );

                        setSB(() => isSubmitting = false);

                        if (success) {
                          Navigator.pop(ctx);
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? "Thank you for your review ⭐"
                                  : "Failed to submit review",
                            ),
                            backgroundColor:
                            success ? Colors.green : Colors.red,
                          ),
                        );
                      },
                      child: isSubmitting
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "Submit Review",
                        style: TextStyle(color: Colors.white),
                      ),
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


  Future<void> fetchTokenId() async {
    _d("🟡 fetchTokenId() → loadFromStorage()");
    final fastApi = FastAPIServices();
    await fastApi.loadFromStorage();
    _d("🟢 fetchTokenId() done. userId=${fastApi.userId}, hasToken=${fastApi
        .accessToken != null}");
  }

  // ⚠️ Disclaimer Popup
  Future<bool> _showDisclaimerDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Disclaimer",
            style: TextStyle(fontWeight: FontWeight.bold),
          ).tr(),
          content: SingleChildScrollView(
            child: Text(
              "The platform will not be held responsible for any financial transactions conducted outside the platform with the astrologer.",
              style: const TextStyle(fontSize: 14, height: 1.5),
            ).tr(),
          ),
          actions: [


            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel").tr(),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: appColor),
              child: const Text(
                  "I Accept", style: TextStyle(color: Colors.white)).tr(),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  // 🚀 Send Push Notification via FastAPI
  Future<void> _sendAstrologerNotification({
    required Astrologer astrologer,
    required String type,
    required String roomId,
    required String sessionType, // "audio_call" | "video_call" | "chat"
    required String customerId,
    required String astrologerId,
  }) async {
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
        "call_type": type, // "audio" / "video" / "chat"
        "session_type": sessionType, // "audio_call" / "video_call" / "chat"
        "room_id": roomId,
        "customer_id": customerId,
        "astrologer_id": astrologerId,
        "timestamp": DateTime.now().toIso8601String(),
      };

      _d("📡 Sending FCM to ${astrologer.name} (${astrologer
          .astroId}) with payload → $payload");

      final res = await api.sendNotificationToAstrologer(
        astrologerId: astrologer.astroId,
        title: title,
        body: body,
        screen: screen,
        data: payload,
      );

      if (res["success"] == true) {
        _d("✅ Notification sent successfully to ${astrologer.name}");
      } else {
        _d("⚠️ Failed to send notification: ${res['error']}");
      }
    } catch (e, st) {
      _d("💥 Exception in _sendAstrologerNotification: $e\n$st");
    }
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

          /// ⭐ RATE & REVIEW
          IconButton(
            icon: const Icon(Icons.rate_review_outlined),
            tooltip: 'Rate & Review',
            onPressed: () async {
              final astrologer = await astrologerFuture;
              _showReviewBottomSheet(astrologer);
            },
          ),

          /// 🚨 REPORT
          IconButton(
            icon: Icon(Icons.report_problem_outlined,
                color: Colors.grey.shade600),
            onPressed: _showReportDialog,
            tooltip: 'Report Astrologer',
          ),

          /// ⛔ BLOCK
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
          _d(
              "📦 FutureBuilder state=${snapshot
                  .connectionState} hasErr=${snapshot
                  .hasError} hasData=${snapshot.hasData}");
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
          _d(
              "✅ astrologer loaded: id=${astrologer.astroId}, name=${astrologer
                  .name}");
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


        ],
      ),
    );
  }

  Widget _buildHeaderSection(Astrologer astrologer) {
    final imageUrl = (astrologer.profileImage ?? '').trim();
    final hasValidImage = _isValidImageUrl(imageUrl);
    final completeImageUrl =
    hasValidImage ? _getCompleteImageUrl(imageUrl) : '';
    _d("🖼 header: hasValidImage=$hasValidImage url=$completeImageUrl");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appColor.withOpacity(0.1),
            appColor.withOpacity(0.05),
            Colors.white
          ],
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
                  gradient: LinearGradient(
                      colors: [appColor, appColor.withOpacity(0.7)]),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage:
                  hasValidImage ? NetworkImage(completeImageUrl) : null,
                  child: !hasValidImage
                      ? Icon(Icons.person,
                      size: 60, color: Colors.grey.shade400)
                      : null,
                ),
              ),
              // Container(
              //   padding: const EdgeInsets.all(8),
              //   decoration: BoxDecoration(
              //       color: Colors.green,
              //       shape: BoxShape.circle,
              //       border: Border.all(color: Colors.white, width: 2)),
              //   child: const Icon(Icons.circle,
              //       color: Colors.white, size: 14),
              // ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    astrologer.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                astrologer.isVerified
                    ? Icons.verified
                    : Icons.verified_outlined,
                color: astrologer.isVerified ? appColor : Colors.grey,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            astrologer.primarySkill ?? "Astrology Expert",
            style: TextStyle(
                fontSize: 16,
                color: appColor,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_outline,
                  size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                  "${astrologer.experienceInYears ?? 0} Years Exp",
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(width: 16),
              Icon(Icons.location_on_outlined,
                  size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                  astrologer.currentCity ?? "Not specified",
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey.shade600)),
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
          if (astrologer.loginBio != null &&
              astrologer.loginBio!.isNotEmpty)
            _buildInfoCard(
              title: 'About Me',
              icon: Icons.info_outline,
              child: Text(
                astrologer.loginBio!,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5),
              ),
            ),
          if (astrologer.loginBio != null &&
              astrologer.loginBio!.isNotEmpty)
            const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Professional Background',
            icon: Icons.work_outline,
            child: Column(
              children: [
                _buildProfileRow('Primary Expertise',
                    astrologer.primarySkill ?? 'Not specified'),
                _buildProfileRow('Experience',
                    '${astrologer.experienceInYears ?? 0} Years'),
                _buildProfileRow('Highest Qualification',
                    astrologer.highestQualification ?? 'Not specified'),
                _buildProfileRow('Astrology Education',
                    astrologer.learnAstrology ?? 'Not specified'),
                _buildProfileRow(
                    'Currently Working',
                    astrologer.currentlyworkingfulltimejob ??
                        'Not specified'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Personal Information',
            icon: Icons.person_outline,
            child: Column(
              children: [
                _buildProfileRow('Languages Known',
                    astrologer.languageKnown ?? 'Not specified'),
                _buildProfileRow(
                    'Location',
                    '${astrologer.currentCity ?? 'Not specified'}${astrologer
                        .country != null ? ', ${astrologer.country}' : ''}'),
                _buildProfileRow(
                    'Contact Verified',
                    astrologer.isContactVerified
                        ? '✅ Verified'
                        : '❌ Not Verified'),
                _buildProfileRow(
                    'Profile Status',
                    astrologer.isVerified
                        ? '✅ Verified Astrologer'
                        : '❌ Not Verified'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Consultation Rates',
            icon: Icons.attach_money_outlined,
            child: Column(
              children: [
                _buildProfileRow(
                    'Audio Call',
                    _rateOrNA(
                        astrologer,
                        astrologer.audioCallCharge,
                        astrologer.audioCallChargeUSD,
                        suffix: '/10 min')),
                _buildProfileRow(
                    'Video Call',
                    _rateOrNA(
                        astrologer,
                        astrologer.videoCallCharge,
                        astrologer.videoCallChargeUSD,
                        suffix: '/10 min')),
                _buildProfileRow(
                    'Chat',
                    _rateOrNA(
                        astrologer,
                        astrologer.chatCharge,
                        astrologer.chatChargeUSD,
                        suffix: '/message')),
                if (astrologer.monthlyEarning != null &&
                    astrologer.monthlyEarning!.isNotEmpty)
                  _buildProfileRow('Monthly Earnings',
                      '₹ ${astrologer.monthlyEarning}'),
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

    _d(
        "🎛 options: audio=$hasAudio(${astrologer
            .audioCallCharge}) video=$hasVideo(${astrologer
            .videoCallCharge}) chat=$hasChat(${astrologer.chatCharge})");

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
              price: _priceLabel(
                  astrologer,
                  astrologer.audioCallCharge,
                  astrologer.audioCallChargeUSD,
                  '/10 min'),
              features: [
                'Best for quick guidance',
                'Uninterrupted connection'
              ],
              disabled: !hasAudio,
              onTap: () async {
                _showCallRequestDialog(astrologer, 'Audio');
              },
            ),
            const SizedBox(height: 16),
            _buildConsultationOption(
              icon: Icons.videocam,
              title: 'Video Call',
              subtitle: 'Face-to-face consultation',
              price: _priceLabel(
                  astrologer,
                  astrologer.videoCallCharge,
                  astrologer.videoCallChargeUSD,
                  '/10 min'),
              features: [
                'Better understanding',
                'Screen sharing'
              ],
              disabled: !hasVideo,
              onTap: () async {
                _showCallRequestDialog(astrologer, 'Video');
              },
            ),
            const SizedBox(height: 16),
            _buildConsultationOption(
              icon: Icons.chat,
              title: 'Chat',
              subtitle: 'Text-based consultation',
              price:
              _priceLabel(
                  astrologer,
                  astrologer.chatCharge,
                  astrologer.chatChargeUSD,
                  '/message'),
              features: [
                '24×7 availability',
                'Share images'
              ],
              disabled: !hasChat,
              onTap: () async {
                _showCallRequestDialog(astrologer, 'Chat');
              },
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
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: appColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: appColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: appColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: features
                    .map(
                      (f) =>
                      Chip(
                        label: Text(
                          f,
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade700),
                        ),
                        backgroundColor: Colors.grey.shade100,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                      ),
                )
                    .toList(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: appColor,
                      foregroundColor: Colors.white),
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
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFAB(
              icon: Icons.audiotrack,
              label: 'Audio Call',
              price: _priceLabel(
                  astrologer,
                  astrologer.audioCallCharge,
                  astrologer.audioCallChargeUSD,
                  '/10 min'),
              onPressed: hasAudio
                  ? () async {
                _showCallRequestDialog(astrologer, 'Audio');
              }
                  : null,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFAB(
              icon: Icons.videocam,
              label: 'Video Call',
              price: _priceLabel(astrologer,
                  astrologer.videoCallCharge,
                  astrologer.videoCallChargeUSD,
                  '/10 min'),
              onPressed: hasVideo
                  ? () async {
                _showCallRequestDialog(astrologer, 'Video');
              }
                  : null,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFAB(
              icon: Icons.chat,
              label: 'Chat',
              price:
              _priceLabel(
                  astrologer,
                  astrologer.chatCharge,
                  astrologer.chatChargeUSD,
                  '/message'),
              onPressed: hasChat
                  ? () async {
                _showCallRequestDialog(astrologer, 'Chat');
              }
                  : null,
              color: Colors.orange,
            ),
          ),
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
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  price,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- (OLD PAYMENT) → REMOVED DEDUCTION ----------
  // No more _payIfEnoughBalance or sendMoney here.
  // Deduction should happen ONLY on session end in backend.

  // Optional: simple balance check (does NOT deduct)
  Future<bool> _hasSufficientBalanceForSession({
    required double requiredAmount,
    required BuildContext notifyContext,
  }) async {
    try {
      // Get user's current balance - replace with your actual balance fetching logic
      final userBalance = await _getUserBalance(); // You need to implement this

      if (userBalance < requiredAmount) {
        // Close any open bottom sheets first
        if (Navigator.canPop(notifyContext)) {
          Navigator.pop(notifyContext);
        }

        // Show dialog using the root context
        if (notifyContext.mounted) {
          await showDialog(
            context: notifyContext,
            barrierDismissible: false,
            builder: (dialogContext) =>
                AlertDialog(
                  title: const Text('Insufficient Balance'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocationService.isIndianUser
                            ? 'You need ${currencySymbol()}${requiredAmount
                            .toStringAsFixed(0)} to start this consultation.'
                            : 'You need \$${requiredAmount.toStringAsFixed(
                            0)} to start this consultation.',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        LocationService.isIndianUser
                            ? 'Your current balance: ₹${userBalance
                            .toStringAsFixed(0)}'
                            : 'Your current balance: \$${userBalance
                            .toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('OK'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RechargeWalletScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColor,
                      ),
                      child: const Text('Add Funds'),
                    ),
                  ],
                ),
          );
        }
        return false;
      }

      return true;
    } catch (e) {
      _d("Error checking balance: $e");

      // Show error dialog
      if (notifyContext.mounted) {
        ScaffoldMessenger.of(notifyContext).showSnackBar(
          SnackBar(
            content: Text("Error checking balance: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  // ---------- Bottom sheet / main flow ----------

  void _showCallRequestDialog(Astrologer astrologer, String callType) async {
    final BuildContext pageContext = context;

    // Show disclaimer first
    final accepted = await _showDisclaimerDialog(context);
    if (!accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "You must accept the disclaimer before proceeding."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final isAudio = callType.toLowerCase().startsWith('audio');
    final isVideo = callType.toLowerCase().startsWith('video');
    final isChat = callType.toLowerCase().startsWith('chat');

    double rate;

    if (LocationService.isIndianUser) {
      rate = isAudio
          ? astrologer.audioCallCharge
          : isVideo
          ? astrologer.videoCallCharge
          : astrologer.chatCharge;
    } else {
      rate = isAudio
          ? (astrologer.audioCallChargeUSD ?? 0)
          : isVideo
          ? (astrologer.videoCallChargeUSD ?? 0)
          : (astrologer.chatChargeUSD ?? 0);
    }

    // For audio/video we display 10-minute block price, but DO NOT deduct here.
    final bool pricedPerTenMinBlock = isAudio || isVideo;

    _d(
        "🟡 openSheet type=$callType (per10min=$pricedPerTenMinBlock) rate=$rate");

    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetCtx, setSB) {
            return Container(
              padding: const EdgeInsets.all(20),
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
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'with ${astrologer.name}',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  // Info card — shows estimated/minimum charge ONLY, no deduction.
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: appColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: appColor.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pricedPerTenMinBlock
                              ? 'Estimated Charge (10 min)'
                              : 'Estimated Charge',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '${currencySymbol()} ${rate.toStringAsFixed(0)}',
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
                      ),
                      child: _isProcessing
                          ? const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 2),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                          : const Text(
                        "Send Request",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _isProcessing
                          ? null
                          : () async {
                        if (mounted) {
                          setState(() {
                            _isProcessing = true;
                          });
                        }


                        try {
                          _d("🟡 [SEND_REQUEST] tap → type=$callType astroId=${astrologer.astroId}");

                          /// -------------------------------
                          /// 1️⃣ Map call type
                          /// -------------------------------
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

                          /// -------------------------------
                          /// 2️⃣ Balance check (NO deduction)
                          /// -------------------------------
                          final double requiredAmount = rate;

                          final hasBalance = await _hasSufficientBalanceForSession(
                            requiredAmount: requiredAmount,
                            notifyContext: pageContext,
                          );

                          if (!hasBalance) {
                            _d("⛔ insufficient balance → stop flow");

                            if (mounted) {
                              setState(() {
                                _isProcessing = false;
                              });
                            }

                            if (Navigator.canPop(pageContext)) {
                              Navigator.pop(pageContext);
                            }

                            return;
                          }

                          /// -------------------------------
                          /// 3️⃣ Create Session
                          /// -------------------------------
                          await FastAPIServices().loadFromStorage();

                          final myUserIdFromStorage = FastAPIServices().userId;

                          final dynamic raw = await FastAPIServices().createSession(
                            astrologerId: astrologer.astroId,
                            sessionType: mappedSessionType,
                          );

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
                              _d("❌ decode error: $e");
                            }
                          }

                          if (session == null) {
                            ScaffoldMessenger.of(pageContext).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to create session."),
                              ),
                            );
                            return;
                          }

                          final Map<String, dynamic> s = Map<String, dynamic>.from(session);

                          final String roomId = (s["room_id"] ?? "").toString();

                          /// -------------------------------
                          /// 4️⃣ Extract userId
                          /// -------------------------------
                          String userUid = '';

                          final dynamic userField = s["user"];

                          if (userField is Map) {
                            userUid = (userField["id"] ??
                                userField["user_id"] ??
                                userField["uid"] ??
                                '')
                                .toString();
                          } else if (userField is String) {
                            userUid = userField;
                          }

                          if (userUid.isEmpty) {
                            userUid = (s["user_id"] ?? myUserIdFromStorage ?? '').toString();
                          }

                          /// -------------------------------
                          /// 5️⃣ Extract astrologerId
                          /// -------------------------------
                          String astrologerUid = '';

                          final dynamic astroField = s["astrologer"];

                          if (astroField is Map) {
                            astrologerUid = (astroField["id"] ??
                                astroField["astro_id"] ??
                                '')
                                .toString();
                          }

                          if (astrologerUid.isEmpty) {
                            astrologerUid =
                                (s["astrologer_id"] ?? astrologer.astroId).toString();
                          }

                          if (roomId.isEmpty || userUid.isEmpty || astrologerUid.isEmpty) {
                            ScaffoldMessenger.of(pageContext).showSnackBar(
                              const SnackBar(
                                content: Text("Session data missing."),
                              ),
                            );
                            return;
                          }

                          /// -------------------------------
                          /// 6️⃣ Save debug vars
                          /// -------------------------------
                          _lastRoomId = roomId;
                          _lastAstrologerUid = astrologerUid;
                          _lastMyUserId = userUid;

                          /// -------------------------------
                          /// 7️⃣ Send Notification
                          /// -------------------------------
                          await _sendAstrologerNotification(
                            astrologer: astrologer,
                            type: callType,
                            roomId: roomId,
                            sessionType: mappedSessionType,
                            customerId: userUid,
                            astrologerId: astrologerUid,
                          );

                          /// -------------------------------
                          /// 8️⃣ Close Bottom Sheet safely
                          /// -------------------------------
                          if (Navigator.canPop(pageContext)) {
                            Navigator.pop(pageContext);
                          }

                          if (!mounted) return;

                          /// -------------------------------
                          /// 9️⃣ Show waiting dialog
                          /// -------------------------------
                          _showRequestSentDialog(callType);

                        } catch (e, st) {
                          _d("💥 Exception in SEND_REQUEST: $e\n$st");

                          if (mounted) {
                            ScaffoldMessenger.of(pageContext).showSnackBar(
                              SnackBar(
                                content: Text("Something went wrong: $e"),
                              ),
                            );
                          }
                        }
                        finally {
                          if (!mounted) return;

                          setState(() {
                            _isProcessing = false;
                          });
                        }
                      },
                    ),
                  ),

                  SizedBox(height: 70,)
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------- Helpers / misc ----------

  String _priceLabel(Astrologer astrologer, double inr, double? usd,
      String suffix) {
    if (inr <= 0) return 'Not available';

    if (LocationService.isIndianUser) {
      return '₹ ${inr.toStringAsFixed(0)}$suffix';
    } else {
      return '\$ ${(usd ?? 0).toStringAsFixed(0)}$suffix';
    }
  }

  String _rateOrNA(Astrologer astrologer, double inr, double? usd,
      {String suffix = ''}) {
    if (inr <= 0) return 'Not available';

    if (LocationService.isIndianUser) {
      return '₹ ${inr.toStringAsFixed(0)} $suffix';
    } else {
      return '\$ ${(usd ?? 0).toStringAsFixed(0)} $suffix';
    }
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: appColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
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
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isNotEmpty ? value : 'Not specified',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
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
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 150,
                height: 24,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 8),
              Container(
                width: 200,
                height: 16,
                color: Colors.grey.shade300,
              ),
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
            Icon(Icons.error_outline,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              "Unable to load profile",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _d(
                    "🔁 Try Again tapped → refetch astrologer");
                setState(() {
                  astrologerFuture = FastAPIServices()
                      .fetchAstrologerDetail(widget.astroId);
                });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: appColor),
              child: const Text(
                "Try Again",
                style: TextStyle(color: Colors.white),
              ),
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
          Icon(Icons.person_off_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "No astrologer found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "The requested astrologer profile is not available",
            style: TextStyle(color: Colors.grey.shade600),
          ),
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
      return !url.contains('/astro/null') &&
          !url.contains('undefined') &&
          !url.contains('placeholder');
    }
    return url.isNotEmpty;
  }

  String _getCompleteImageUrl(String imageUrl) {
    if (imageUrl.startsWith('file://')) {
      final String fileName = imageUrl
          .split('/')
          .last;
      return 'https://fastapi.jyotishionline.com/static/uploads/$fileName';
    }
    if (imageUrl.startsWith('http')) return imageUrl;
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      return 'https://fastapi.jyotishionline.com${imageUrl.startsWith('/')
          ? imageUrl
          : '/$imageUrl'}';
    }
    return imageUrl;
  }

  void _showRequestSentDialog(String requestType) {
    int remainingSeconds = 60;
    Timer? timer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Start timer only once
            if (timer == null) {
              timer = Timer.periodic(const Duration(seconds: 1), (t) {
                if (remainingSeconds == 0) {
                  t.cancel();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (Navigator.canPop(dialogContext)) {
                      Navigator.of(dialogContext).pop();
                    }
                  });
                } else {
                  setState(() {
                    remainingSeconds--;
                  });
                }
              });
            }

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text("Request Sent!"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Your $requestType request has been sent.\n\n"
                    // "Please stay on this page — the astrologer will accept your request "
                    // "within 1 minute if they are available.\n\n"
                    // "Once accepted, the session will automatically start.",
                  ),

                  Text(
                      "Please stay on this page — the astrologer will accept your request within 1 minute if they are available.")
                      .tr(),

                  Text("Once accepted, the session will automatically start.")
                      .tr(),

                  Text(
                      'If he didnt repond now , you will be notified once they respoond')
                      .tr(),


                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      "Time remaining: $remainingSeconds sec",
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColor,
                  ),
                  onPressed: () {
                    timer?.cancel();
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                      "OK", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      timer?.cancel(); // extra safety
    });
  }


  void _showReportDialog() {
    String? selectedReason;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Report Astrologer"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Please select the reason for reporting:",
                  ),
                  const SizedBox(height: 16),
                  ...[
                    'Inappropriate behavior',
                    'Fake profile',
                    'Poor service',
                    'Other'
                  ].map(
                        (reason) {
                      return RadioListTile<String>(
                        title: Text(reason),
                        value: reason,
                        groupValue: selectedReason,
                        onChanged: (value) {
                          setState(() {
                            selectedReason = value;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red),
                  onPressed: () async {
                    if (selectedReason == null) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please select a reason before submitting.",
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    try {
                      final astrologer =
                      await astrologerFuture;
                      final apiService = FastAPIServices();
                      final response =
                      await apiService.reportAstrologer(
                        astrologerId: astrologer.astroId,
                        reason: selectedReason!,
                      );
                      if (response != null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Astrologer reported successfully."),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Failed to report astrologer."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text("Error: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Submit Report",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBlockDialog() {
    final apiService = FastAPIServices();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Block Astrologer"),
          content: const Text(
            "Are you sure you want to block this astrologer? You will no longer be able to chat or call them.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final astrologer = await astrologerFuture;
                  final response =
                  await apiService.blockAstrologer(
                      astrologerId: astrologer.astroId);
                  if (response != null) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Astrologer blocked successfully."),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Failed to block astrologer."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                "Block",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<double> _getUserBalance() async {
    try {
      _d("💰 Fetching user wallet balance...");

      /// load token + userId
      await FastAPIServices().loadFromStorage();

      /// call wallet API
      final wallet = await FastAPIServices().fetchCurrentWallet();

      if (wallet == null) {
        _d("⚠ Wallet API returned null");
        return 0.0;
      }

      double balanceInr = wallet.amount.toDouble();

      _d("💰 Wallet balance (INR): $balanceInr");

      /// 🌍 If user is international convert INR → USD
      if (!LocationService.isIndianUser) {
        try {
          final response = await http.get(
            Uri.parse("https://open.er-api.com/v6/latest/INR"),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            double usdRate = data["rates"]["USD"];

            double balanceUsd = balanceInr * usdRate;

            _d("💱 Converted balance: $balanceInr INR → $balanceUsd USD");

            return balanceUsd;
          }
        } catch (e) {
          _d("⚠ Currency API failed, using fallback rate");

          /// fallback conversion
          return balanceInr * 0.012;
        }
      }

      /// 🇮🇳 Indian user
      return balanceInr;
    } catch (e) {
      _d("❌ Error fetching user balance: $e");
      return 0.0;
    }
  }

  String currencySymbol() {
    return LocationService.isIndianUser ? "₹" : "\$";
  }
}