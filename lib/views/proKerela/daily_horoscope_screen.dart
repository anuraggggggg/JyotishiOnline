// daily_horoscope_screen.dart
import 'package:flutter/material.dart';

class DailyHoroscopeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Horoscope'),
      ),
      body: Center(
        child: Text('Daily Horoscope Content here'),
      ),
    );
  }
}
