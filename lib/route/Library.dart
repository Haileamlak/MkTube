import 'package:flutter/material.dart';
import 'package:mk_tv_app/route/Home.dart';

class Library extends StatelessWidget {
  const Library();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
            title: const Text("የእርስዎ"),
            foregroundColor: Colors.amber,
            backgroundColor: Colors.blue,
            floating: true,
            stretch: true,
            actions: <Widget>[
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.search),
                tooltip: 'Search',
                onPressed: () {/* ... */},
              ),
            ]),
        SliverList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Thumbnail(index + 1),
                  ),
                  const Expanded(
                    child: LocalVideoInfo(),
                  ),
                  const LocalVideoActions(),
                ],
              ),
            );
          }, childCount: 6),
        )
      ],
    );
  }
}

class LocalVideoInfo extends StatelessWidget {
  const LocalVideoInfo();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [LocalVideoDescription(), VideoProgram()],
    );
  }
}

class LocalVideoDescription extends StatelessWidget {
  const LocalVideoDescription();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 10),
      child: Text(
        "Install Kali Linux 2020.2 in Dual Boot with Windows 10 - Ultimate step by step guide",
        style: TextStyle(fontSize: 15, height: 1,fontWeight: FontWeight.w400),
        maxLines: 4,
      ),
    );
  }
}

class LocalVideoActions extends StatelessWidget {
  const LocalVideoActions();
  @override
  Widget build(BuildContext context) {
    return  Align(alignment: Alignment.topCenter, child: IconButton(onPressed: () {},color: Colors.amber, icon: Icon(Icons.delete,size: 20,opticalSize: 20,)));
  }
}
