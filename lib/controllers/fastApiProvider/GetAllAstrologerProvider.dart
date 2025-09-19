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
      final List<dynamic> response =
          await FastAPIServices().fetchAllAstrologers();

      print("🧙‍♂️ Total Astrologers: ${response.length}");
      for (var astro in response) {
        print("🔮 Name: ${astro['name']}, Skill: ${astro['primarySkill']}");
      }

      astrologers =
          response.map((json) => GetAllAstrologerModel.fromJson(json)).toList();
    } catch (e) {
      print("❌ Error fetching astrologers: $e");
      astrologers = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
