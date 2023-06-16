import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mk_tv_app/model/VideoInformation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedModel with ChangeNotifier {
  List<VideoInformation> savedVideos = [];
  bool noSaved = false;

  SavedModel() {
    getSaved();
  }

  Future<void> getSaved() async {
    final getPrefs = await SharedPreferences.getInstance();
    final listOfSavedKeys = getPrefs.getStringList("saved");
    if (listOfSavedKeys == null) {
      noSaved = true;
      notifyListeners();
    } else {
      final databse = FirebaseDatabase.instance;
      listOfSavedKeys.map((element) async {
        final snapshot = await databse.ref("videoinformation/$element").once();

        final videoInfoMap = snapshot.snapshot.value as Map<dynamic, dynamic>?;
        if (videoInfoMap != null) {
          // Convert the map to Map<String, dynamic> using cast()
          final value = videoInfoMap.cast<String, dynamic>();

          // Parse the data from the value map
          final key = value['key'] as String?;
          final videoName = value['videoName'] as String?;
          final thumbnailName = value['thumbnailName'] as String?;
          final title = value['title'] as String?;
          final description = value['description'] as String?;
          final programName = value['programName'] as String?;
          final releaseDateAndTime = value['releaseDateAndTime'] as int?;
          final videoUrl = value['videoUrl'] as String?;
          final thumbnailUrl = value['thumbnailUrl'] as String?;
          final released = value['released'] as bool?;

          // Return the parsed data as a VideoInformation object
          savedVideos.add(VideoInformation(
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
      });
    }
    notifyListeners();
  }
}
