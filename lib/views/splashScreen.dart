import 'package:AstrowayCustomer/fastApi/fastApiServices.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splashController.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  initState() {
    super.initState();
    FastAPIServices().checkLoginStatus();
  }

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
