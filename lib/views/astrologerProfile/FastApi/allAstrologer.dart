import 'package:AstrowayCustomer/services/location_services.dart';
import 'package:flutter/material.dart';
import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/views/astrologerProfile/FastApi/astroProfile.dart';
import '../../../model/fastApiModel/allAstrologerModel.dart';
import 'dart:async';

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
  int _totalAstrologers = 0;

  // Search state
  String _currentSearchQuery = '';
  bool _isSearching = false;
  bool _hasSearched = false;
  int _searchCurrentPage = 1;
  bool _searchHasMoreData = true;

  static const Color appYellow = Color(0xFFFFC31F);
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _fetchNextPage();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (_isSearching && _searchHasMoreData && !_isLoading) {
          _loadMoreSearchResults();
        } else if (!_isSearching && !_isLoading && _hasMoreData && _searchController.text.isEmpty) {
          _fetchNextPage();
        }
      }
    });
  }

  // ------------------------------------------------------
  // 📡 PAGINATION LOGIC FOR NORMAL LIST
  // ------------------------------------------------------
  Future<void> _fetchNextPage() async {
    if (_isLoading || !_hasMoreData || _isSearching) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.fetchAllAstrologers(
        page: _currentPage,
        size: 10,
      );

      final List<GetAllAstrologerModel> newItems = response["list"];
      final int total = response["total"];

      setState(() {
        _totalAstrologers = total;

        if (newItems.isEmpty) {
          _hasMoreData = false;
        } else {
          _currentPage++;
          _allAstrologers.addAll(newItems);
          _filteredAstrologers = List.from(_allAstrologers);
          _sortAstrologers();
        }

        _isFirstLoad = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Pagination Error: $e");
      _showErrorSnackBar("Failed to load astrologers");
    }
  }

  // ------------------------------------------------------
  // 🔍 SEARCH FUNCTION - SEARCHES ENTIRE DATABASE
  // ------------------------------------------------------
  Future<void> _performSearch(String query, {bool loadMore = false}) async {
    if (query.isEmpty) {
      _clearSearch();
      return;
    }

    if (_isLoading) return;

    if (!loadMore) {
      // New search - reset everything
      setState(() {
        _isLoading = true;
        _isSearching = true;
        _hasSearched = true;
        _currentSearchQuery = query;
        _filteredAstrologers = [];
        _searchCurrentPage = 1;
        _searchHasMoreData = true;
      });
    } else {
      setState(() => _isLoading = true);
    }

    try {
      final response = await _apiService.searchAstrologers(
        search: query,
        page: loadMore ? _searchCurrentPage : 1,
        size: 10,
        orderBy: 'rating',
        orderDir: 'desc',
      );

      final List<GetAllAstrologerModel> newItems = response["list"];
      final int total = response["total"];

      setState(() {
        _totalAstrologers = total;

        if (loadMore) {
          // Append to existing search results
          _filteredAstrologers.addAll(newItems);
        } else {
          // Replace with new search results
          _filteredAstrologers = newItems;
        }

        // Check if we have more data to load
        if (newItems.isEmpty || _filteredAstrologers.length >= total) {
          _searchHasMoreData = false;
        } else {
          _searchCurrentPage++;
          _searchHasMoreData = true;
        }

        _isLoading = false;
        _sortAstrologers();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Search Error: $e");
      _showErrorSnackBar("Search failed. Please try again.");
    }
  }

  Future<void> _loadMoreSearchResults() async {
    if (_currentSearchQuery.isNotEmpty && _searchHasMoreData && !_isLoading) {
      await _performSearch(_currentSearchQuery, loadMore: true);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        _clearSearch();
      } else if (query.length >= 2) { // Only search if at least 2 characters
        _performSearch(query);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _hasSearched = false;
      _currentSearchQuery = '';
      _searchCurrentPage = 1;
      _searchHasMoreData = true;
      _filteredAstrologers = List.from(_allAstrologers);
      _sortAstrologers();
      // Reset total count to normal list total
      _totalAstrologers = _allAstrologers.length;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
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

  // ------------------------------------------------------
  // 🖼️ IMAGE URL HELPER
  // ------------------------------------------------------
  String _buildImageUrl(String? rawPath) {
    if (rawPath == null || rawPath.trim().isEmpty) return '';
    final cleaned = rawPath.replaceAll('\n', '').replaceAll('\r', '').trim();
    if (cleaned.startsWith('http')) return cleaned;
    return "https://fastapi.jyotishionline.com/${cleaned.startsWith('/') ? cleaned.substring(1) : cleaned}";
  }

  // ------------------------------------------------------
  // 🎨 ASTROLOGER CARD
  // ------------------------------------------------------
  Widget _buildAstrologerCard(GetAllAstrologerModel astro) {
    final imageUrl = _buildImageUrl(astro.profileImage);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AstrologerDetailPage(astroId: astro.astroId),
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
                      // Top Rated Badge
                      if (astro.overallRating >= 4.5)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "TOP RATED",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

                  // Pricing Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      // Chat Pricing
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 14, color: appYellow),
                            const SizedBox(width: 6),
                            LocationService.isIndianUser ? Text(
                              "₹${astro.chatCharge.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ) : Text(
                              "\$${astro.chatChargeUSD.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Call Pricing
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.call_outlined, size: 14, color: Colors.blue),
                            const SizedBox(width: 6),
                            LocationService.isIndianUser ? Text(
                              "₹${astro.audioCallCharge.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ) : Text(
                              "\$${astro.audioCallChargeUSD.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Video Pricing
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.videocam_outlined, size: 14, color: Colors.purple),
                            const SizedBox(width: 6),
                            LocationService.isIndianUser ? Text(
                              "₹${astro.videoCallCharge.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ) : Text(
                              "\$${astro.videoCallChargeUSD.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ) ,
                          ],
                        ),
                      ),
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
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "All Astrologers",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 0.5,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
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
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
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
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search by name, skill, or language...",
                prefixIcon: Icon(Icons.search, color: appYellow),
                suffixIcon: _isSearching && _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey.shade500),
                  onPressed: _clearSearch,
                )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          ),

          // Stats Bar
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
                  _isSearching
                      ? "Found $_totalAstrologers Astrologer${_totalAstrologers != 1 ? 's' : ''}"
                      : "$_totalAstrologers Astrologer${_totalAstrologers != 1 ? 's' : ''} Available",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (_isSearching)
                  TextButton(
                    onPressed: _clearSearch,
                    child: Text(
                      "Clear",
                      style: TextStyle(
                        color: appYellow,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Astrologers List
          Expanded(
            child: _isFirstLoad && !_isSearching
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
                : _filteredAstrologers.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isSearching ? Icons.search_off : Icons.people_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSearching
                        ? "No results found for '${_searchController.text}'"
                        : "No astrologers available",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  if (_isSearching)
                    TextButton(
                      onPressed: _clearSearch,
                      child: Text(
                        "View all astrologers",
                        style: TextStyle(
                          color: appYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: _filteredAstrologers.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _filteredAstrologers.length) {
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
                            _isSearching
                                ? "Loading more results..."
                                : "Loading more astrologers...",
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
                return _buildAstrologerCard(_filteredAstrologers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}