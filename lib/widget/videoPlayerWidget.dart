import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoPlayerController controller;

  VideoPlayerWidget({required this.controller});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late bool _showPauseButton;

  @override
  void initState() {
    super.initState();
    _showPauseButton = true;

    widget.controller.addListener(() {
      if (widget.controller.value.isPlaying) {
        setState(() {
          _showPauseButton = false;
        });
      } else {
        setState(() {
          _showPauseButton = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Toggle play/pause when the player is tapped
        if (widget.controller.value.isPlaying) {
          widget.controller.pause();
        } else {
          widget.controller.play();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(widget.controller),
          if (_showPauseButton)
            PauseButtonOverlay(
              onPressed: () {
                if (widget.controller.value.isPlaying) {
                  widget.controller.pause();
                } else {
                  widget.controller.play();
                }
              },
            ),
        ],
      ),
    );
  }
}

class PauseButtonOverlay extends StatelessWidget {
  final VoidCallback onPressed;

  PauseButtonOverlay({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
      ),
      child: IconButton(
        icon: Icon(Icons.play_arrow, color: Colors.white, size: 30),
        onPressed: onPressed,
      ),
    );
  }
}
