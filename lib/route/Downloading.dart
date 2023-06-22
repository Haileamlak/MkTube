import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mk_tv_app/model/libraryModel.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Downloading extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  //
  Downloading({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Image(
              height: 32,
              image: AssetImage("lib/myassets/mktube.png"),
            ),
            Text("Downloading"),
          ],
        ),
        foregroundColor: Colors.lightBlue,
      ),
      body: Consumer<LibraryModel>(
        builder: (context, value, child) {
          //if there are downloading videos
          if (value.downloading.isNotEmpty) {
            return ListView.builder(
              itemBuilder: (context, index) {
                final progress =
                    value.downloadProgresses[index].snapshot.bytesTransferred /
                        value.downloadProgresses[index].snapshot.totalBytes;
                return Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                          child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl:
                                  value.downloading[index].thumbnailUrl ?? "",
                              height: 100,
                              placeholder: (context, url) =>
                                  const Center(child: Icon(Icons.video_file)),
                            ),
                          ),
                          
                          progress == 1
                              ? const Icon(
                                  Icons.done,
                                  color: Colors.green,
                                  size: 50,
                                )
                              : Container(
                                  padding:
                                      const EdgeInsets.only(top: 15, left: 16),
                                  child: CircularProgressIndicator(strokeWidth: 10,
                                      color: Colors.lightBlue, value: progress),
                                ),if (progress != 1)
                            IconButton(
                                color: Colors.red,
                                onPressed: () {
                                  value.cancelDownload(index);
                                },
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  size: 50,
                                )),
                        ],
                      )),
                      Expanded(
                        child: Text(
                          '${value.downloading[index].title ?? "No Title"}\n${value.downloading[index].programName ?? ""}',
                          maxLines: 4,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: IconButton(
                          icon: getIcon(value.downloadProgresses[index]),
                          onPressed: () {
                            switch (value
                                .downloadProgresses[index].snapshot.state) {
                              case TaskState.paused:
                                value.downloadProgresses[index].resume();
                                break;
                              case TaskState.running:
                                value.downloadProgresses[index].pause();
                                break;
                              case TaskState.success:
                              case TaskState.canceled:
                              case TaskState.error:
                              default:

                                value.downloading.removeAt(index);
                                value.downloadProgresses.removeAt(index);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: value.downloading.length,
            );
          } else {
            //whenever there are no videos downloaded
            return const Column(
              children: [
                Padding(padding: EdgeInsets.all(30)),
                Center(
                    child: Image(
                  color: Colors.grey,
                  image: AssetImage("lib/myassets/mklogo.png"),
                  width: 100,
                )),
                Center(child: Text("No videos are currently downloading!"))
              ],
            );
          }
        },
      ),
    );
  }

//helper function to return Icon based on the state
  Icon getIcon(DownloadTask task) {
    switch (task.snapshot.state) {
      case TaskState.paused:
        return const Icon(Icons.play_circle_outlined);
      case TaskState.running:
        return const Icon(Icons.pause);
      case TaskState.success:
        return const Icon(Icons.done);
      case TaskState.canceled:
        return const Icon(Icons.file_download_off);
      case TaskState.error:
      default:
        return const Icon(Icons.error);
    }
  }

//helper String to return Icon based on the state
  Text getString(DownloadTask task) {
    switch (task.snapshot.state) {
      case TaskState.paused:
        return const Text("Resume");
      case TaskState.running:
        return const Text("Pause");
      case TaskState.success:
        return const Text("Download Successful");
      case TaskState.canceled:
        return const Text("Cancelled");
      case TaskState.error:
      default:
        return const Text("Error");
    }
  }
}
