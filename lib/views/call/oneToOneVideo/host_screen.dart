import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

class HostWidget extends StatelessWidget {
  const HostWidget({
    super.key,
    required this.agoraEngine,
  });
  final RtcEngine agoraEngine;
  @override
  Widget build(BuildContext context) {
    // Local user joined as a host
    return SizedBox(
      height: 400,
      width: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: agoraEngine,
            canvas: const VideoCanvas(
              uid: 0,
            ),
          ),
        ),
      ),
    );
  }
}