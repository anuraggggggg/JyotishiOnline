import 'package:flutter/material.dart';
import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:AstrowayCustomer/model/fastApiModel/allAstrologerModel.dart';

class GetAllAstrologerProvider with ChangeNotifier {
  bool isLoading = false;
  List<GetAllAstrologerModel> astrologers = [];

  Future<void> getAstrologers() async {
    isLoading = true;
    notifyListeners();

    try {
      final response =
      await FastAPIServices().fetchAllAstrologers();

      final List<GetAllAstrologerModel> list = response["list"];
      final int total = response["total"];

      print("📊 Total Astrologers: $total");

      for (var astro in list) {
        print("🔮 Name: ${astro.name}, Skill: ${astro.primarySkill}");
      }

      // ✅ SORT (optional, but backend should handle ideally)
      list.sort((a, b) {
        if (b.overallRating != a.overallRating) {
          return b.overallRating.compareTo(a.overallRating);
        }
        return b.totalReviews.compareTo(a.totalReviews);
      });

      astrologers = list;
    } catch (e) {
      print("❌ Error fetching astrologers: $e");
      astrologers = [];
    }

    isLoading = false;
    notifyListeners();
  }
}