import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewWidget extends StatefulWidget {

  final String videoPath;

  const VideoPreviewWidget({
    super.key,
    required this.videoPath,
  });

  @override
  State<VideoPreviewWidget> createState() =>
      _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState
    extends State<VideoPreviewWidget> {

  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller =
    VideoPlayerController.file(File(widget.videoPath),)
      ..initialize().then((_) {

        controller.setLooping(true);

        controller.play();

        setState(() {});
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (!controller.value.isInitialized) {

      return Container(
        color: Colors.black12,

        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,

        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
