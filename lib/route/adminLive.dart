import 'dart:async';
import 'package:agora_token_service/agora_token_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

const String appId = "<Agora-app-ID-here>";

class AdminLivePage extends StatefulWidget {
  const AdminLivePage({Key? key}) : super(key: key);

  @override
  _AdminLivePageState createState() => _AdminLivePageState();
}

class _AdminLivePageState extends State<AdminLivePage> {
  String channelName = "<channel-name-here>";
  String token = "";

  int uid = 0; // uid of the local user
  int? _remoteUid;
  int _viewers = 0; // uid of the remote user

  double volume = 50;
  bool muted = false;
  bool paused = false;

  bool _isJoined = false; // Indicates if the local user has joined the channel
  final bool _isHost =
      true; // Indicates whether the user has joined as a host or audience
  late RtcEngine agoraEngine; // Agora engine instance

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

// Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get started with Broadcast Streaming'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          Stack(
            children: [
              SizedBox(
                height: 250,
                child: Center(child: _videoPanel()),
              ),
              // Positioned(textDirection:, child: child)
              // if (_isJoined)
              //   Wrap(
              //     children: [
              //       const Icon(
              //         Icons.remove_red_eye,
              //         color: Colors.red,
              //       ),
              //       Text(" $_viewers")
              //     ],
              //   ),
            ],
          ),
          titleAndDescription(),
          ElevatedButton(
            child: _isJoined
                ? const Text(
                    "Finish",
                    style: TextStyle(color: Colors.red),
                  )
                : const Text(
                    "Go Live",
                    style: TextStyle(color: Colors.green),
                  ),
            onPressed: () => {_isJoined ? leave() : join()},
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _videoPanel() {
    if (!_isJoined) {
      return const Column(
        children: [
          Image(
            image: AssetImage(
              "lib/myassets/mklogo.png",
            ),
            width: 128,
          ),
          Text(
            'Start Streaming',
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      // Show local video preview
      return AgoraVideoView(
          controller: VideoViewController(
        rtcEngine: agoraEngine,
        canvas: const VideoCanvas(uid: 0),
      ));
    }
  }

  Widget titleAndDescription() {
    if (_isJoined) {
      return Column(
        children: [
          ListTile(
            leading: IconButton(
              icon: Icon(muted ? Icons.volume_off : Icons.volume_up),
              onPressed: () async {
                setState(() {
                  muted = !muted;
                });
                await agoraEngine.muteLocalAudioStream(!muted);
              },
            ),
            title: Slider(
              min: 0,
              max: 100,
              value: volume,
              onChanged: (value) async {
                setState(() {
                  volume = value;
                });
                await agoraEngine.adjustRecordingSignalVolume(volume.toInt());
              },
            ),
            trailing: IconButton(
              icon: Icon(paused ? Icons.pause : Icons.play_arrow),
              onPressed: () async {
                setState(() {
                  paused = !paused;
                });
                if (paused) {
                  await agoraEngine.startPreview();
                  await agoraEngine.muteLocalVideoStream(paused);
                } else {
                  await agoraEngine.stopPreview();
                  await agoraEngine.muteLocalVideoStream(paused);
                }
              },
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: SelectableText(
          //     "$_viewers watching",
          //     textAlign: TextAlign.left,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText(
              titleController.text,
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText(
              descController.text,
              textAlign: TextAlign.left,
            ),
          )
        ],
      );
    } else {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  label: Text("Title")),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: descController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  label: Text("Description")),
            ),
          ),
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Set up an instance of Agora engine
    setupVideoSDKEngine();
  }

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: appId));

    await agoraEngine.enableVideo();
    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Stream Started!")));
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
  }

  void join() async {
    // Set channel options
    ChannelMediaOptions options;

    // Set channel profile and client role

    options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );
    await agoraEngine.startPreview();

    token = getToken();

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: uid,
    );
    await agoraEngine
        .setVideoEncoderConfiguration(const VideoEncoderConfiguration(
      orientationMode: OrientationMode.orientationModeAdaptive,
    ));
    await agoraEngine.switchCamera();

    if (titleController.text == "") {
      titleController.text = "Mahibere Kidusan Tv Live";
    }
    await FirebaseDatabase.instance.ref("live").set({
      "title": titleController.text,
      "description": descController.text,
      "viewers": 0
    });
  }

  void leave() async {
    setState(() {
      _isJoined = false;
      _viewers = 0;
    });
    agoraEngine.leaveChannel();
    await FirebaseDatabase.instance
        .ref("live")
        .set({"title": "", "description": "", "viewers": 0});
  }

// Release the resources when you leave
  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    await FirebaseDatabase.instance
        .ref("live")
        .set({"title": "", "description": "", "viewers": 0});
    agoraEngine.release();
    super.dispose();
  }

  String getToken() {
    String appId = "<agora-app-id-here>";
    String appCertificate = "<agora-app-certificate-here>";
    String channelName = "<channel name here>";
    int uid = 0; // The integer uid, required for an RTC token
    int expirationTimeInSeconds =
        3600; // The time after which the token expires

    // Calculate the time expiry timestamp
    int timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) +
        expirationTimeInSeconds;

    String result = RtcTokenBuilder.build(
        appId: appId,
        appCertificate: appCertificate,
        channelName: channelName,
        uid: uid.toString(),
        role: RtcRole.publisher,
        expireTimestamp: timestamp);
    print(result);
    return result;
  }

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
