import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/views/astrologerProfile/FastApi/astroProfile.dart';
import 'package:flutter/material.dart';

class ViewAllAstrologersPage extends StatefulWidget {
  const ViewAllAstrologersPage({Key? key}) : super(key: key);

  @override
  _ViewAllAstrologersPageState createState() => _ViewAllAstrologersPageState();
}

class _ViewAllAstrologersPageState extends State<ViewAllAstrologersPage> {
  final FastAPIServices _apiService = FastAPIServices();
  late Future<List<dynamic>> _futureAstrologers;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredAstrologers = [];
  List<dynamic> _allAstrologers = [];

  static const Color appYellow = Color(0xFFFFC31F);

  @override
  void initState() {
    super.initState();
    _futureAstrologers = _apiService.fetchAllAstrologers();
  }

  void _filterAstrologers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAstrologers = _allAstrologers;
      } else {
        _filteredAstrologers = _allAstrologers.where((astro) {
          final name = astro['name']?.toString().toLowerCase() ?? '';
          final skill = astro['primarySkill']?.toString().toLowerCase() ?? '';
          return name.contains(query.toLowerCase()) ||
              skill.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          color: appYellow,
          size: 16,
        );
      }),
    );
  }

  Widget _buildAstrologerCard(Map<String, dynamic> astro, int index) {
    final isOnline = astro['isOnline'] ?? false;
    final rating = double.tryParse(astro['rating']?.toString() ?? '0') ?? 0.0;
    final reviews = astro['reviewsCount'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Profile Image with Online Badge
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: (astro['profileImage'] != null &&
                        astro['profileImage'].toString().isNotEmpty)
                        ? Image.network(
                      astro['profileImage'].toString().startsWith("http")
                          ? astro['profileImage']
                          : "https://fastapi.jyotishionline.com${astro['profileImage']}",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: Icon(Icons.person,
                              color: Colors.grey.shade400),
                        );
                      },
                    )
                        : Container(
                      color: Colors.grey.shade100,
                      child: Icon(Icons.person,
                          color: Colors.grey.shade400),
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Astrologer Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          astro['name'] ?? "Unknown Astrologer",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: appYellow.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "₹${astro['charge']}/min",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${astro['primarySkill'] ?? 'Astrologer'} • ${astro['experienceInYears'] ?? 0} yrs exp",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildRatingStars(rating),
                      const SizedBox(width: 6),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "($reviews)",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const Spacer(),
                      if (astro['languages'] != null &&
                          astro['languages'].toString().isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.language,
                                size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 2),
                            Text(
                              astro['languages'].toString().split(',').first,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
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

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.grey.shade200,
                        margin: const EdgeInsets.only(bottom: 8),
                      ),
                      Container(
                        width: 120,
                        height: 14,
                        color: Colors.grey.shade200,
                        margin: const EdgeInsets.only(bottom: 8),
                      ),
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.grey.shade200,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Astrologers",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureAstrologers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingShimmer();
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Failed to load astrologers",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _futureAstrologers = _apiService.fetchAllAstrologers();
                      });
                    },
                    child: const Text("Try Again"),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No astrologers available",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          if (_allAstrologers.isEmpty) {
            _allAstrologers = snapshot.data!;
            _filteredAstrologers = _allAstrologers;
          }

          return Column(
            children: [
              // Search Bar
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterAstrologers,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Search by name or skill...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),

              // Results Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      "${_filteredAstrologers.length} astrologers",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Astrologers List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _futureAstrologers = _apiService.fetchAllAstrologers();
                      _allAstrologers.clear();
                      _filteredAstrologers.clear();
                    });
                  },
                  child: ListView.builder(
                    itemCount: _filteredAstrologers.length,
                    itemBuilder: (context, index) {
                      final astro = _filteredAstrologers[index];
                      return InkWell(
                        onTap: () {
                          // Navigate to detail page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AstrologerDetailPage(
                                astroId: astro['astroId'], // Pass the astrologer ID
                              ),
                            ),
                          );
                        },
                        child: _buildAstrologerCard(astro, index),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}