import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mk_tv_app/model/SavedModel.dart';
import 'package:mk_tv_app/route/Home.dart';
import 'package:mk_tv_app/route/VideoPlay.dart';
import 'package:provider/provider.dart';

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
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => VideoPlay(
                          videoInformation: value.savedVideos[index])));
                },
                child: CachedNetworkImage(
                  imageUrl: value.savedVideos[index].thumbnailUrl ?? "",
                  errorWidget: (context, url, error) =>
                      const SizedBox(height: 100, child: Icon(Icons.error)),
                  placeholder: (context, url) => const SizedBox(
                      height: 200, child: CupertinoActivityIndicator()),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    value.savedVideos[index].title ?? "",
                    maxLines: 3,
                  ),
                  Text(value.savedVideos[index].programName ?? "")
                ],
              ),
            ),
            const Expanded(flex: 0, child: VideoMoreActionButton())
          ],
        );
      },
    );
  }
}
