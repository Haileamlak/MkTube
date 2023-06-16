import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:mk_tv_app/model/VideoInformation.dart';
import 'package:video_player/video_player.dart';

class VideoPlayModel with ChangeNotifier {
  final VideoInformation videoInfo;

  late VideoPlayerController controller;
  late ChewieController customController;

  bool canPlay = false;

  VideoPlayModel({required this.videoInfo}) {
    initialize();
  }
  void initialize() async {
    controller = VideoPlayerController.network(videoInfo.videoUrl ?? "");
    controller.initialize().then((value) {
      customController = ChewieController(
          videoPlayerController: controller, autoPlay: true, looping: false);
      controller.play();
      canPlay = true;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    customController.dispose();
    super.dispose();
  }
}
