import 'package:flutter/material.dart';
import '../../../fastApi/fastApiServices.dart';
import '../../../model/fastApiModel/astrologerProfileModel.dart';
import '../../../theme/appTheme.dart';
import '../../../utils/global.dart';

class AstrologerDetailPage extends StatefulWidget {
  final String astroId;

  const AstrologerDetailPage({super.key, required this.astroId});

  @override
  State<AstrologerDetailPage> createState() => _AstrologerDetailPageState();
}

class _AstrologerDetailPageState extends State<AstrologerDetailPage> with SingleTickerProviderStateMixin {
  late Future<Astrologer> astrologerFuture;
  late TabController _tabController;
  int _selectedDuration = 10; // Default duration

  @override
  void initState() {
    super.initState();
    astrologerFuture = FastAPIServices().fetchAstrologerDetail(widget.astroId);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          // Report Button
          IconButton(
            icon: Icon(Icons.report_problem_outlined, color: Colors.grey.shade600),
            onPressed: _showReportDialog,
            tooltip: 'Report Astrologer',
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
    );
  }

  Widget _buildAstrologerUI(Astrologer astrologer) {
    final imageUrl = (astrologer.profileImage ?? '').trim();
    final hasValidImage = _isValidImageUrl(imageUrl);
    final completeImageUrl = hasValidImage ? _getCompleteImageUrl(imageUrl) : '';

    return Column(
      children: [
        // Header Section
        _buildHeaderSection(astrologer, hasValidImage, completeImageUrl),

        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: appColor,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: appColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.audiotrack, size: 20),
                text: 'Audio Call',
              ),
              Tab(
                icon: Icon(Icons.videocam, size: 20),
                text: 'Video Call',
              ),
              Tab(
                icon: Icon(Icons.chat, size: 20),
                text: 'Chat',
              ),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCallTab(astrologer, 'Audio'),
              _buildCallTab(astrologer, 'Video'),
              _buildChatTab(astrologer),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to validate image URLs
  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    if (url.toLowerCase().contains('null')) return false;
    if (url.startsWith('file://')) {
      // Check if it's a valid file path that can be converted
      return url.length > 7; // More than just 'file://'
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return !url.contains('/astro/null') &&
          !url.contains('undefined') &&
          !url.contains('placeholder');
    }
    // If it's a relative path, consider it valid
    return url.isNotEmpty;
  }

  // Helper method to get complete image URL
  String _getCompleteImageUrl(String imageUrl) {
    if (imageUrl.startsWith('file://')) {
      // Convert file:// URLs to complete network URLs
      final String fileName = imageUrl.split('/').last;
      return 'https://fastapi.jyotishionline.com/static/uploads/$fileName';
    }

    // If it's already a complete URL, return as is
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }

    // If it's a relative path, prepend base URL
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      return 'https://fastapi.jyotishionline.com${imageUrl.startsWith('/') ? imageUrl : '/$imageUrl'}';
    }

    return imageUrl;
  }

  Widget _buildHeaderSection(Astrologer astrologer, bool hasValidImage, String imageUrl) {
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
                  radius: 50,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: hasValidImage
                      ? NetworkImage(imageUrl)
                      : null,
                  child: !hasValidImage
                      ? Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey.shade400,
                  )
                      : null,
                ),
              ),
              // Online Status Badge
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.circle,
                  color: Colors.white,
                  size: 12,
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
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.verified,
                color: appColor,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Tagline
          Text(
            "Expert ${astrologer.primarySkill} Astrologer",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Rating and Reviews
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              const Text(
                "4.8",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 16,
                color: Colors.grey.shade300,
              ),
              const SizedBox(width: 8),
              Text(
                "1.2k Reviews",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCallTab(Astrologer astrologer, String callType) {
    final isAudio = callType == 'Audio';
    final icon = isAudio ? Icons.audiotrack : Icons.videocam;
    final price = isAudio
        ? (astrologer.charge! * 0.8) // 20% discount for audio
        : astrologer.charge!;
    final totalPrice = price * _selectedDuration;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Pricing Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [appColor, appColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: appColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "$callType Call Consultation",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "₹ ${price.toStringAsFixed(2)} / min",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Total for $_selectedDuration mins: ₹ ${totalPrice.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "First 5 mins free for new users",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                if (isAudio) ...[
                  const SizedBox(height: 4),
                  Text(
                    "20% off regular video call rate",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Duration Selection
          _buildDurationSection(callType),

          const SizedBox(height: 24),

          // Send Request Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _sendCallRequest(astrologer, callType, _selectedDuration),
              style: ElevatedButton.styleFrom(
                backgroundColor: appColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    "Send ${callType} Call Request",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Features List
          _buildFeaturesList(callType),
        ],
      ),
    );
  }

  Widget _buildChatTab(Astrologer astrologer) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Pricing Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [appColor, appColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: appColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "Chat Consultation",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "₹ ${(astrologer.charge! * 0.5).toStringAsFixed(2)} / message",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "First message free for new users",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "50% off call rates",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Chat Features
          _buildChatFeatures(),

          const SizedBox(height: 24),

          // Send Chat Request Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _sendChatRequest(astrologer),
              style: ElevatedButton.styleFrom(
                backgroundColor: appColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    "Send Chat Request",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSection(String callType) {
    final durations = [5, 10, 15, 30, 60];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Duration (minutes)",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: durations.map((duration) {
            return ChoiceChip(
              label: Text('$duration min'),
              selected: _selectedDuration == duration,
              onSelected: (selected) {
                setState(() {
                  _selectedDuration = duration;
                });
              },
              selectedColor: appColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: _selectedDuration == duration ? appColor : Colors.grey.shade700,
                fontWeight: _selectedDuration == duration ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(String callType) {
    final features = callType == 'Audio'
        ? [
      'Clear voice quality',
      'Uninterrupted connection',
      'Record call option',
      '20% cheaper than video'
    ]
        : [
      'Face-to-face consultation',
      'Screen sharing available',
      'Record session option',
      'Better understanding through video'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Features",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: features.map((feature) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: appColor,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChatFeatures() {
    final features = [
      'Unlimited messages for 24 hours',
      'Share images and documents',
      'Get detailed written responses',
      '50% cheaper than call rates',
      'Response within 15 minutes'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Chat Features",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: features.map((feature) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: appColor,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _sendCallRequest(Astrologer astrologer, String callType, int duration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Send $callType Call Request"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("You are sending a $callType call request to ${astrologer.name}"),
            const SizedBox(height: 8),
            Text("Duration: $duration minutes"),
            const SizedBox(height: 8),
            Text("Total Amount: ₹ ${(callType == 'Audio' ? astrologer.charge! * 0.8 : astrologer.charge!) * duration}"),
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
            child: const Text("Send Request", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _sendChatRequest(Astrologer astrologer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              _showRequestSentDialog('Chat');
            },
            style: ElevatedButton.styleFrom(backgroundColor: appColor),
            child: const Text("Send Request", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRequestSentDialog(String requestType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Optionally navigate to requests page
            },
            child: const Text("View My Requests"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: appColor),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Report Astrologer"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Please select the reason for reporting:"),
            const SizedBox(height: 16),
            ...['Inappropriate behavior', 'Fake profile', 'Poor service', 'Other']
                .map((reason) => RadioListTile<String>(
              title: Text(reason),
              value: reason,
              groupValue: null,
              onChanged: (value) {},
            ))
                .toList(),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Report submitted successfully")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Submit Report", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
                  astrologerFuture = FastAPIServices().fetchAstrologerDetail(widget.astroId);
                });
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
}