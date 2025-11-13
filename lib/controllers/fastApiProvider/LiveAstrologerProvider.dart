import 'package:flutter/material.dart';

import '../../fastApi/fastApiServices.dart';
import '../../model/fastApiModel/LiveAstrologerModel.dart';


class LiveAstrologerProvider extends ChangeNotifier {
  final FastAPIServices _api = FastAPIServices();

  bool isLoading = false;
  List<LiveAstrologerModel> liveAstrologers = [];

  Future<void> fetchLiveAstrologers() async {
    isLoading = true;
    notifyListeners();

    try {
      liveAstrologers = await _api.fetchLiveAstrologers();
    } catch (e) {
      print("❌ Error fetching live astrologers: $e");
      liveAstrologers = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
