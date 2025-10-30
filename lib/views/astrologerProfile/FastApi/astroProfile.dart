import 'package:flutter/material.dart';
import '../../../fastApi/fastApiServices.dart';
import '../../../fastApi/fastApiendpoints.dart';
import '../../../model/fastApiModel/astrologerProfileModel.dart';
import '../../../theme/appTheme.dart';
import '../../../utils/global.dart';
import '../../chat/newChatScreen.dart';

class AstrologerDetailPage extends StatefulWidget {
  final String astroId;

  const AstrologerDetailPage({super.key, required this.astroId});

  @override
  State<AstrologerDetailPage> createState() => _AstrologerDetailPageState();
}

class _AstrologerDetailPageState extends State<AstrologerDetailPage> {
  late Future<Astrologer> astrologerFuture;
  int _selectedDuration = 10;

  @override
  void initState() {
    super.initState();
    astrologerFuture = FastAPIServices().fetchAstrologerDetail(widget.astroId);
    final fastApi = FastAPIServices();
    fetchTokenId();
    // make sure data is loaded
  }

  fetchTokenId() async{
    final fastApi = FastAPIServices();
    await fastApi.loadFromStorage(); // make sure data is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Astrologer Profile",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
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
          // Report Astrologer Button
          IconButton(
            icon: Icon(
              Icons.report_problem_outlined,
              color: Colors.grey.shade600,
            ),
            onPressed: _showReportDialog,
            tooltip: 'Report Astrologer',
          ),

          // Block Astrologer Button
          IconButton(
            icon: Icon(
              Icons.block,
              color: Colors.red.shade400,
            ),
            onPressed: _showBlockDialog,
            tooltip: 'Block Astrologer',
          ),
        ],

      ),
      body: FutureBuilder<Astrologer>(
        future: astrologerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingShimmer();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData) {
            return _buildEmptyState();
          }

          final astrologer = snapshot.data!;
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

  Widget _buildAstrologerUI(Astrologer astrologer) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Header Section
          _buildHeaderSection(astrologer),

          // Profile Details
          _buildProfileDetails(astrologer),

          // Consultation Options
          _buildConsultationOptions(astrologer),

          const SizedBox(height: 100), // Space for FABs
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Astrologer astrologer) {
    // Calculate image URL inside this method
    final imageUrl = (astrologer.profileImage ?? '').trim();
    final hasValidImage = _isValidImageUrl(imageUrl);
    final completeImageUrl = hasValidImage
        ? _getCompleteImageUrl(imageUrl)
        : '';

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
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Avatar with Badge
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [appColor, appColor.withOpacity(0.7)],
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: hasValidImage
                      ? NetworkImage(completeImageUrl)
                      : null,
                  child: !hasValidImage
                      ? Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey.shade400,
                  )
                      : null,
                ),
              ),
              // Online Status Badge
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.circle,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Name with Verification Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                astrologer.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                maxLines: 1, // only one line
                overflow: TextOverflow.ellipsis, // show ...
                softWrap: false, // prevents wrapping to the next line
              ),

              const SizedBox(width: 8),
              Icon(
                astrologer.isVerified ? Icons.verified : Icons
                    .verified_outlined,
                color: astrologer.isVerified ? appColor : Colors.grey,
                size: 22,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Primary Skill
          Text(
            astrologer.primarySkill ?? "Astrology Expert",
            style: TextStyle(
              fontSize: 16,
              color: appColor,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          // Experience and Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_outline, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                "${astrologer.experienceInYears ?? 0} Years Exp",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on_outlined, size: 16,
                  color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                astrologer.currentCity ?? "Not specified",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Rating and Consultations
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(12),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.grey.shade200,
          //         blurRadius: 8,
          //         offset: const Offset(0, 2),
          //       ),
          //     ],
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       _buildStatItem(Icons.star, "4.8", "Rating"),
          //       const SizedBox(width: 24),
          //       Container(
          //         width: 1,
          //         height: 30,
          //         color: Colors.grey.shade300,
          //       ),
          //       const SizedBox(width: 24),
          //       _buildStatItem(Icons.people, "${astrologer.totalOrder ?? 0}", "Consultations"),
          //       const SizedBox(width: 24),
          //       Container(
          //         width: 1,
          //         height: 30,
          //         color: Colors.grey.shade300,
          //       ),
          //       const SizedBox(width: 24),
          //       _buildStatItem(Icons.thumb_up, "98%", "Satisfaction"),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: appColor, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(Astrologer astrologer) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About Me Section
          if (astrologer.loginBio != null && astrologer.loginBio!.isNotEmpty)
            _buildInfoCard(
              title: 'About Me',
              icon: Icons.info_outline,
              child: Text(
                astrologer.loginBio!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),

          if (astrologer.loginBio != null && astrologer.loginBio!.isNotEmpty)
            const SizedBox(height: 16),

          // Professional Details
          _buildInfoCard(
            title: 'Professional Background',
            icon: Icons.work_outline,
            child: Column(
              children: [
                _buildProfileRow('Primary Expertise',
                    astrologer.primarySkill ?? 'Not specified'),
                _buildProfileRow(
                    'Experience', '${astrologer.experienceInYears ?? 0} Years'),
                _buildProfileRow('Highest Qualification',
                    astrologer.highestQualification ?? 'Not specified'),
                _buildProfileRow('Astrology Education',
                    astrologer.learnAstrology ?? 'Not specified'),
                _buildProfileRow('Currently Working',
                    astrologer.currentlyworkingfulltimejob ?? 'Not specified'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Personal Details
          _buildInfoCard(
            title: 'Personal Information',
            icon: Icons.person_outline,
            child: Column(
              children: [
                _buildProfileRow('Languages Known',
                    astrologer.languageKnown ?? 'Not specified'),
                _buildProfileRow('Location',
                    '${astrologer.currentCity ?? 'Not specified'}${astrologer
                        .country != null ? ', ${astrologer.country}' : ''}'),
                _buildProfileRow('Contact Verified',
                    astrologer.isContactVerified
                        ? '✅ Verified'
                        : '❌ Not Verified'),
                _buildProfileRow('Profile Status', astrologer.isVerified
                    ? '✅ Verified Astrologer'
                    : '❌ Not Verified'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Consultation Rates
          _buildInfoCard(
            title: 'Consultation Rates',
            icon: Icons.attach_money_outlined,
            child: Column(
              children: [
                _buildProfileRow(
                    'Call Rate', '₹ ${astrologer.charge} / minute'),
                _buildProfileRow('Audio Call',
                    '₹ ${(astrologer.charge * 0.8).toStringAsFixed(
                        0)} / minute (20% off)'),
                _buildProfileRow('Chat',
                    '₹ ${(astrologer.charge * 0.5).toStringAsFixed(
                        0)} / message (50% off)'),
                if (astrologer.monthlyEarning != null &&
                    astrologer.monthlyEarning!.isNotEmpty)
                  _buildProfileRow(
                      'Monthly Earnings', '₹ ${astrologer.monthlyEarning}'),
              ],
            ),
          ),

          // Social Links
          if (_hasSocialLinks(astrologer)) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Connect With Me',
              icon: Icons.link_outlined,
              child: _buildSocialLinks(astrologer),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConsultationOptions(Astrologer astrologer) {
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
              price: '₹ ${(astrologer.charge * 0.8).toStringAsFixed(0)}/min',
              features: [
                '20% cheaper than video',
                'Record call option',
                'Uninterrupted connection'
              ],
            ),
            const SizedBox(height: 16),
            _buildConsultationOption(
              icon: Icons.videocam,
              title: 'Video Call',
              subtitle: 'Face-to-face consultation',
              price: '₹ ${astrologer.charge}/min',
              features: [
                'Better understanding',
                'Screen sharing',
                'Record session'
              ],
            ),
            const SizedBox(height: 16),
            _buildConsultationOption(
              icon: Icons.chat,
              title: 'Chat',
              subtitle: 'Text-based consultation',
              price: '₹ ${(astrologer.charge * 0.5).toStringAsFixed(
                  0)}/message',
              features: [
                '50% off call rates',
                '24-hour access',
                'Share images'
              ],
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
  }) {
    return Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: appColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: features.map((feature) {
              return Chip(
                label: Text(
                  feature,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                  ),
                ),
                backgroundColor: Colors.grey.shade100,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons(Astrologer astrologer) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFAB(
              icon: Icons.audiotrack,
              label: 'Audio Call',
              price: '₹ ${(astrologer.charge * 0.8).toStringAsFixed(0)}/min',
              onPressed: () => _showCallRequestDialog(astrologer, 'Audio'),
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFAB(
              icon: Icons.videocam,
              label: 'Video Call',
              price: '₹ ${astrologer.charge}/min',
              onPressed: () => _showCallRequestDialog(astrologer, 'Video'),
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFAB(
              icon: Icons.chat,
              label: 'Chat',
              price: '₹ ${(astrologer.charge * 0.5).toStringAsFixed(0)}/msg',
              onPressed: () =>  _showCallRequestDialog(astrologer, 'Chat'),
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
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
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
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCallRequestDialog(Astrologer astrologer, String callType) {
    const int defaultDuration = 10; // Fixed duration

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                '$callType Call Consultation',
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
                      'Total Amount (10 min)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '₹ ${(callType == 'Audio'
                          ? astrologer.charge * 0.8
                          : astrologer.charge) * defaultDuration}',
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
                  onPressed: () async {
                    print("🟡 [BUTTON] Send Request clicked");
                    print("➡️ Selected Call Type: $callType");
                    print("➡️ Astrologer ID: ${astrologer.astroId}");

                    // 🧠 Map callType to correct backend value
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
                        mappedSessionType = "chat";
                        break;
                      default:
                        mappedSessionType = "chat"; // fallback
                    }

                    print("✅ Mapped session_type for API: $mappedSessionType");

                    print("➡️ Current User ID: ${FastAPIServices().userId}");
                    print("🟠 [API CALL INITIATED]");

                    bool success = await FastAPIServices().createSession(
                      astrologerId: astrologer.astroId,
                      sessionType: mappedSessionType,
                    );

                    if (success) {
                      print("✅ [SUCCESS] Session created successfully.");
                      _showRequestSentDialog(callType);
                    } else {
                      print("❌ [FAILED] Session creation failed.");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(
                            "Failed to send request. Please try again.")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: appColor),
                  child: const Text(
                    "Send Request",
                    style: TextStyle(color: Colors.white),
                  ),
                ),


              ),
            ],
          ),
        );
      },
    );
  }


  // Keep existing helper methods...
  Widget _buildInfoCard(
      {required String title, required IconData icon, required Widget child}) {
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
            offset: const Offset(0, 2),
          ),
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

  Widget _buildSocialLinks(Astrologer astrologer) {
    final socialLinks = [
      if (astrologer.instaProfileLink != null &&
          astrologer.instaProfileLink!.isNotEmpty &&
          astrologer.instaProfileLink != 'string')
        _buildSocialLinkItem('Instagram', Icons.photo_camera_outlined,
            astrologer.instaProfileLink!),
      if (astrologer.facebookProfileLink != null &&
          astrologer.facebookProfileLink!.isNotEmpty &&
          astrologer.facebookProfileLink != 'string')
        _buildSocialLinkItem(
            'Facebook', Icons.facebook, astrologer.facebookProfileLink!),
      if (astrologer.linkedInProfileLink != null &&
          astrologer.linkedInProfileLink!.isNotEmpty &&
          astrologer.linkedInProfileLink != 'string')
        _buildSocialLinkItem(
            'LinkedIn', Icons.business_center, astrologer.linkedInProfileLink!),
      if (astrologer.youtubeChannelLink != null &&
          astrologer.youtubeChannelLink!.isNotEmpty &&
          astrologer.youtubeChannelLink != 'string')
        _buildSocialLinkItem(
            'YouTube', Icons.video_library, astrologer.youtubeChannelLink!),
      if (astrologer.websiteProfileLink != null &&
          astrologer.websiteProfileLink!.isNotEmpty &&
          astrologer.websiteProfileLink != 'string')
        _buildSocialLinkItem(
            'Website', Icons.language, astrologer.websiteProfileLink!),
    ];

    return Column(
      children: socialLinks,
    );
  }

  Widget _buildSocialLinkItem(String platform, IconData icon, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: appColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  url.length > 40 ? '${url.substring(0, 40)}...' : url,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.open_in_new, size: 18, color: appColor),
            onPressed: () => _launchUrl(url),
          ),
        ],
      ),
    );
  }

  bool _hasSocialLinks(Astrologer astrologer) {
    return (astrologer.instaProfileLink != null &&
        astrologer.instaProfileLink!.isNotEmpty &&
        astrologer.instaProfileLink != 'string') ||
        (astrologer.facebookProfileLink != null &&
            astrologer.facebookProfileLink!.isNotEmpty &&
            astrologer.facebookProfileLink != 'string') ||
        (astrologer.linkedInProfileLink != null &&
            astrologer.linkedInProfileLink!.isNotEmpty &&
            astrologer.linkedInProfileLink != 'string') ||
        (astrologer.youtubeChannelLink != null &&
            astrologer.youtubeChannelLink!.isNotEmpty &&
            astrologer.youtubeChannelLink != 'string') ||
        (astrologer.websiteProfileLink != null &&
            astrologer.websiteProfileLink!.isNotEmpty &&
            astrologer.websiteProfileLink != 'string');
  }

  void _launchUrl(String url) {
    print('Launching URL: $url');
  }

  void _sendCallRequest(Astrologer astrologer, String callType, int duration) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text("Send $callType Call Request"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("You are sending a $callType call request to ${astrologer
                    .name}"),
                const SizedBox(height: 8),
                Text("Duration: $duration minutes"),
                const SizedBox(height: 8),
                Text("Total Amount: ₹ ${(callType == 'Audio' ? astrologer
                    .charge * 0.8 : astrologer.charge) * duration}"),
                const SizedBox(height: 16),
                const Text(
                  "The astrologer will receive your request and can accept it to start the call.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showRequestSentDialog(callType);
                },
                style: ElevatedButton.styleFrom(backgroundColor: appColor),
                child: const Text(
                    "Send Request", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  void _sendChatRequest(Astrologer astrologer) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text("Send Chat Request"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("You are sending a chat request to ${astrologer.name}"),
                const SizedBox(height: 16),
                const Text(
                  "The astrologer will receive your request and can accept it to start the chat session.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showRequestSentDialog('chat');
                },
                style: ElevatedButton.styleFrom(backgroundColor: appColor),
                child: const Text(
                    "Send Request", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  void _showRequestSentDialog(String requestType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text("Request Sent!"),
              ],
            ),
            content: Text(
              "Your $requestType request has been sent successfully. "
                  "You will be notified when the astrologer accepts your request.",
            ),
            actions: [
              // TextButton(
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              //   child: const Text("View My Requests"),
              // ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close the dialog first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerChatPage(
                        // receiverId: widget.astroId,
                        // myUserId: FastAPIServices().userId ?? '',
                        // token: FastAPIServices().accessToken ?? '',
                        astrologerUid: "fea423d4-3f23-43a9-9ecb-a5cd4d0d5247",
                        myUserId:  'user_779b09b9560f490e92889c35f5ff8de5',
                        // token: FastAPIServices().accessToken ?? '',
                        roomId: 'room_7cbc2ffb81574c528e9d4fafd095cd2a',
                      )

                    ),
                  );
                  print('🧠 astroId: ${widget.astroId}');
                  print('🧠 userId: ${FastAPIServices().userId}');
                  print('🧠 accessToken: ${FastAPIServices().accessToken}');

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
          builder: (context, setState) =>
              AlertDialog(
                title: const Text("Report Astrologer"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Please select the reason for reporting:"),
                    const SizedBox(height: 16),
                    ...[
                      'Inappropriate behavior',
                      'Fake profile',
                      'Poor service',
                      'Other'
                    ]
                        .map(
                          (reason) =>
                          RadioListTile<String>(
                            title: Text(reason),
                            value: reason,
                            groupValue: selectedReason,
                            onChanged: (value) {
                              setState(() => selectedReason = value);
                            },
                          ),
                    )
                        .toList(),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Please select a reason before submitting."),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      Navigator.pop(context);

                      try {
                        // Get astrologer details from the future
                        final astrologer = await astrologerFuture;

                        // Create an instance of FastAPIServices
                        final apiService = FastAPIServices();

                        final response = await apiService.reportAstrologer(

                          astrologerId: astrologer.astroId,
                          // using the fetched astrologer ID
                          reason: selectedReason!,
                        );

                        if (response != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Astrologer reported successfully."),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Failed to report astrologer."),
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
                      "Submit Report",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                ],
              ),
        );
      },
    );
  }


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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
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
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  astrologerFuture =
                      FastAPIServices().fetchAstrologerDetail(widget.astroId);
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: appColor),
              child: const Text(
                  "Try Again", style: TextStyle(color: Colors.white)),
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
          Icon(
            Icons.person_off_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
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
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    if (url.toLowerCase().contains('null')) return false;
    if (url.startsWith('file://')) {
      return url.length > 7;
    }
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

    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }

    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      return 'https://fastapi.jyotishionline.com${imageUrl.startsWith('/')
          ? imageUrl
          : '/$imageUrl'}';
    }

    return imageUrl;
  }

  void _showBlockDialog() {
    final apiService = FastAPIServices();

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(context);

                  try {
                    final astrologer = await astrologerFuture;

                    final response = await apiService.blockAstrologer(

                      astrologerId: astrologer.astroId,
                    );

                    if (response != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Astrologer blocked successfully."),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed to block astrologer."),
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
          ),
    );
  }

}