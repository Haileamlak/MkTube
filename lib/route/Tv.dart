import 'package:flutter/material.dart';

class Tv extends StatelessWidget {
  const Tv();
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
            title:const Text("ቴለቪዥን"),
            foregroundColor: Colors.amber,
            backgroundColor: Colors.blue,
            floating: true,
            stretch: true,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search',
                onPressed: () {/* ... */},
              ),
            ]),
        SliverList(
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            return Container(
              color: index.isOdd ? Colors.white : Colors.red,
              height: 200.0,
              child: Center(
                child: Text('$index', textScaleFactor: 5),
              ),
            );
          }, childCount: 10),
        )
      ],
    );
  }
}
