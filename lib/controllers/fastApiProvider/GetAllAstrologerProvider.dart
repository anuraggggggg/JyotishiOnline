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
      // 1. Fetch the data (This returns List<GetAllAstrologerModel>)
      final List<GetAllAstrologerModel> response =
      await FastAPIServices().fetchAllAstrologers();

      // 2. ✅ FIX: Use dot notation for printing (No more astro['name'])
      print("🧙‍♂️ Total Astrologers: ${response.length}");
      for (var astro in response) {
        print("🔮 Name: ${astro.name}, Skill: ${astro.primarySkill}");
      }

      // 3. ✅ SORT: Highest Rating first, then by Reviews
      response.sort((a, b) {
        if (b.overallRating != a.overallRating) {
          return b.overallRating.compareTo(a.overallRating);
        }
        return b.totalReviews.compareTo(a.totalReviews);
      });

      astrologers = response;
    } catch (e) {
      print("❌ Error fetching astrologers: $e");
      astrologers = [];
    }

    isLoading = false;
    notifyListeners();
  }
}