import 'package:flutter/material.dart';
import '../../theme/appTheme.dart';
import 'numerology_screen.dart';
import 'daily_horoscope_screen.dart';

class NumerologyAndHoroscopeScreen extends StatelessWidget {
  const NumerologyAndHoroscopeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildServiceCard(
              context,
              title: 'Numerology',
              icon: Icons.numbers ,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NumerologyScreen()),
                );
              },
            ),
            const SizedBox(height: 30),
            _buildServiceCard(
              context,
              title: 'Daily Horoscope',
              icon: Icons.auto_awesome,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>  DailyHoroscopeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context,
      {required String title,
        required IconData icon,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16) , side: BorderSide(color: appYellow)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 36, color: appYellow),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
