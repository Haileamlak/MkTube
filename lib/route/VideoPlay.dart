import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:mk_tv_app/model/videoPlayModel.dart';
import 'package:provider/provider.dart';

class VideoPlay extends StatelessWidget {
  final videoInformation;
  const VideoPlay({super.key, this.videoInformation});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VideoPlayModel>(
      create: (context) => VideoPlayModel(videoInfo: videoInformation),
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<VideoPlayModel>(
              builder: (context, value, child) => value.canPlay
                  ? const Icon(Icons.ondemand_video)
                  : const Text("Loading...")),
          // backgroundColor: Colors.blue,
          foregroundColor: Colors.amber,
        ),
        body: const Column(
          children: [
            Video(),
            VideoFullInfo(),
          ],
        ),
      ),
    );
  }
}

class Video extends StatelessWidget {
  const Video({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoPlayModel>(builder: (context, value, child) {
      return !value.canPlay
          ? const AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(
                  child: CircularProgressIndicator(
                color: Colors.white,
                backgroundColor: Colors.amber,
              )))
          : AspectRatio(
              aspectRatio: value.customController.aspectRatio ?? 16 / 9,
              child: Chewie(controller: value.customController));
    });
  }
}

class VideoFullInfo extends StatelessWidget {
  const VideoFullInfo({super.key});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: const [
          FullVideoTitle(),
          FullVideoCategory(),
          SizedBox(
            height: 50,
            child: Center(child: VideoActionButtons()),
          ),
          VideoDescription(),
          Divider(),
          // Divider(),
        ],
      ),
    );
  }
}

class FullVideoTitle extends StatelessWidget {
  const FullVideoTitle({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<VideoPlayModel>(
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Text(
          value.videoInfo.title ?? "",
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 16, height: 1),
        ),
      ),
    );
  }
}

class VideoDescription extends StatelessWidget {
  const VideoDescription({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<VideoPlayModel>(
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Text(
          value.videoInfo.description ?? "",
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 16, height: 1),
        ),
      ),
    );
  }
}

class VideoActionButtons extends StatelessWidget {
  const VideoActionButtons({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: ElevatedButton.icon(
              label: const Text("watch later"),
              onPressed: () {},
              icon: const Icon(Icons.watch_later_outlined)),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: ElevatedButton.icon(
              label: const Text("share"),
              onPressed: () {},
              icon: const Icon(Icons.share)),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: ElevatedButton.icon(
              label: const Text("download"),
              onPressed: () {},
              icon: const Icon(Icons.download_rounded)),
        ),
      ],
    );
  }
}

class FullVideoCategory extends StatelessWidget {
  const FullVideoCategory({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<VideoPlayModel>(
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.only(left: 20, top: 5, bottom: 5),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "${value.videoInfo.programName ?? ""} - ${value.videoInfo.releaseDate?.day}/${value.videoInfo.releaseDate?.month}/${value.videoInfo.releaseDate?.year}",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
          ),
        ),
      ),
    );
  }
}
