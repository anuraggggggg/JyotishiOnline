import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../model/fastApiModel/giftModel.dart';
import '../../fastApi/fastApiendpoints.dart';

class GiftProvider with ChangeNotifier {

  List<GiftModel> _gifts = [];
  bool _isLoading = false;
  String? _error;

  List<GiftModel> get gifts => _gifts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getGifts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(FastApiEndpoints.getGifts), // ✅ using your constant
        headers: {
          "accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        _gifts = data
            .map((e) => GiftModel.fromJson(e))
            .where((g) => g.isActive) // optional filter
            .toList();
      } else {
        _error = "Error: ${response.statusCode}";
        _gifts = [];
      }

    } catch (e) {
      _error = e.toString();
      _gifts = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}