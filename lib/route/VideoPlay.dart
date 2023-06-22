import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:mk_tv_app/model/VideoInformation.dart';
import 'package:mk_tv_app/model/libraryModel.dart';
import 'package:mk_tv_app/model/videoPlayModel.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoPlay extends StatelessWidget {
  final videoInformation;
  const VideoPlay({super.key, this.videoInformation});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VideoPlayModel>(
      create: (context) => VideoPlayModel(videoInfo: videoInformation!),
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<VideoPlayModel>(
              builder: (context, value, child) => value.canPlay
                  ? TextButton.icon(
                      icon: const Icon(Icons.ondemand_video),
                      onPressed: null,
                      label: const Text("Playing..."),
                    )
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
          Divider(),
          SizedBox(
            height: 50,
            child: Center(child: VideoActionButtons()),
          ),
          VideoDescription(),
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
    return Consumer2<VideoPlayModel, LibraryModel>(
      builder: (context, value, value2, child) => ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton.icon(
                label: const Text("Watch later"),
                onPressed: () async {
                  SharedPreferences getprefs =
                      await SharedPreferences.getInstance();

                  bool Unsaved =
                      false; //used to check whether the operation is unsaving or saving

                  var listOfSaved = getprefs.getStringList("saved");

                  final videoKey = value.videoInfo.key ?? "";
                  if (listOfSaved != null) {
                    if (listOfSaved.contains(videoKey)) {
                      listOfSaved.remove(videoKey);
                      Unsaved = true;
                    } else {
                      listOfSaved.add(videoKey);
                    }
                  } else {
                    listOfSaved = [videoKey];
                  }

                  final isSaved =
                      await getprefs.setStringList("saved", listOfSaved);
                  if (isSaved) {
                    if (Unsaved) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Video Unsaved Successfully!")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Video Saved Successfully!")));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Video Saving Failed!")));
                  }
                },
                icon: const Icon(Icons.watch_later_outlined)),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton.icon(
                label: const Text("Share"),
                onPressed: () async {
                  final downloadUrl = value.videoInfo.videoUrl;

                  await Share.share('Checkout this video: $downloadUrl');
                },
                icon: const Icon(Icons.share)),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton.icon(
                label: const Text("Download"),
                onPressed: () async {
                  final isDownloaded = (await SharedPreferences.getInstance())
                      .containsKey(value.videoInfo.key ?? "");
                  if (isDownloaded) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Video Already Downloaded!")));
                  } else {
                    value2.download(videoInfo: value.videoInfo);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Video Downloading Started!")));
                  }
                },
                icon: const Icon(Icons.download_rounded)),
          ),
        ],
      ),
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
