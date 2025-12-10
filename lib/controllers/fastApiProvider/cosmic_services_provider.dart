import 'package:flutter/material.dart';

import '../../fastApi/fastApiServices.dart';
import '../../model/fastApiModel/cosmic_service_model.dart';



class CosmicServicesProvider extends ChangeNotifier {
  bool isLoading = true;
  List<CosmicService> services = [];

  Future<void> loadCosmicServices() async {
    try {
      isLoading = true;
      notifyListeners();

      final api = FastAPIServices();

      // ✅ Correct method call
      final data = await api.getCosmicServices();

      services = data.map<CosmicService>(
            (e) => CosmicService.fromJson(e),
      ).toList();
    } catch (e) {
      print("❌ Provider Error Cosmic Services: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
