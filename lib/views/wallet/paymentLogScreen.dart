import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../controllers/fastApiProvider/WalletProvider.dart';
import 'package:AstrowayCustomer/theme/appTheme.dart';
import 'package:AstrowayCustomer/model/fastApiModel/wallet_tx_model.dart';
import '../../services/location_services.dart';

class PaymentLogScreen extends StatefulWidget {
  @override
  _PaymentLogScreenState createState() => _PaymentLogScreenState();
}

class _PaymentLogScreenState extends State<PaymentLogScreen> {
  String _selectedFilter = 'all';
  final GlobalKey<RefreshIndicatorState> _refreshKey =
  GlobalKey<RefreshIndicatorState>();

  double _usdRate = 83; // fallback

  @override
  void initState() {
    super.initState();

    _fetchUsdRate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchWalletTransactions();
    });
  }

  Future<void> _fetchUsdRate() async {
    try {
      final response =
      await http.get(Uri.parse("https://open.er-api.com/v6/latest/USD"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _usdRate = data["rates"]["INR"];
        });
      }
    } catch (e) {
      debugPrint("Currency fetch failed: $e");
    }
  }

  Future<void> _refresh() async {
    await context.read<WalletProvider>().fetchWalletTransactions();
  }

  // ---------------------------------------------------------------------------
  // FILTER CHIPS
  // ---------------------------------------------------------------------------

  Widget _chip(String label, String value, Color color) {
    final selected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedFilter = value),
      selectedColor: color.withOpacity(0.25),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: selected ? color : Colors.grey[700],
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _chip('All', 'all', appYellow),
          _chip('Credits', 'credit', Colors.green),
          _chip('Debits', 'debit', Colors.red),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TRANSACTION LIST
  // ---------------------------------------------------------------------------

  Widget _buildList(
      WalletProvider provider,
      List<WalletTxModel> list,
      ) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: appYellow),
      );
    }

    if (provider.errorMessage != null) {
      return _errorState(provider.errorMessage!);
    }

    if (list.isEmpty) {
      return _emptyState();
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) => _transactionCard(list[i]),
    );
  }

  // ---------------------------------------------------------------------------
  // TRANSACTION CARD
  // ---------------------------------------------------------------------------

  Widget _transactionCard(WalletTxModel tx) {
    final bool isCredit = tx.isCredit;
    final Color color = isCredit ? Colors.green : Colors.red;

    final bool hasDuration = tx.duration != "00:00:00";

    double displayAmount = tx.amount;

    if (!LocationService.isIndianUser) {
      displayAmount = tx.amount / _usdRate;
    }

    String currency = LocationService.isIndianUser ? "₹" : "\$";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(_icon(tx.transactionType), color: color),
        ),
        title: Text(
          _description(tx.transactionType, isCredit),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('dd MMM yyyy, hh:mm a').format(tx.createdAt),
              style: const TextStyle(fontSize: 12),
            ),
            if (hasDuration) ...[
              const SizedBox(height: 2),
              Text(
                "Duration: ${tx.duration}",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 4),
            _statusChip(tx.status),
          ],
        ),
        trailing: Text(
          isCredit
              ? "+$currency${displayAmount.toStringAsFixed(2)}"
              : "-$currency${displayAmount.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  IconData _icon(String type) {
    switch (type) {
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'audio_call':
        return Icons.call_outlined;
      case 'video_call':
        return Icons.videocam_outlined;
      case 'send_money':
        return Icons.compare_arrows;
      default:
        return Icons.account_balance_wallet;
    }
  }

  String _description(String type, bool isCredit) {
    if (isCredit) return "Wallet Credit";
    switch (type) {
      case 'chat':
        return "Chat Consultation";
      case 'audio_call':
        return "Audio Call";
      case 'video_call':
        return "Video Call";
      case 'send_money':
        return "Money Sent";
      default:
        return "Wallet Transaction";
    }
  }

  Widget _statusChip(String status) {
    final color =
    status.toLowerCase() == 'success' ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _errorState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64),
          const SizedBox(height: 12),
          Text(msg),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey),
          SizedBox(height: 12),
          Text("No transactions found"),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (_, provider, __) {
        final List<WalletTxModel> all = [...provider.transactions]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final filtered = _selectedFilter == 'all'
            ? all
            : all.where((tx) {
          return _selectedFilter == 'credit'
              ? tx.isCredit
              : !tx.isCredit;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Payment History",
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.bold),
            ),
            backgroundColor: appYellow,
            iconTheme: const IconThemeData(color: textColor),
            centerTitle: true,
          ),
          body: RefreshIndicator(
            key: _refreshKey,
            onRefresh: _refresh,
            color: appYellow,
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildFilterChips(),
                const SizedBox(height: 8),
                Expanded(child: _buildList(provider, filtered)),
              ],
            ),
          ),
        );
      },
    );
  }
}