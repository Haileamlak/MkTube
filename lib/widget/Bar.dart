import 'package:flutter/material.dart';
import 'package:mk_tv_app/model/videoListModel.dart';
import 'package:provider/provider.dart';

class Bar extends StatelessWidget {
  final title;
  const Bar({super.key, this.title});
  @override
  Widget build(BuildContext context) {
    return Consumer<VideoListModel>(
      builder: (context, value2, child) => SliverAppBar(
          title: Row(
            children: [
              const Image(
                height: 32,
                image: AssetImage("lib/myassets/mktube.png"),
              ),
              Text(title),
            ],
          ),
          foregroundColor: Colors.lightBlue,
          // backgroundColor: Colors.blue,

          floating: true,
          stretch: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search',
              onPressed: () {},
            ),
          ]),
    );
  }
}


