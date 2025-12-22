import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:flutter/material.dart';
import '../../../model/fastApiModel/allAstrologerModel.dart'; // Ensure correct path
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

  static const Color appYellow = Color(0xFFFFC31F);

  @override
  void initState() {
    super.initState();
    _fetchAstrologers(); // Initial Load (Page 1)

    // ✅ Setup Pagination Listener
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
  // 📡 FETCH DATA (PAGE BY PAGE)
  // ------------------------------------------------------
  Future<void> _fetchAstrologers() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() => _isLoading = true);

    try {
      final List<GetAllAstrologerModel> newItems =
      await _apiService.fetchAllAstrologers(page: _currentPage, size: 10);

      setState(() {
        if (newItems.isEmpty) {
          _hasMoreData = false;
        } else {
          _currentPage++;
          _allAstrologers.addAll(newItems);

          // ✅ SORTING: Highest Rating first
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
  // 🧙 ASTROLOGER CARD (UPDATED TO USE MODEL)
  // ------------------------------------------------------
  Widget _buildAstrologerCard(GetAllAstrologerModel astro) {
    // Image Path Cleanup
    String imageUrl = "";
    if (astro.profileImage != null && astro.profileImage!.isNotEmpty) {
      final cleaned = astro.profileImage!.replaceAll('\n', '').trim();
      imageUrl = cleaned.startsWith("http")
          ? cleaned
          : "https://fastapi.jyotishionline.com/${cleaned.startsWith('/') ? cleaned.substring(1) : cleaned}";
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AstrologerDetailPage(astroId: astro.astroId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: imageUrl.isEmpty
                    ? Icon(Icons.person, color: Colors.grey.shade400)
                    : null,
              ),
              const SizedBox(width: 16),

              // Name + Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      astro.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${astro.primarySkill ?? 'Astrologer'} • ${astro.experienceInYears} yrs",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${astro.audioCallCharge.toStringAsFixed(0)}/min",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              // Call Icon
              const Icon(Icons.call, color: Colors.green, size: 28),
            ],
          ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Call Astrologer", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isFirstLoad
          ? const Center(child: CircularProgressIndicator(color: appYellow))
          : RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _allAstrologers.clear();
            _currentPage = 1;
            _hasMoreData = true;
            _isFirstLoad = true;
          });
          await _fetchAstrologers();
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _allAstrologers.length + (_hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loading spinner at bottom
            if (index == _allAstrologers.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator(color: appYellow)),
              );
            }

            return _buildAstrologerCard(_allAstrologers[index]);
          },
        ),
      ),
    );
  }
}