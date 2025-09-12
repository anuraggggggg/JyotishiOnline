import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/fastApiProvider/WalletProvider.dart';
import 'package:AstrowayCustomer/theme/appTheme.dart';

class PaymentLogScreen extends StatefulWidget {
  @override
  _PaymentLogScreenState createState() => _PaymentLogScreenState();
}

class _PaymentLogScreenState extends State<PaymentLogScreen> {
  String _selectedFilter = 'all'; // 'all', 'credit', 'debit'
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletProvider>(context, listen: false).fetchWalletTransactions();
    });
  }

  Future<void> _refreshData() async {
    await Provider.of<WalletProvider>(context, listen: false)
        .fetchWalletTransactions();
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _selectedFilter == 'all',
            onSelected: (bool selected) {
              setState(() {
                _selectedFilter = selected ? 'all' : _selectedFilter;
              });
            },
            selectedColor: appYellow.withOpacity(0.3),
            checkmarkColor: textColor,
            labelStyle: TextStyle(
              color: _selectedFilter == 'all' ? textColor : Colors.grey[700],
              fontWeight: _selectedFilter == 'all' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          FilterChip(
            label: const Text('Credits'),
            selected: _selectedFilter == 'credit',
            onSelected: (bool selected) {
              setState(() {
                _selectedFilter = selected ? 'credit' : _selectedFilter;
              });
            },
            selectedColor: Colors.green.withOpacity(0.3),
            checkmarkColor: Colors.green,
            labelStyle: TextStyle(
              color: _selectedFilter == 'credit' ? Colors.green[700] : Colors.grey[700],
              fontWeight: _selectedFilter == 'credit' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          FilterChip(
            label: const Text('Debits'),
            selected: _selectedFilter == 'debit',
            onSelected: (bool selected) {
              setState(() {
                _selectedFilter = selected ? 'debit' : _selectedFilter;
              });
            },
            selectedColor: Colors.red.withOpacity(0.3),
            checkmarkColor: Colors.red,
            labelStyle: TextStyle(
              color: _selectedFilter == 'debit' ? Colors.red[700] : Colors.grey[700],
              fontWeight: _selectedFilter == 'debit' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(WalletProvider walletProvider, List<dynamic> transactions) {
    if (walletProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(appYellow),
        ),
      );
    } else if (walletProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              '${walletProvider.errorMessage}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                walletProvider.fetchWalletTransactions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: appYellow,
                foregroundColor: textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    } else if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No transactions found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all'
                  ? 'Your transactions will appear here'
                  : 'No ${_selectedFilter == 'credit' ? 'credits' : 'debits'} found',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final log = transactions[index];
          return _buildTransactionCard(log);
        },
      );
    }
  }

  // Widget _buildSummaryCard(List<dynamic> logs) {
  //   double totalCredits = 0;
  //   double totalDebits = 0;
  //
  //   for (var log in logs) {
  //     final amount = (log['amount'] ?? 0).toDouble();
  //     if (log['transactionType'] == 'credit' && log['status'] == 'success') {
  //       totalCredits += amount;
  //     } else if (log['transactionType'] == 'debit' && log['status'] == 'success') {
  //       totalDebits += amount;
  //     }
  //   }
  //
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     margin: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [appYellow.withOpacity(0.8), appYellow],
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.3),
  //           spreadRadius: 1,
  //           blurRadius: 5,
  //           offset: const Offset(0, 3),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         const Text(
  //           "Wallet Summary",
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //             color: textColor,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: [
  //             _buildSummaryItem("Total Credits", totalCredits, Colors.green[700]!),
  //             Container(
  //               width: 1,
  //               height: 40,
  //               color: Colors.white.withOpacity(0.5),
  //             ),
  //             _buildSummaryItem("Total Debits", totalDebits, Colors.red[700]!),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSummaryItem(String title, double value, Color color) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 14, color: Colors.white)),
        const SizedBox(height: 4),
        Text(
          "₹${value.toStringAsFixed(0)}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> log) {
    final isCredit = log['transactionType'] == 'credit';
    final icon = isCredit ? Icons.arrow_circle_up : Icons.arrow_circle_down;
    final color = isCredit ? Colors.green : Colors.red;
    final status = (log['status'] ?? 'Completed').toLowerCase();
    final statusColor = status == 'success' ? Colors.green : Colors.orange;
    final amount = (log['amount'] ?? 0).toDouble();

    // Custom description
    final description = isCredit
        ? "Added to Wallet"
        : "Cosmic Insights Services";

    DateTime? date;
    try {
      date = DateTime.parse(log['created_at']);
    } catch (e) {
      date = null;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          description,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date != null
                  ? DateFormat('dd MMM yyyy, hh:mm a').format(date)
                  : 'Invalid Date',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isCredit ? "+₹${amount.toStringAsFixed(0)}" : "-₹${amount.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Balance: ₹${(log['balance_after'] ?? 0).toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        // Filter transactions based on selection
        final filteredTransactions = _selectedFilter == 'all'
            ? walletProvider.transactions
            : walletProvider.transactions
            .where((t) => t['transactionType'] == _selectedFilter)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Payment History",
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            backgroundColor: appYellow,
            iconTheme: const IconThemeData(color: textColor),
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _refreshIndicatorKey.currentState?.show();
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refreshData,
            color: appYellow,
            backgroundColor: Colors.white,
            strokeWidth: 2.5,
            displacement: 40,
            edgeOffset: 0,
            child: Container(
              color: Colors.grey[50],
              child: Column(
                children: [
                  // _buildSummaryCard(walletProvider.transactions),
                  _buildFilterChips(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildTransactionList(walletProvider, filteredTransactions),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}