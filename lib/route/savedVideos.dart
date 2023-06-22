import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mk_tv_app/model/SavedModel.dart';
import 'package:mk_tv_app/model/libraryModel.dart';
import 'package:mk_tv_app/route/VideoPlay.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedVideos extends StatelessWidget {
  const SavedVideos({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SavedModel>(
      create: (context) => SavedModel(),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.lightBlue,
          title: const Row(
            children: [
              Image(
                height: 32,
                image: AssetImage("lib/myassets/mktube.png"),
              ),
              Text("Saved"),
            ],
          ),
        ),
        body: Consumer<SavedModel>(
          builder: (context, value, child) {
            if (value.savedVideos.isNotEmpty) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  return SavedVideo(index: index);
                },
                itemCount: value.savedVideos.length,
              );
            } else if (value.noSaved) {
              return const Column(
                children: [
                  Padding(padding: EdgeInsets.all(10)),
                  Center(
                      child: Image(
                    color: Colors.grey,
                    image: AssetImage("lib/myassets/mklogo.png"),
                    width: 100,
                  )),
                  Center(child: Text("No Saved Videos to watch!"))
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
          },
        ),
      ),
    );
  }
}

class SavedVideo extends StatelessWidget {
  final index;

  const SavedVideo({super.key, this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer<SavedModel>(
      builder: (context, value, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => VideoPlay(
                            videoInformation: value.savedVideos[index])));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      height: 100,
                      imageUrl: value.savedVideos[index].thumbnailUrl ?? "",
                      errorWidget: (context, url, error) =>
                          const SizedBox(height: 100, child: Icon(Icons.error)),
                      placeholder: (context, url) => const SizedBox(
                          height: 100, child: CupertinoActivityIndicator()),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => VideoPlay(
                            videoInformation: value.savedVideos[index])));
                  },
                  child: Column(
                    children: [
                      Text(
                        value.savedVideos[index].title ?? "",
                        maxLines: 3,
                        textAlign: TextAlign.left,
                      ),
                      Text(value.savedVideos[index].programName ?? "")
                    ],
                  ),
                ),
              ),
              Expanded(
                  flex: 0,
                  child: SavedMoreActionButton(
                    index: index,
                  ))
            ],
          ),
        );
      },
    );
  }
}

class SavedMoreActionButton extends StatelessWidget {
  final index;
  const SavedMoreActionButton({super.key, this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SavedModel, LibraryModel>(
      builder: (context, value, value2, child) {
        return IconButton(
            onPressed: () async {
              // Future<void> _showMyDialog() async {
              await showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    children: [
                      TextButton.icon(
                        label: const Text("Remove from Watch Later"),
                        onPressed: () async {
                          bool unsaveSuccessfull = await value.Unsave(index);
                          if (unsaveSuccessfull) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Video Unsaved Successfully!")));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Video Unsaving Failed!")));
                          }
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.watch_later),
                      ),
                      TextButton.icon(
                          label: const Text("Download"),
                          onPressed: () async {
                            final isDownloaded =
                                (await SharedPreferences.getInstance())
                                    .containsKey(
                                        value.savedVideos[index].key ?? "");
                            if (isDownloaded) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Video Already Downloaded!")));
                            } else {
                              value2.download(
                                  videoInfo: value.savedVideos[index]);
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
                          onPressed:
                              // () async {
                              //   // final downloadUrl =
                              //       // value.listOfVideos[index]!.videoUrl;

                              //   await Share.share(
                              //       'Download this video: downloadUrl');
                              //   Navigator.pop(context);
                              // },
                              () async {
                            final downloadUrl =
                                value.savedVideos[index].videoUrl;

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
            icon: const Icon(Icons.more_vert));
      },
    );
  }
}
