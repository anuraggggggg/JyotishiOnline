// ignore_for_file: must_be_immutable

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';


class CoHostWidget extends StatelessWidget {
   CoHostWidget({
    super.key,
    required this.remoteUid,
    required this.agoraEngine,
    required this.channelId,
  });

  final int? remoteUid;
  final RtcEngine agoraEngine;
  String channelId;

  @override
  Widget build(BuildContext context) {
    if (remoteUid != null) {
      debugPrint('remote id from _videoPanelForCoHost:- $remoteUid');
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: remoteUid), //Remote User ID placed here
          connection: RtcConnection(channelId: channelId),
        ),
      );
    } else {
      return const Align(
        alignment: Alignment.bottomCenter,
        child: Text(
          'Astrologer not  join..,',
          style: TextStyle(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}
