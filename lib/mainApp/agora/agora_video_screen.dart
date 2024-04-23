// ignore_for_file: unnecessary_null_comparison

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../mixins/call_mixin.dart';
import '../../reusable/colors.dart';
import '../model/toggle_call_data_model.dart';
import '../../reusable/call_duration.dart';
import '../controllers/chats_controller.dart';
import '../dashboard_screen.dart';
import '../controllers/agora_video_controller.dart';
import '../../services/awesome_notification_service.dart';

class AgoraVideoScreen extends StatefulWidget {
  const AgoraVideoScreen({super.key, required this.startTimeStamp});
  final Timestamp startTimeStamp;
  @override
  State<AgoraVideoScreen> createState() => _AgoraVideoScreenState();
}

class _AgoraVideoScreenState extends State<AgoraVideoScreen> with CallMixin {
  AgoraVideoController agoraVideoController = Get.put(AgoraVideoController());
  ChatsController chatController = Get.put(ChatsController());
  double bottomMargin = 10.0;
  @override
  void initState() {
    super.initState();

    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelKey: 'channel', channelName: 'Normal Notifications', channelDescription: 'Notification channel for normal notifications', ledColor: Colors.white),
      ],
    );
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) {
        ToggleCallDataModel toggleCallData = ToggleCallDataModel(timestamp: widget.startTimeStamp, isVoiceCall: false);
        return AwesomeNotificationController.onActionReceivedMethod(receivedAction, toggleCallData);
      },
      onNotificationCreatedMethod: (ReceivedNotification receivedNotification) => AwesomeNotificationController.onNotificationCreatedMethod(receivedNotification),
      onNotificationDisplayedMethod: (ReceivedNotification receivedNotification) => AwesomeNotificationController.onNotificationDisplayedMethod(receivedNotification),
      onDismissActionReceivedMethod: (ReceivedAction receivedAction) => AwesomeNotificationController.onDismissActionReceivedMethod(receivedAction),
    );
    joinChannel();
  }

  Future<void> showAwesomeNotification(
    int id,
    String title,
    String body,
    BuildContext context,
  ) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        notificationLayout: NotificationLayout.Default,
        backgroundColor: white,
        channelKey: 'channel',
        wakeUpScreen: true,
        title: title,
        body: body,
        id: id,
      ),
    );
  }

  void joinChannel() async {
    setState(() => agoraVideoController.joinChannel());
  }

  void disconnect() async {
    setState(() => agoraVideoController.leaveChannel());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Row(
            children: [
              ElevatedButton(onPressed: () => joinChannel(), child: const Text('Refresh')),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    openBottomSheet();
                  },
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: agoraVideoController.toggleVideoScreen == true ? localVideo() : _remoteVideo(size),
                  ),
                ),
                Positioned(
                  bottom: bottomMargin,
                  right: 20,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          agoraVideoController.showToggleToSwitchVideos.value = !agoraVideoController.showToggleToSwitchVideos.value;
                        },
                        child: Container(
                          height: 200,
                          width: 150,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: white.withOpacity(0.5), width: 1)),
                          child: agoraVideoController.toggleVideoScreen == true ? _remoteVideo(size) : localVideo(),
                        ),
                      ),
                      Obx(() {
                        return Visibility(
                          visible: agoraVideoController.showToggleToSwitchVideos.value,
                          child: InkWell(
                            onTap: () => setState(() => agoraVideoController.toggleVideoScreen = !agoraVideoController.toggleVideoScreen),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: white,
                              child: Icon(
                                Icons.open_in_browser,
                                color: black,
                                size: 14,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }

  Widget localVideo() {
    return SizedBox(
        width: 520,
        height: 420,
        child: Obx(() => Stack(
              alignment: Alignment.center,
              children: [
                AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: agoraVideoController.engine,
                    canvas: const VideoCanvas(
                      uid: uid,
                      backgroundColor: 3,
                      mirrorMode: VideoMirrorModeType.videoMirrorModeEnabled,
                    ),
                  ),
                  onAgoraVideoViewCreated: (viewId) {
                    if (agoraVideoController.isVideoEnable.value == false) {
                      agoraVideoController.engine.startPreview();
                    } else {
                      agoraVideoController.engine.stopPreview();
                    }
                  },
                ),
                if (agoraVideoController.isVideoEnable.value == true)
                  Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.amber),
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      agoraVideoController.firstWord,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            )));
  }

  void openBottomSheet() {
    setState(() => bottomMargin = 50);
    Timestamp stamp = widget.startTimeStamp;

    DateTime targetDateTime = stamp.toDate();
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          border: Border(
            top: BorderSide(
              color: Colors.white,
              width: 1.0,
            ),
          ),
        ),
        height: 100.0,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.startTimeStamp != null) CallDuration(timeWhenCallStart: targetDateTime) else const Text('Connecting...'),
            Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
              //videoCam
              Obx(() => buildVideoControllButtons(
                    onPressed: () {
                      agoraVideoController.isVideoEnable.value = !agoraVideoController.isVideoEnable.value;
                      if (agoraVideoController.isVideoEnable.value == true) {
                        agoraVideoController.engine.disableVideo();
                      } else {
                        agoraVideoController.engine.enableVideo();
                      }
                    },
                    color: red,
                    icon: agoraVideoController.isVideoEnable.value == true ? Icons.videocam : Icons.videocam_off,
                  )),
              //showMessages or hide VideoScreen
              buildVideoControllButtons(
                onPressed: () {
                  Get.offAll(const DashboardScreen());
                  showAwesomeNotification(0, 'Title', 'On-going video call', context);
                  agoraVideoController.chatsController.showVideoCallScreen.value = false;
                },
                color: green,
                icon: Icons.message,
              ),
              //mic
              GestureDetector(
                onTap: () {
                  agoraVideoController.isAudioEnable.value = !agoraVideoController.isAudioEnable.value;
                },
                child: Obx(() => CircleAvatar(
                      backgroundColor: grey,
                      radius: 25,
                      child: Icon(
                        agoraVideoController.isAudioEnable.value == true ? Icons.mic : Icons.mic_off,
                        color: agoraVideoController.isAudioEnable.value == true ? green : white,
                      ),
                    )),
              ),
              //call_end
              buildVideoControllButtons(
                onPressed: () {
                  agoraVideoController.leaveChannel();
                  Get.back();
                  Get.back();
                },
                color: red,
                icon: Icons.call_end,
              ),
            ]),
          ],
        ),
      ),
      barrierColor: Colors.transparent,
    );
  }

  // Display remote user's video
  Widget _remoteVideo(Size size) {
    return agoraVideoController.remoteUid.isEmpty
        ? Container(
            color: black,
            child: const Center(
                child: Text(
              'Please wait...',
              style: TextStyle(
                color: white,
                fontSize: 20,
              ),
            )),
          )
        : Container(
            color: blue.withOpacity(0.5),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (agoraVideoController.remoteUid.isNotEmpty) ...[
                  Expanded(
                    child: SizedBox(
                      width: size.width / 1.4,
                      height: size.height,
                      child: AgoraVideoView(
                        controller: VideoViewController.remote(
                          rtcEngine: agoraVideoController.engine,
                          canvas: VideoCanvas(
                            backgroundColor: 1,
                            enableAlphaMask: true,
                            sourceType: VideoSourceType.videoSourceCamera,
                            uid: agoraVideoController.remoteUid.first,
                          ),
                          connection: const RtcConnection(channelId: channel),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
  }
}
