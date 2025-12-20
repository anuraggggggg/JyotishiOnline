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
  static const Color appDark = Color(0xFF1A1A1A);

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

  Widget _buildChargeChip(IconData icon, String label, dynamic charge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.blueGrey),
          const SizedBox(width: 4),
          Text(
            "₹$charge",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildAstrologerCard(Map<String, dynamic> astro, int index) {
    final isOnline = astro['isActive'] ?? false; // Using isActive from your JSON as online status

    // Extracting charges from your JSON structure
    final chatCharge = astro['chatCharge'] ?? 0;
    final audioCharge = astro['audioCallCharge'] ?? 0;
    final videoCharge = astro['videoCallCharge'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Stack(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: appYellow.withOpacity(0.2),
                  backgroundImage: (astro['profileImage'] != null && astro['profileImage'].toString().isNotEmpty)
                      ? NetworkImage(astro['profileImage'].toString().startsWith("http")
                      ? astro['profileImage']
                      : "https://fastapi.jyotishionline.com/${astro['profileImage']}")
                      : null,
                  child: (astro['profileImage'] == null) ? const Icon(Icons.person, size: 35, color: Colors.grey) : null,
                ),
                if (isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    astro['name'] ?? "Astrologer",
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${astro['primarySkill'] ?? 'General'} • ${astro['experienceInYears'] ?? 0} yrs",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Exp: ${astro['languageKnown'] ?? 'English, Hindi'}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Charges Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildChargeChip(Icons.chat_bubble_outline, "Chat", chatCharge),
                      _buildChargeChip(Icons.call_outlined, "Audio", audioCharge),
                      _buildChargeChip(Icons.videocam_outlined, "Video", videoCharge),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("All Astrologers", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureAstrologers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: appYellow));
          }

          if (_allAstrologers.isEmpty && snapshot.hasData) {
            _allAstrologers = snapshot.data!;
            _filteredAstrologers = _allAstrologers;
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterAstrologers,
                  decoration: InputDecoration(
                    hintText: "Search Astrologer...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: _filteredAstrologers.length,
                  itemBuilder: (context, index) {
                    final astro = _filteredAstrologers[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AstrologerDetailPage(
                              astroId: astro['astro_id'],
                            ),
                          ),
                        );
                      },
                      child: _buildAstrologerCard(astro, index),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}