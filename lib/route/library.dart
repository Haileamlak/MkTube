import 'package:flutter/material.dart';
import 'package:mk_tv_app/routes.dart';
import 'package:mk_tv_app/widget/MkDrawer.dart';

class Library extends StatelessWidget {
  const Library({super.key});

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
            Text("Library"),
          ],
        ),
        foregroundColor: Colors.lightBlue,
      ),
      drawer: const MkDrawer(),
      body: ListView(
        children: [
          // Padding(padding: EdgeInsets.all(30)),

          Card(
            child: ListTile(
              onTap: () {
                Navigator.pushNamed(context, RouteGenerator.downloaded);
              },
              leading: const Icon(Icons.video_file),
              title: const Text("Downloaded"),
              textColor: Colors.lightBlue,
            ),
          ),
          Card(
            child: ListTile(
              onTap: () {
                Navigator.pushNamed(context, RouteGenerator.savedVideos);
              },
              leading: const Icon(Icons.watch_later),
              title: const Text("Saved "),
              textColor: Colors.lightBlue,
            ),
          ),
          Card(
            child: ListTile(
              onTap: () {
                Navigator.pushNamed(context, RouteGenerator.downloading);
              },
              leading: const Icon(Icons.downloading),
              title: const Text("Downloading"),
              textColor: Colors.lightBlue,
            ),
          ),
          const Center(
              child: Image(
            // color: Colors.grey,
            image: AssetImage("lib/myassets/mklogo.png"),
            width: 100,
          )),
        ],
      ),
    );
  }
}
