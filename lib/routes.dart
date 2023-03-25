import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mk_tv_app/main.dart';
import 'package:mk_tv_app/route/VideoPlay.dart';

class RouteGenerator {
  static const homePage = '/';
  static const videoPage = '/video';

  RouteGenerator._();
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homePage:
        return MaterialPageRoute(
          builder: (_) => const MyHomePage(title: "ማኅበረ ቅዱሳን ቴቪ"),
        );
      case videoPage:
        return CupertinoPageRoute(
          builder: (_) => const VideoPlay(),
        );
      default:
        throw const RouteException("Route not found");
    }
  }
}

class RouteException implements Exception {
  final String message;
  const RouteException(this.message);
}
