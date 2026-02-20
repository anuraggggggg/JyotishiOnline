import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bottomNavigationController.dart';

class MiniSessionOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomNavigationController>(
      builder: (c) {
        if (!c.isSessionActive || !c.isMiniVisible) {
          return const SizedBox();
        }

        return Positioned(
          bottom: 100,
          right: 16,
          child: GestureDetector(
            onTap: () {
              c.openSession();

              if (c.sessionType == "chat") {
                Get.toNamed("/chat");
              } else if (c.sessionType == "audio") {
                Get.toNamed("/audioCall");
              } else {
                Get.toNamed("/videoCall");
              }
            },
            child: Container(
              width: 140,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10)
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    c.sessionType == "chat"
                        ? Icons.chat
                        : c.sessionType == "audio"
                        ? Icons.call
                        : Icons.videocam,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.sessionAstrologerName,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
