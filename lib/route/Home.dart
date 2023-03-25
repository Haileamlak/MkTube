import 'package:flutter/material.dart';
import 'package:mk_tv_app/route/VideoPlay.dart';
import 'package:mk_tv_app/routes.dart';
import 'package:mk_tv_app/widget/Bar.dart';

class Home extends StatelessWidget {
  const Home();
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        Bar(),
        SliverList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return Column(
              children: [
                Thumbnail(index + 1),
                const VideoInfo(),
                const Divider(height: 1)
              ],
            );
          }, childCount: 6),
        )
      ],
    );
  }
}

class Thumbnail extends StatelessWidget {
  final index;
  const Thumbnail(this.index);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(RouteGenerator.videoPage);
      },
      child: Image(
          fit: BoxFit.contain, image: AssetImage("lib/myassets/img$index.jpg")),
    );
  }
}

class VideoInfo extends StatelessWidget {
  const VideoInfo();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [VideoDescription(), VideoProgramAndActions()],
    );
  }
}

class VideoDescription extends StatelessWidget {
  const VideoDescription();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 5),
      child: Text(
        "Install Kali Linux 2020.2 in Dual Boot with Windows 10 - Ultimate step by step guide",
        style: TextStyle(fontSize: 16, height: 1),
        maxLines: 2,
      ),
    );
  }
}

class VideoProgramAndActions extends StatelessWidget {
  const VideoProgramAndActions();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const VideoProgram(),
        ButtonBar(
          children: [
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.watch_later_outlined)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.download))
          ],
        )
      ],
    );
  }
}

class VideoProgram extends StatelessWidget {
  const VideoProgram();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Tsebel Tsedik",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
        ),
      ),
    );
  }
}
