import 'package:flutter/material.dart';

class Bar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
        title:const Text("ማኅበረ ቅዱሳን ቴቪ"),
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
        ]);
  }
}


