import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mk_tv_app/model/libraryModel.dart';
import 'package:provider/provider.dart';

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
                return Dismissible(
                  onDismissed: (direction) async {
                    if (await value.cancelDownload(index)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Download Cancelled!")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text("Something Went Wrong while Cancelling!")));
                    }
                  },
                  key: ValueKey(index),
                  background: Container(color: Colors.red,),
                  child: Card(
                    margin: const EdgeInsets.all(5),
                    child: ListTile(
                      textColor: Colors.green,
                      leading: progress == 1
                          ? const Icon(Icons.video_file)
                          : CircularProgressIndicator(value: progress),
                      title: Text(
                        value.downloading[index].title ?? "No Title",
                        maxLines: 1,
                      ),
                      subtitle: Text(
                        value.downloading[index].description ??
                            "No Description",
                        maxLines: 1,
                      ),
                      trailing:
                          downloadActionButton(value.downloadProgresses[index]),
                    ),
                  ),
                );
              },
              itemCount: value.downloading.length,
            );
          } else {
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

  Widget downloadActionButton(DownloadTask task) {
    switch (task.snapshot.state) {
      case TaskState.paused:
        return Consumer<LibraryModel>(
          builder: (context, value, child) => IconButton(
            onPressed: () {
              task.resume();
              value.notify();
            },
            icon: const Icon(Icons.play_circle_outlined),
          ),
        );
      case TaskState.running:
        return Consumer<LibraryModel>(
          builder: (context, value, child) => IconButton(
            onPressed: () {
              task.pause();
              value.notify();
            },
            icon: const Icon(Icons.pause),
          ),
        );
      case TaskState.success:
        return const IconButton(
          onPressed: null,
          icon: Icon(Icons.done),
        );
      case TaskState.canceled:
        return Consumer<LibraryModel>(
          builder: (context, value, child) => IconButton(
            onPressed: () {
              task.cancel();
              value.notify();
            },
            icon: const Icon(Icons.file_download_off),
          ),
        );
      case TaskState.error:
      default:
        return IconButton(
          onPressed: () {
            task.ignore();
          },
          icon: const Icon(Icons.error),
        );
    }
  }
}
