class VideoInformation {
  String? key;
  String? title;
  String? description;
  String? programName;
  String? videoName;
  String? thumbnailName;
  DateTime? releaseDate;
  String? thumbnailUrl;
  String? videoUrl;
  bool? released;

  VideoInformation(
      {required this.key,
      required this.title,
      required this.description,
      required this.programName,
      required this.videoName,
      required this.thumbnailName,
      required this.releaseDate,
      this.thumbnailUrl = "",
      this.videoUrl = "",
      this.released = false});

  VideoInformation.fromMap(Map<String, dynamic> videoInfo) {
    key = videoInfo['key'] as String;
    title = videoInfo['title'] as String;
    description = videoInfo['description'] as String;
    programName = videoInfo['programName'] as String;
    videoName = videoInfo['videoName'] as String;
    thumbnailName = videoInfo['thumbnailName'] as String;
    releaseDate =
        DateTime.fromMillisecondsSinceEpoch(videoInfo['releaseDate'] as int);
    thumbnailUrl = videoInfo['thumbnailUrl'] as String;
    videoUrl = videoInfo['videoUrl'] as String;
    released = videoInfo['released'] as bool;
  }
}
