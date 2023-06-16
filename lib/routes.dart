import 'package:flutter/cupertino.dart';
import 'package:mk_tv_app/main.dart';
import 'package:mk_tv_app/route/Downloading.dart';
import 'package:mk_tv_app/route/Settings.dart';
import 'package:mk_tv_app/route/VideoPlay.dart';
import 'package:mk_tv_app/route/adminLive.dart';
import 'package:mk_tv_app/route/downloaded.dart';
import 'package:mk_tv_app/route/savedVideos.dart';

class RouteGenerator {
  static const homePage = '/';
  static const videoPage = '/video';
  static const settingsPage = '/settings';
  static const live = '/live';
  static const downloading = '/downloading';
  static const downloaded = '/downloaded';
  static const savedVideos = '/saved';

  RouteGenerator._();
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homePage:
        return CupertinoPageRoute(
          builder: (_) => const MyHomePage(title: "ማኅበረ ቅዱሳን ቴቪ"),
        );
      case videoPage:
        return CupertinoPageRoute(
          builder: (_) => const VideoPlay(),
        );
      case settingsPage:
        return CupertinoPageRoute(
          builder: (_) => const Settings(),
        );
      case live:
        return CupertinoPageRoute(
          builder: (_) => const AdminLivePage(),
        );
      case downloading:
        return CupertinoPageRoute(
          builder: (_) => Downloading(),
        );
      case downloaded:
        return CupertinoPageRoute(
          builder: (_) => const Downloaded(),
        );case savedVideos:
        return CupertinoPageRoute(
          builder: (_) => const SavedVideos(),
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
