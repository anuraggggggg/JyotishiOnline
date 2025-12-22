import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:flutter/material.dart';
import '../../../model/fastApiModel/allAstrologerModel.dart'; // Ensure correct path
import 'astrologerProfile/FastApi/astroProfile.dart';

class ChatAstrologerScreen extends StatefulWidget {
  const ChatAstrologerScreen({Key? key}) : super(key: key);

  @override
  _ChatAstrologerScreenState createState() => _ChatAstrologerScreenState();
}

class _ChatAstrologerScreenState extends State<ChatAstrologerScreen> {
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
    _fetchAstrologers(); // Load Page 1

    // ✅ Pagination Listener
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

          // ✅ SORTING: Keep top rated at the top of the chat list
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
      debugPrint("Pagination Error: $e");
    }
  }

  // ------------------------------------------------------
  // 🧙 ASTROLOGER CARD (UPDATED TO USE MODEL)
  // ------------------------------------------------------
  Widget _buildAstrologerCard(GetAllAstrologerModel astro) {
    // Determine Image URL
    String imageUrl = "";
    if (astro.profileImage != null && astro.profileImage!.isNotEmpty) {
      imageUrl = astro.profileImage!.startsWith("http")
          ? astro.profileImage!
          : "https://fastapi.jyotishionline.com/${astro.profileImage!.startsWith('/') ? astro.profileImage!.substring(1) : astro.profileImage}";
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
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                    child: imageUrl.isEmpty
                        ? Icon(Icons.person, color: Colors.grey.shade400)
                        : null,
                  ),
                  // Assuming Online status comes from API, if not available use a default
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green, // You can toggle this based on a field
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
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
                      "₹${astro.chatCharge.toStringAsFixed(0)}/min",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chat, color: Colors.blue, size: 28),
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
      appBar: AppBar(
        title: const Text("Chat with Astrologer"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _isFirstLoad
          ? const Center(child: CircularProgressIndicator(color: appYellow))
          : RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _allAstrologers.clear();
            _currentPage = 1;
            _hasMoreData = true;
          });
          await _fetchAstrologers();
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _allAstrologers.length + (_hasMoreData ? 1 : 0),
          itemBuilder: (context, index) {
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