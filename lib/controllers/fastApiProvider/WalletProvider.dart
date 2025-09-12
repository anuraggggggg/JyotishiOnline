import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../apiManager/apiServices.dart';
import '../../fastApi/fastApiServices.dart';


class WalletProvider with ChangeNotifier {
  final FastAPIServices apiService;

  WalletProvider(this.apiService);

  List<dynamic> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWalletTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await apiService.getWalletTransactions();
      _transactions = data;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}