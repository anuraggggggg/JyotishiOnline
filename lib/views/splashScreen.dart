import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splashController.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final SplashController controller = Get.put(SplashController());

    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Image.asset(
          'assets/images/splash3.gif', // ← Updated path
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

