import 'dart:async';
import 'package:agora_token_service/agora_token_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mk_tv_app/model/SettingModel.dart';
import 'package:mk_tv_app/widget/MkDrawer.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:provider/provider.dart';

const String appId = "<agora-app-id-here>";

class Tv extends StatefulWidget {
  const Tv({Key? key}) : super(key: key);

  @override
  _TvState createState() => _TvState();
}

class _TvState extends State<Tv> {
  String channelName = "<channel name here>";
  String token = "";
  String title = "";
  String description = "";

  int uid = 0; // uid of the local user

  bool muted = false;
  double volume = 100;
  bool paused = false;

  int viewers = 0;
  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  // bool _isHost =
  //     true; // Indicates whether the user has joined as a host or audience
  late RtcEngine agoraEngine; // Agora engine instance

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

// Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.lightBlue,
        title: const Row(
          children: [
            Image(
              height: 32,
              image: AssetImage("lib/myassets/mktube.png"),
            ),
            Text("Live"),
          ],
        ),
      ),
      drawer: const MkDrawer(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          // Container for the local video
          AspectRatio(
            aspectRatio: 16 / 9,
            // decoration: BoxDecoration(border: Border.all()),
            child: Center(child: _videoPanel()),
          ),
        ],
      ),
    );
  }

  Widget _videoPanel() {
    return Consumer<SettingModel>(
      builder: (context, value, child) {
        if (value.connectionStatus == ConnectivityResult.none) {
          return const Column(
            children: [
              Padding(padding: EdgeInsets.all(30)),
              Image(
                color: Colors.black,
                image: AssetImage("lib/myassets/mklogo.png"),
                width: 100,
              ),
              Text(
                'No Internet Connection!',
                textAlign: TextAlign.center,
              ),
            ],
          );
        } else if (!_isJoined) {
          return const Column(
            children: [
              Padding(padding: EdgeInsets.all(30)),
              Image(
                image: AssetImage("lib/myassets/mklogo.png"),
                width: 100,
              ),
              Text(
                'Connecting...',
                textAlign: TextAlign.center,
              ),
            ],
          );
        }
        // Show remote video
        else if (_remoteUid != null) {
          return AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: agoraEngine,
              canvas: VideoCanvas(uid: _remoteUid),
              connection: RtcConnection(channelId: channelName),
            ),
          );
        } else {
          return const Column(
            children: [
              Padding(padding: EdgeInsets.all(30)),
              Center(
                  child: Image(
                color: Colors.grey,
                image: AssetImage("lib/myassets/mklogo.png"),
                width: 100,
              )),
              Center(child: Text("No Live!"))
            ],
          );
        }
      },
    );
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
                await agoraEngine.muteRemoteAudioStream(
                    uid: _remoteUid!, mute: muted);
              },
            ),
            title: Slider(
              min: 0,
              max: 400,
              value: volume,
              onChanged: (value) async {
                setState(() {
                  volume = value;
                });
                await agoraEngine.adjustPlaybackSignalVolume(volume.toInt());
              },
            ),
            trailing: IconButton(
              icon: Icon(paused ? Icons.play_arrow : Icons.pause),
              onPressed: () async {
                setState(() {
                  paused = !paused;
                });
                await agoraEngine.muteRemoteVideoStream(
                    uid: _remoteUid!, mute: paused);
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
              title,
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText(
              description,
              textAlign: TextAlign.left,
            ),
          )
        ],
      );
    } else {
      return const LinearProgressIndicator();
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
          showMessage("Stream Started");
          setState(() {
            _isJoined = true;
            final titleAndDesc = FirebaseDatabase.instance.ref("live").get();
            titleAndDesc.then((value) async {
              final mapResult = value.value as Map<Object?, Object?>?;
              final result = mapResult?.cast<String, dynamic>();
              // title = result?["title"];
              // description = result?["description"];
              viewers = result?["viewers"];
              viewers++;
              await FirebaseDatabase.instance
                  .ref("live")
                  .update({"viewers": viewers});
            });
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;

            final titleAndDesc = FirebaseDatabase.instance.ref("live").get();
            titleAndDesc.then((value) {
              final mapResult = value.value as Map<Object?, Object?>?;
              final result = mapResult?.cast<String, dynamic>();

              title = result?["title"];
              description = result?["description"];
              viewers = result?["viewers"];
            });
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
            final titleAndDesc = FirebaseDatabase.instance.ref("live").get();
            titleAndDesc.then((value) async {
              final mapResult = value.value as Map<Object?, Object?>?;
              final result = mapResult?.cast<String, dynamic>();
              // title = result?["title"];
              // description = result?["description"];
              viewers = result?["viewers"];
              viewers--;
              await FirebaseDatabase.instance
                  .ref("live")
                  .update({"viewers": viewers});
            });
          });
        },
      ),
    );

    join();
  }

  void join() async {
    // Set channel options
    ChannelMediaOptions options;

    // Set channel profile and client role

    options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleAudience,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      // Set the latency level
      audienceLatencyLevel:
          AudienceLatencyLevelType.audienceLatencyLevelUltraLowLatency,
    );
    token = getToken();

    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: uid,
    );
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

// Release the resources when you leave
  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    agoraEngine.release();
    super.dispose();
  }

  String getToken() {
    String appId = "<agora-app-id-here>";
    String appCertificate = "<agora app certificate here>";
    String channelName = "<channel name>";
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
        role: RtcRole.subscriber,
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
