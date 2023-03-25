import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mk_tv_app/route/Home.dart';

class VideoPlay extends StatelessWidget {
  const VideoPlay();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video detail"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.amber,
      ),
      body: ListView(
        children: const [
          Video(),
          VideoInfo(),
          // VideoActions(),
        ],
      ),
    );
  }
}

class Video extends StatefulWidget {
  const Video();

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  late FirebaseStorage storage;
  late VideoPlayerController controller;
  late CustomVideoPlayerController customController;
  late Future<String> url;
  @override
  void initState() {
    super.initState();
    storage = FirebaseStorage.instance;
    url = storage.ref().child("videos").child("intro1.mp4").getDownloadURL();

    url.then((value) {
      print(value);
      print(value);
      print(value);
      print(value);
      print(value);
      print(value);
      controller = VideoPlayerController.network(value);
      controller.initialize().then((value) {
        setState(() {});
      });
    });
    controller = VideoPlayerController.asset("lib/myassets/geezm.mp4");
    controller.initialize().then((value) => {setState(() {})});
    customController = CustomVideoPlayerController(
        context: context, videoPlayerController: controller);

    // setState(() {})
  }

  @override
  void dispose() {
    customController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized)
      return Container(
          height: 300, child: Center(child: CircularProgressIndicator()));
    return Container(
      child: CustomVideoPlayer(customVideoPlayerController: customController),
    );
  }
}
