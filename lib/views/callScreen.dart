import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/services/location_services.dart';
import 'package:flutter/material.dart';
import '../../../model/fastApiModel/allAstrologerModel.dart';
import 'astrologerProfile/FastApi/astroProfile.dart';

class CallAstrologerScreen extends StatefulWidget {
  const CallAstrologerScreen({Key? key}) : super(key: key);

  @override
  _CallAstrologerScreenState createState() => _CallAstrologerScreenState();
}

class _CallAstrologerScreenState extends State<CallAstrologerScreen> {
  final FastAPIServices _apiService = FastAPIServices();
  final ScrollController _scrollController = ScrollController();

  // State Variables
  List<GetAllAstrologerModel> _allAstrologers = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  bool _isFirstLoad = true;
  int _totalAstrologers = 0;

  static const Color appYellow = Color(0xFFFFC31F);

  @override
  void initState() {
    super.initState();
    _fetchAstrologers();

    // Pagination Listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMoreData) {
          _fetchAstrologers();
        }
      }
    });
  }

  // ------------------------------------------------------
  // 📡 FETCH DATA
  // ------------------------------------------------------
  Future<void> _fetchAstrologers() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.fetchAllAstrologers(
        page: _currentPage,
        size: 10,
      );

      final List<GetAllAstrologerModel> newItems = response["list"];
      final int total = response["total"];

      setState(() {
        _totalAstrologers = total; // ✅ store total count

        if (newItems.isEmpty) {
          _hasMoreData = false;
        } else {
          _currentPage++;
          _allAstrologers.addAll(newItems);

          // ✅ OPTIONAL SORT (remove if backend handles it)
          _allAstrologers.sort((a, b) {
            if (b.overallRating != a.overallRating) {
              return b.overallRating.compareTo(a.overallRating);
            }
            return b.totalReviews.compareTo(a.totalReviews);
          });
        }

        _isFirstLoad = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Call Screen Pagination Error: $e");
    }
  }

  // ------------------------------------------------------
  // 🎨 ENHANCED UI CARD
  // ------------------------------------------------------
  Widget _buildAstrologerCard(GetAllAstrologerModel astro) {
    String imageUrl = "";
    if (astro.profileImage != null && astro.profileImage!.isNotEmpty) {
      final cleaned = astro.profileImage!.replaceAll('\n', '').trim();
      imageUrl = cleaned.startsWith("http")
          ? cleaned
          : "https://fastapi.jyotishionline.com/${cleaned.startsWith('/') ? cleaned.substring(1) : cleaned}";
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AstrologerDetailPage(astroId: astro.astroId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0.5,
            ),
          ],
          border: Border.all(color: Colors.grey.shade100, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Section
            Container(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade100,
                          image: imageUrl.isNotEmpty
                              ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: imageUrl.isEmpty
                            ? Icon(Icons.person, size: 36, color: Colors.grey.shade400)
                            : null,
                      ),

                    ],
                  ),
                  const SizedBox(height: 8),
                  // Rating Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber.shade700, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          astro.overallRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${astro.totalReviews} reviews",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Astrologer Details Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              astro.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (astro.primarySkill != null && astro.primarySkill!.isNotEmpty)
                              Text(
                                astro.primarySkill!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: appYellow,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Call Price Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: LocationService.isIndianUser ? Text(
                          "₹${astro.audioCallCharge.toStringAsFixed(0)}/min",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ) : Text(
                          "\$${astro.audioCallChargeUSD.toStringAsFixed(0)}/min",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        )
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Languages & Experience
                  Row(
                    children: [
                      Icon(Icons.language, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          astro.languageKnown ?? 'English, Hindi',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(Icons.work_outline, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        "${astro.experienceInYears} Years Experience",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Call Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AstrologerDetailPage(astroId: astro.astroId)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: Colors.green.withOpacity(0.3),
                      ),
                      icon: Icon(Icons.call, size: 18),
                      label: const Text(
                        "Call Now",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(

        title: const Text(
          "Call Astrologers",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 0.5,
            color: Colors.black,
          ),
        ),
        backgroundColor: appYellow,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
        ),
      ),
      body: _isFirstLoad
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: appYellow,
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            Text(
              "Loading Astrologers...",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        color: appYellow,
        onRefresh: () async {
          setState(() {
            _allAstrologers.clear();
            _currentPage = 1;
            _hasMoreData = true;
          });
          await _fetchAstrologers();
        },
        child: Column(
          children: [
            // Header Stats
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$_totalAstrologers Astrologers Available",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),

                ],
              ),
            ),

            // Astrologers List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                itemCount: _allAstrologers.length + (_hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _allAstrologers.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: appYellow,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Loading more astrologers...",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return _buildAstrologerCard(_allAstrologers[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}