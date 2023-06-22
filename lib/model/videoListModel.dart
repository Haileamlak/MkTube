import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:mk_tv_app/model/VideoInformation.dart';
// import 'package:http/http.dart';

class VideoListModel with ChangeNotifier {
  final database = FirebaseDatabase.instance;
  final storage = FirebaseStorage.instance;
  List<VideoInformation?> listOfVideos = [];

  int currentIndex = 0;
  // Map<int, Future<Response>> downloading = {};
  // late final videosStream;

  VideoListModel() {
    getListOfVideos();
  }

  bool isQueryInText({required String text, required String query}) {
    final queryArray = query.split(" ");
    for (var singlequery in queryArray) {
      if (text.contains(singlequery)) {
        return true;
      }
    }
    return false;
  }

  Future<void> getListOfVideos({String query = "", String? startAfter}) async {
    DatabaseEvent dataSnapshot;
    if (startAfter != null) {
      dataSnapshot = await database
          .ref("videoinformation")
          .startAfter(listOfVideos.last, key: startAfter)
          .orderByKey()
          .once();
    } else {
      dataSnapshot = await database.ref("videoinformation").orderByKey().once();
    }
    final videoInfoMap = dataSnapshot.snapshot.value as Map<dynamic, dynamic>?;
    if (videoInfoMap != null) {
      for (var entry in videoInfoMap.entries) {
        final key = entry.key as String;
        final valueAsMapObject = entry.value as Map<Object?, Object?>?;

        // Convert the map to Map<String, dynamic> using cast()
        final value = valueAsMapObject?.cast<String, dynamic>();
        // Check if the 'released' attribute is true

        if (query.isEmpty ||
            isQueryInText(text: value?['title'], query: query) ||
            isQueryInText(text: value?['description'], query: query)) {
          // return VideoInformation.fromMap(value!);

          // Parse the data from the value map
          final videoName = value?['videoName'] as String?;
          final thumbnailName = value?['thumbnailName'] as String?;
          final title = value?['title'] as String?;
          final description = value?['description'] as String?;
          final programName = value?['programName'] as String?;
          final releaseDateAndTime = value?['releaseDateAndTime'] as int?;
          final videoUrl = value?['videoUrl'] as String?;
          final thumbnailUrl = value?['thumbnailUrl'] as String?;
          final released = value?['released'] as bool?;

          // Return the parsed data as a VideoInformation object
          listOfVideos.add(VideoInformation(
            key: key,
            videoName: videoName,
            thumbnailName: thumbnailName,
            title: title,
            description: description,
            programName: programName,
            releaseDate: DateTime.fromMillisecondsSinceEpoch(
                releaseDateAndTime ?? DateTime.now().millisecondsSinceEpoch),
            videoUrl: videoUrl,
            thumbnailUrl: thumbnailUrl,
            released: released,
          ));
        }
      }
      // listOfVideos.length;
      // Use the videoInfoList for further processing
    } else {
      // listOfVideos.length--;
    }

    notifyListeners();
  }
}
