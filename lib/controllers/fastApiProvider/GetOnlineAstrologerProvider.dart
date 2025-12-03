import 'package:flutter/material.dart';
import 'package:AstrowayCustomer/fastApi/fastAPIServices.dart';
import 'package:AstrowayCustomer/model/fastApiModel/OnlineAstrologerModel.dart';

class GetOnlineAstrologerProvider with ChangeNotifier {
  bool isLoading = false;
  List<OnlineAstrologerModel> astrologers = [];

  final FastAPIServices _api = FastAPIServices();

  /// 🚀 Fetch Online Astrologers (with extra debugging)
  Future<void> fetchOnlineAstrologers() async {
    isLoading = true;
    notifyListeners();

    print("📡 Fetching online astrologers...");

    try {
      final result = await _api.fetchOnlineAstrologers();

      if (result.isNotEmpty) {
        astrologers = result;

        print("🔥 Online astrologers fetched: ${astrologers.length}");
        print("📜 -----------------------------");

        for (var a in astrologers) {
          print("🧙 ID: ${a.id}");
          print("👤 Name: ${a.name}");
          print("🖼 Image: ${a.profileImage}");
          print("💬 Chat: ₹${a.chatCharge}");
          print("📞 Audio: ₹${a.audioCallCharge}");
          print("🎥 Video: ₹${a.videoCallCharge}");
          print("⏳ Wait: ${a.waitTime}");
          print("—————————————————————");
        }

      } else {
        print("⚠️ API returned EMPTY LIST");
        astrologers = [];
      }

    } catch (e) {
      astrologers = [];
      print("❌ Error fetching online astrologers: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// 🔄 Manual Refresh
  Future<void> refresh() async {
    print("🔄 Refreshing online astrologers...");
    await fetchOnlineAstrologers();
  }
}
