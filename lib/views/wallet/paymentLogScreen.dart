import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:AstrowayCustomer/theme/appTheme.dart';

class PaymentLogScreen extends StatefulWidget {
  @override
  _PaymentLogScreenState createState() => _PaymentLogScreenState();
}

class _PaymentLogScreenState extends State<PaymentLogScreen> {
  // Temporary list of payment logs (replace with API data later)
  final List<PaymentLog> _paymentLogs = [
    PaymentLog(
      id: '1',
      amount: 500,
      type: 'credit',
      description: 'Wallet Recharge',
      date: DateTime.now().subtract(Duration(hours: 2)),
      status: 'success',
    ),
    PaymentLog(
      id: '2',
      amount: 300,
      type: 'debit',
      description: 'Astrology Consultation',
      date: DateTime.now().subtract(Duration(days: 1)),
      status: 'success',
    ),
    PaymentLog(
      id: '3',
      amount: 1000,
      type: 'credit',
      description: 'Wallet Recharge',
      date: DateTime.now().subtract(Duration(days: 2)),
      status: 'success',
    ),
    PaymentLog(
      id: '4',
      amount: 200,
      type: 'debit',
      description: 'Horoscope Report',
      date: DateTime.now().subtract(Duration(days: 3)),
      status: 'success',
    ),
    PaymentLog(
      id: '5',
      amount: 100,
      type: 'debit',
      description: 'Chat with Astrologer',
      date: DateTime.now().subtract(Duration(days: 4)),
      status: 'failed',
    ),
    PaymentLog(
      id: '6',
      amount: 1500,
      type: 'credit',
      description: 'Referral Bonus',
      date: DateTime.now().subtract(Duration(days: 5)),
      status: 'success',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            // Summary Card
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        "Total Credits",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "₹${_getTotalCredits()}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Total Debits",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "₹${_getTotalDebits()}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Transaction List
            Expanded(
              child: ListView.builder(
                itemCount: _paymentLogs.length,
                itemBuilder: (context, index) {
                  final log = _paymentLogs[index];
                  return _buildTransactionCard(log);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(PaymentLog log) {
    final isCredit = log.type == 'credit';
    final icon = isCredit ? Icons.add : Icons.remove;
    final color = isCredit ? Colors.green : Colors.red;
    final statusColor = log.status == 'success' ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          log.description,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          DateFormat('dd MMM yyyy, hh:mm a').format(log.date),
          style: TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isCredit ? "+₹${log.amount}" : "-₹${log.amount}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                log.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTotalCredits() {
    double total = 0;
    for (var log in _paymentLogs) {
      if (log.type == 'credit' && log.status == 'success') {
        total += log.amount;
      }
    }
    return total.toStringAsFixed(0);
  }

  String _getTotalDebits() {
    double total = 0;
    for (var log in _paymentLogs) {
      if (log.type == 'debit' && log.status == 'success') {
        total += log.amount;
      }
    }
    return total.toStringAsFixed(0);
  }
}

class PaymentLog {
  final String id;
  final double amount;
  final String type; // 'credit' or 'debit'
  final String description;
  final DateTime date;
  final String status; // 'success' or 'failed'

  PaymentLog({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    required this.status,
  });
}
