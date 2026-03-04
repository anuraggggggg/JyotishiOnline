import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controllers/splashController.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    // ✅ Create SplashController (ONLY ONCE)
    Get.put(SplashController());

    // ✅ Initialize splash video
    _videoController = VideoPlayerController.asset(
      'assets/videos/splash_video.mp4',
    )
      ..initialize().then((_) {
        setState(() {});
        _videoController
          ..setVolume(0) // mute splash video
          ..play();
      });

    _videoController.setLooping(false);
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _videoController.value.isInitialized
          ? Stack(
        fit: StackFit.expand,
        children: [
          // Video player with proper aspect ratio handling
          AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: VideoPlayer(_videoController),
          ),
          // Optional: Add a color overlay if needed
          // Container(color: Colors.black.withOpacity(0.3)),
        ],
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}