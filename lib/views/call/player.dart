import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lecle_yoyo_player/lecle_yoyo_player.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../controllers/history_controller.dart';

// ignore: must_be_immutable
class Player extends StatefulWidget {
  String sid;
  Player({super.key,required this.sid});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final historyController = Get.find<HistoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player'),
      ),
      backgroundColor: Colors.grey.shade300,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                ),
                alignment: Alignment.center,
                child: YoYoPlayer(
                  onPlayingVideo: (videoType) {
                    //  print(videoType);
                  },
                  onShowMenu: (showMenu, m3u8Show) {
                    print(showMenu);
                    print("audio link");
                    print('https://s3-ap-south-1.amazonaws.com/astroway/${widget.sid}_${historyController.callHistoryListById[0].channelName}.m3u8');

                  },
                  autoPlayVideoAfterInit: true,
                  aspectRatio: 16 / 9,
                  url:
                  "https://s3-ap-south-1.amazonaws.com/astroway/${widget.sid}_${historyController.callHistoryListById[0].channelName}.m3u8",
                  videoStyle: VideoStyle(
                      fullScreenIconSize: 1,
                      fullScreenIconColor: Colors.black,
                      enableSystemOrientationsOverride: false,
                      videoQualityBgColor: Colors.black,

                      qualityStyle: TextStyle(
                        fontSize: 1.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      forwardAndBackwardBtSize: 30.0,
                      playButtonIconSize: 40.0,
                      playIcon: Icon(
                        Icons.play_arrow,
                        size: 40.0,
                        color: Colors.white,
                      ),
                      pauseIcon: Icon(
                        Icons.pause,
                        size: 40.0,
                        color: Colors.white,
                      ),
                      videoQualityPadding: EdgeInsets.all(5.0),
                      allowScrubbing: true),
                  videoLoadingStyle: VideoLoadingStyle(
                    indicatorInitialValue: 0.0,
                    loading: Center(
                      child: Text(
                        "Loading video",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  allowCacheFile: true,
                  onCacheFileCompleted: (files) {
                    print('Cached file length ::: ${files?.length}');

                    if (files != null && files.isNotEmpty) {
                      for (var file in files) {
                        print('File path ::: ${file.path}');
                      }
                    }
                  },
                  onCacheFileFailed: (error) {
                    print('Cache file error ::: $error');
                  },
                ),
              ),
              Positioned(
                  child: Icon(Icons.music_video,color: Colors.white,
                    size: 30.sp,))
            ],
          ),
        ],
      ),
    );
  }
}
