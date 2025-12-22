import 'package:flutter/material.dart';
import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/views/astrologerProfile/FastApi/astroProfile.dart';
import '../../../model/fastApiModel/allAstrologerModel.dart';

class ViewAllAstrologersPage extends StatefulWidget {
  const ViewAllAstrologersPage({Key? key}) : super(key: key);

  @override
  State<ViewAllAstrologersPage> createState() => _ViewAllAstrologersPageState();
}

class _ViewAllAstrologersPageState extends State<ViewAllAstrologersPage> {
  final FastAPIServices _apiService = FastAPIServices();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // State Variables
  List<GetAllAstrologerModel> _allAstrologers = [];
  List<GetAllAstrologerModel> _filteredAstrologers = [];

  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  bool _isFirstLoad = true;

  static const Color appYellow = Color(0xFFFFC31F);

  @override
  void initState() {
    super.initState();
    // Initial fetch (Page 1)
    _fetchNextPage();

    // Listen to scroll to detect bottom of list
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // Fetch next page if we aren't loading, have more data, and not searching
        if (!_isLoading && _hasMoreData && _searchController.text.isEmpty) {
          _fetchNextPage();
        }
      }
    });
  }

  // ------------------------------------------------------
  // 📡 PAGINATION LOGIC (LOADS PAGE 1, 2, 3...)
  // ------------------------------------------------------
  Future<void> _fetchNextPage() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() => _isLoading = true);

    try {
      final List<GetAllAstrologerModel> newItems =
      await _apiService.fetchAllAstrologers(page: _currentPage, size: 10);

      setState(() {
        if (newItems.isEmpty) {
          _hasMoreData = false; // No more pages to load
        } else {
          _currentPage++;
          _allAstrologers.addAll(newItems); // Append new data to existing list
          _filteredAstrologers = List.from(_allAstrologers);
          _sortAstrologers();
        }
        _isFirstLoad = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Pagination Error: $e");
    }
  }

  // ------------------------------------------------------
  // ⭐ SORTING & FILTERING
  // ------------------------------------------------------
  void _sortAstrologers() {
    _filteredAstrologers.sort((a, b) {
      if (b.overallRating != a.overallRating) {
        return b.overallRating.compareTo(a.overallRating);
      }
      return b.totalReviews.compareTo(a.totalReviews);
    });
  }

  void _filterAstrologers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAstrologers = List.from(_allAstrologers);
      } else {
        _filteredAstrologers = _allAstrologers.where((astro) {
          final name = astro.name.toLowerCase();
          final skill = astro.primarySkill?.toLowerCase() ?? '';
          return name.contains(query.toLowerCase()) ||
              skill.contains(query.toLowerCase());
        }).toList();
      }
      _sortAstrologers();
    });
  }

  // ------------------------------------------------------
  // 🖼 HELPERS (Kept from your original code)
  // ------------------------------------------------------
  String _buildImageUrl(String? rawPath) {
    if (rawPath == null || rawPath.trim().isEmpty) return '';
    final cleaned = rawPath.replaceAll('\n', '').replaceAll('\r', '').trim();
    if (cleaned.startsWith('http')) return cleaned;
    return "https://fastapi.jyotishionline.com/${cleaned.startsWith('/') ? cleaned.substring(1) : cleaned}";
  }

  Widget _buildRatingRow(double rating, int reviews) {
    return Row(
      children: [
        const Icon(Icons.star, size: 14, color: Colors.orange),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        Text("($reviews reviews)", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const Spacer(),
        if (rating >= 4.5)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.green.shade600, borderRadius: BorderRadius.circular(4)),
            child: const Text("TOP RATED", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildChargeChip(IconData icon, double charge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.blueGrey),
          const SizedBox(width: 4),
          Text("₹${charge.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAstrologerCard(GetAllAstrologerModel astro) {
    final imageUrl = _buildImageUrl(astro.profileImage);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: appYellow.withOpacity(0.2),
              backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl.isEmpty ? const Icon(Icons.person, size: 35, color: Colors.grey) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(astro.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text("${astro.primarySkill ?? 'Astrologer'} • ${astro.experienceInYears} yrs", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  _buildRatingRow(astro.overallRating, astro.totalReviews),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildChargeChip(Icons.chat_bubble_outline, astro.chatCharge),
                      _buildChargeChip(Icons.call_outlined, astro.audioCallCharge),
                      _buildChargeChip(Icons.videocam_outlined, astro.videoCallCharge),
                    ],
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("All Astrologers", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // SEARCH INPUT
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterAstrologers,
              decoration: InputDecoration(
                hintText: "Search name or skill...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // LIST VIEW
          Expanded(
            child: _isFirstLoad
                ? const Center(child: CircularProgressIndicator(color: appYellow))
                : _filteredAstrologers.isEmpty
                ? const Center(child: Text("No astrologers found"))
                : ListView.builder(
              controller: _scrollController, // IMPORTANT: Connect controller here
              itemCount: _filteredAstrologers.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading spinner at bottom
                if (index == _filteredAstrologers.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator(color: appYellow)),
                  );
                }

                final astro = _filteredAstrologers[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AstrologerDetailPage(astroId: astro.astroId),
                      ),
                    );
                  },
                  child: _buildAstrologerCard(astro),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}