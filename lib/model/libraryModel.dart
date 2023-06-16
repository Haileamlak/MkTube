import 'dart:convert';
import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:mk_tv_app/model/VideoInformation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryModel with ChangeNotifier {
  final storage = FirebaseStorage.instance;
  List<VideoInformation> downloading = [];
  List<DownloadTask> downloadProgresses = [];
  List<Map<String, dynamic>> downloaded = [];
  bool noDownloads = false;

  LibraryModel() {
    getDownloads();
  }

  void notify() {
    notifyListeners();
  }

  Future<void> getDownloads() async {
    String downloadListKey = "downloads";
    SharedPreferences getprefs = await SharedPreferences.getInstance();
    List<String>? listofKeys = getprefs.getStringList(downloadListKey);
    if (listofKeys != null) {
      for (var i in listofKeys) {
        String? videoInfoMap = getprefs.getString(i);
        if (videoInfoMap != null) {
          downloaded.add(json.decode(videoInfoMap));
        }
      }
      if (downloaded.isEmpty) {
        noDownloads = true;
      }
    } else {
      noDownloads = true;
    }
    notifyListeners();
  }

  Future<bool> cancelDownload(int index) async {
    downloading.removeAt(index);
    try {
      if (downloadProgresses.length > index) {
        await downloadProgresses[index].cancel();

        downloadProgresses.removeAt(index);

        notifyListeners();
        return true;
      } else {
        debugPrint("no delete");
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return false;
  }

  Future<void> download({required VideoInformation videoInfo}) async {
    downloading.add(videoInfo);
    int index = downloading.length - 1;
    await downloadVideo(index);
    switch (downloadProgresses[index].snapshot.state) {
      case TaskState.paused:
        // TODO: Handle this case.
        break;
      case TaskState.running:
        // TODO: Handle this case.
        break;
      case TaskState.success:
        {
          await onDownloadSuccess(index);

          downloadProgresses.removeAt(index);
          downloading.removeAt(index);
        }
        break;
      case TaskState.canceled:
      case TaskState.error:
        {
          downloadProgresses.removeAt(index);
          downloading.removeAt(index);
        }
        break;
    }
    notifyListeners();
  }

  Future<File> downloadVideo(int index) async {
    String fileName = downloading[index].title!;

    var filePath = await _createFile(fileName);
    var file = File(filePath);

    try {
      final downloadTask =
          storage.refFromURL(downloading[index].videoUrl!).writeToFile(file);

      downloadProgresses.add(downloadTask);
      notifyListeners();

      downloadTask.then((p0) {
        notifyListeners();
      });
    } on Exception catch (e) {
      debugPrint(e.toString());
      notifyListeners();
    }
    return file;
  }

  Future<void> onDownloadSuccess(int index) async {
    String downloadListKey = "downloads";
    String mapKey = downloading[index].key!;

    SharedPreferences getprefs = await SharedPreferences.getInstance();
    List<String>? listOfKeys = getprefs.getStringList(downloadListKey);
    // List<int>? loadedMap;

    if (listOfKeys != null) {
      listOfKeys.add(mapKey);
    } else {
      listOfKeys = [mapKey];
    }

// Define a map to store
    Map<String, dynamic> myMap = {
      'videoName': downloading[index].videoName ?? "",
      'title': downloading[index].title ?? "NoTitle",
      "description": downloading[index].description ?? "",
      "programName": downloading[index].programName ?? "",
      'releaseDateAndTime': downloading[index].releaseDate ?? "",
    };

// Save the map to shared_preferences
    final isDownloaded = await getprefs.setString(mapKey, json.encode(myMap));
    if (isDownloaded) await getprefs.setStringList(downloadListKey, listOfKeys);
  }

  Future<String> _createFile(String fileName) async {
    await [Permission.manageExternalStorage].request();
    String filePath = "";

    try {
      if (Platform.isAndroid) {
        String? apDownloadsPath = await AndroidPathProvider.downloadsPath;
        filePath = '$apDownloadsPath/$fileName';
      } else if (Platform.isIOS) {
        String? apDownloadsPath = (await getDownloadsDirectory())?.path;
        filePath = '$apDownloadsPath/$fileName';
      }
    } on Exception {
      print("Could not find Downloads directory!");
    }

    return filePath;
  }

  @override
  void dispose() {
    while (downloadProgresses.isNotEmpty) {
      downloadProgresses.last.ignore();
      downloadProgresses.removeLast();
    }
    super.dispose();
  }
}
