import 'package:flutter/material.dart';
import 'package:mk_tv_app/model/libraryModel.dart';
import 'package:provider/provider.dart';

class Downloaded extends StatelessWidget {
  const Downloaded({super.key});

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
            Text("Downloads"),
          ],
        ),
        foregroundColor: Colors.lightBlue,
      ),
      body: Consumer<LibraryModel>(builder: (context, value, child) {
        if (value.downloaded.isNotEmpty) {
          return ListView.builder(
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        flex: 1,
                        child: PlaceHolderThumbnail(),
                      ),
                      Expanded(
                        flex: 2,
                        child: LocalVideoInfo(index: index),
                      ),
                      Expanded(
                        flex: 0,
                        child: LocalVideoActions(index: index),
                      ),
                    ],
                  ),
                );
              },
              itemCount: value.downloaded.length);
        } else if (value.noDownloads) {
          return const Column(
            children: [
              Padding(padding: EdgeInsets.all(30)),
              Center(
                  child: Image(
                color: Colors.grey,
                image: AssetImage("lib/myassets/mklogo.png"),
                width: 100,
              )),
              Center(child: Text("No Downloads to watch!"))
            ],
          );
        } else {
          return const SizedBox(
            height: 500,
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
      }),
    );
  }
}

class LocalVideoInfo extends StatelessWidget {
  final index;
  const LocalVideoInfo({super.key, this.index});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LocalVideoTitle(
          index: index,
        ),
        LocalVideoCategory(index: index)
      ],
    );
  }
}

class LocalVideoTitle extends StatelessWidget {
  final index;
  const LocalVideoTitle({super.key, this.index});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Consumer<LibraryModel>(
        builder: (context, value, child) => Text(
          value.downloaded[index]["title"],
          style: const TextStyle(
              fontSize: 15, height: 1, fontWeight: FontWeight.w400),
          maxLines: 4,
        ),
      ),
    );
  }
}

class LocalVideoCategory extends StatelessWidget {
  final index;
  const LocalVideoCategory({super.key, this.index});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Consumer<LibraryModel>(
        builder: (context, value, child) => Text(
          value.downloaded[index]["programName"],
          style: const TextStyle(
              fontSize: 15, height: 1, fontWeight: FontWeight.w400),
          maxLines: 4,
        ),
      ),
    );
  }
}

class LocalVideoActions extends StatelessWidget {
  final index;
  const LocalVideoActions({super.key, this.index});
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topCenter,
        child: IconButton(
            onPressed: () {},
            color: Colors.amber,
            icon: const Icon(
              Icons.more_vert,
              size: 20,
              opticalSize: 20,
            )));
  }
}

class PlaceHolderThumbnail extends StatelessWidget {
  const PlaceHolderThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    return const Image(
      image: AssetImage("lib/myassets/mklogo.png"),
      height: 50,
    );
  }
}
