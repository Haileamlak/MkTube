import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mk_tv_app/model/SettingModel.dart';
import 'package:mk_tv_app/model/libraryModel.dart';
import 'package:mk_tv_app/model/videoListModel.dart';
import 'package:mk_tv_app/route/VideoPlay.dart';
import 'package:mk_tv_app/widget/Bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer2<VideoListModel, SettingModel>(
        builder: (context, value, value2, child) {
      return CustomScrollView(
        slivers: [
          const Bar(title: "MK Tube"),
          if (value.listOfVideos.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Video(index);
                },
                childCount: value.listOfVideos.length,
              ),
            )
          else if (value2.connectionStatus == ConnectivityResult.none)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, int index) {
                  return const Column(
                    children: [
                      Padding(padding: EdgeInsets.all(30)),
                      Center(
                        child: Stack(
                          children: [
                            Icon(Icons.error),
                            Image(
                              color: Colors.grey,
                              image: AssetImage("lib/myassets/mklogo.png"),
                              width: 100,
                            ),
                          ],
                        ),
                      ),
                      Center(child: Text("Something Went Wrong!"))
                    ],
                  );
                },
                childCount: 1,
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return const SizedBox(
                      height: 500,
                      child:
                          Center(child: CircularProgressIndicator.adaptive()));
                },
                childCount: 1,
              ),
            )
        ],
      );
    });
  }
}

class Video extends StatelessWidget {
  final index;
  const Video(this.index, {super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<VideoListModel>(builder: (context, value, child) {
      if (value.listOfVideos.length > index) {
        // index = index;
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => VideoPlay(
                        videoInformation: value.listOfVideos[index])));
              },
              child: CachedNetworkImage(
                imageUrl: value.listOfVideos[index]?.thumbnailUrl ?? "",
                errorWidget: (context, url, error) =>
                    const SizedBox(height: 200, child: Icon(Icons.error)),
                placeholder: (context, url) => const SizedBox(
                    height: 200, child: CupertinoActivityIndicator()),
              ),
            ),
            VideoInfo(index: index),
            const Divider(height: 1)
          ],
        );
      }
      // else if (value.listOfVideos.length == index) {
      //   value.getListOfVideos(
      //       startAfter: value.listOfVideos[index]?.key);
      //   return const SizedBox(height: 100, child: CircularProgressIndicator());
      // }
      else {
        return const SizedBox(height: 200, child: CupertinoActivityIndicator());
      }
    });
  }
}

class VideoInfo extends StatelessWidget {
  final index;
  const VideoInfo({super.key, this.index});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Consumer<VideoListModel>(
              builder: (_, value, __) => GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VideoPlay(
                        videoInformation: value.listOfVideos[index],
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    VideoTitle(
                      index: index,
                    ),
                    VideoCategory(index: index),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: VideoMoreActionButton(
              index: index,
            ),
          )
        ],
      ),
    );
  }
}

class VideoTitle extends StatelessWidget {
  final index;
  const VideoTitle({super.key, this.index});
  @override
  Widget build(BuildContext context) {
    return Consumer<VideoListModel>(
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "${value.listOfVideos[index]?.title ?? ""} ",
            style: const TextStyle(fontSize: 16, height: 1),
            maxLines: 2,
          ),
        ),
      ),
    );
  }
}

class VideoCategory extends StatelessWidget {
  final index;
  const VideoCategory({super.key, this.index});
  @override
  Widget build(BuildContext context) {
    return Consumer<VideoListModel>(
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "${value.listOfVideos[index]?.programName ?? ""} - ${getReleaseDurationFormatted(value.listOfVideos[index]?.releaseDate ?? DateTime.now())}",
            maxLines: 1,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
          ),
        ),
      ),
    );
  }

  String getReleaseDurationFormatted(DateTime dt) {
    final now = DateTime.now();
    if (now.year - dt.year > 0) {
      return "${now.year - dt.year} ${now.year - dt.year == 1 ? "year ago" : "years ago"}";
    }
    if (now.month - dt.month > 0) {
      return "${now.month - dt.month} ${now.month - dt.month == 1 ? "month ago" : "months ago"}";
    }
    if (now.day - dt.day > 0) {
      if (now.day - dt.day >= 7) {
        return "${(now.day - dt.day) ~/ 7} ${(now.day - dt.day) ~/ 7 == 1 ? "week ago" : "weeks ago"}";
      }
      return "${now.day - dt.day} ${now.day - dt.day == 1 ? "day ago" : "days ago"}";
    }
    return "${now.minute - dt.minute} ${now.minute - dt.minute == 1 ? "minute ago" : "minutes ago"}";
  }
}

class VideoMoreActionButton extends StatelessWidget {
  final index;
  const VideoMoreActionButton({super.key, this.index});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          // Future<void> _showMyDialog() async {
          await showDialog<void>(
            context: context,
            barrierDismissible: true, // user must tap button!
            builder: (BuildContext context) {
              return Consumer2<VideoListModel, LibraryModel>(
                builder: (context, value, value2, child) {
                  return SimpleDialog(
                    // title: const Text('AlertDialog Title'),
                    children: [
                      TextButton.icon(
                        label: const Text("Save to Watch Later"),
                        onPressed: () async {
                          SharedPreferences getprefs =
                              await SharedPreferences.getInstance();

                          bool Unsaved =
                              false; //used to check whether the operation is unsaving or saving

                          var listOfSaved = getprefs.getStringList("saved");

                          final videoKey = value.listOfVideos[index]?.key ?? "";
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

                          final saveSuccessfull = await getprefs.setStringList(
                              "saved", listOfSaved);
                          if (saveSuccessfull) {
                            if (Unsaved) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Video Unsaved Successfully!")));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Video Saved Successfully!")));
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Video Saving Failed!")));
                          }
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.watch_later_outlined),
                      ),
                      TextButton.icon(
                          label: const Text("Download"),
                          onPressed: () async {
                            final isDownloaded = (await SharedPreferences.getInstance())
                                .containsKey(
                                    value.listOfVideos[index]!.key ?? "");
                            if (isDownloaded) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Video Already Downloaded!")));
                            } else {
                              value2.download(
                                  videoInfo: value.listOfVideos[index]!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Video Downloading Started!")));
                            }
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.download_rounded)),
                      TextButton.icon(
                          label: const Text("Share"),
                          onPressed: () async {
                            final downloadUrl =
                                value.listOfVideos[index]!.videoUrl;

                            await Share.share(
                                'Checkout this video: $downloadUrl');
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.share)),
                    ],
                  );
                },
              );
            },
          );
        },
        icon: const Icon(Icons.more_vert));
  }
}
