import 'dart:async';
import 'dart:developer';

import 'package:agora_token_service/agora_token_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../mixins/call_mixin.dart';
import '../../reusable/colors.dart';
import '../../reusable/call_duration.dart';
import '../model/toggle_call_data_model.dart';
import '../../reusable/firebase_streams.dart';
import '../dashboard_screen.dart';
import '../controllers/agora_audio_controller.dart';
import '../controllers/agora_video_controller.dart';
import '../../services/awesome_notification_service.dart';

class AgoraAudioScreen extends StatefulWidget {
  const AgoraAudioScreen({super.key, required this.docId, required this.profileImage});
  final String docId;
  final String profileImage;
  @override
  State<AgoraAudioScreen> createState() => _AgoraAudioScreenState();
}

class _AgoraAudioScreenState extends State<AgoraAudioScreen> with CallMixin {
  AgoraAudioController agoraAudioController = Get.put(AgoraAudioController());
  late StreamController<Duration> timerController;
  DateTime currentTime = DateTime.now();
  late Stream<Duration> timerStream;
  late Duration remainingTime;
  late Timer updateTimer;
  bool startTimer = false;

  @override
  void dispose() {
    updateTimer.cancel();
    timerController.close();
    super.dispose();
  }

  void tokenGeneration() {
    const role = RtcRole.publisher;

    const expirationInSeconds = 3600;
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expireTimestamp = currentTimestamp + expirationInSeconds;

    final generateToken = RtcTokenBuilder.build(
      appId: appId,
      appCertificate: appCertificate,
      channelName: channel,
      uid: uid.toString(),
      role: role,
      expireTimestamp: expireTimestamp,
    );
    log('generatedToken: $generateToken');
    token = generateToken;
    log('here is token : $token');
  }

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
        ToggleCallDataModel toggleCallData = ToggleCallDataModel(docId: widget.docId, isVoiceCall: true, profileImage: widget.profileImage);
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
    setState(() => agoraAudioController.joinAudioChannel());
  }

  void disconnect() async {
    setState(() => agoraAudioController.leaveAudioChannel());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: black,
        body: StreamBuilder(
          stream: callingDialogBoxStream(widget.docId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final specificDocData = snapshot.data!.data() as Map<String, dynamic>;
            if (specificDocData['callOff'] == true) {
              Navigator.of(context).pop();
            }
            Timestamp stamp = specificDocData['startTime'];
            DateTime targetDateTime = stamp.toDate();
            return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Row(
                children: [
                  ElevatedButton(onPressed: () => joinChannel(), child: const Text('Refresh')),
                ],
              ),
              const Divider(),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: green,
                ),
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: NetworkImage(widget.profileImage),
                ),
              ),
              specificDocData['startTime'] != null
                  ? CallDuration(
                      timeWhenCallStart: targetDateTime,
                    )
                  : const Text('Connecting...'),
              const Spacer(
                flex: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildVideoControllButtons(
                    onPressed: () {
                      Get.offAll(const DashboardScreen());
                      showAwesomeNotification(0, 'Title', 'On-going audio call', context);
                    },
                    color: green,
                    icon: Icons.message,
                  ),
                  Obx(() => buildVideoControllButtons(
                        onPressed: () {
                          agoraAudioController.mute.value = !agoraAudioController.mute.value;
                          agoraAudioController.engine.muteLocalAudioStream(agoraAudioController.mute.value);
                        },
                        color: red,
                        icon: agoraAudioController.mute.value == false ? Icons.mic : Icons.mic_off,
                      )),
                  Obx(() => buildVideoControllButtons(
                        onPressed: () {
                          agoraAudioController.toggleSpeaker();
                        },
                        color: blue,
                        icon: agoraAudioController.isSpeakerOn.value == true ? Icons.volume_up : Icons.headphones,
                      )),
                ],
              ),
              const Spacer(),
              buildVideoControllButtons(
                onPressed: () async {
                  agoraAudioController.leaveAudioChannel();
                  await chatsController.cn.callHistory.doc(widget.docId).update({'callOff': true, 'endTime': Timestamp.now()}).then((value) {
                    Navigator.pop(context);
                  });
                },
                color: red,
                icon: Icons.call_end,
              ),
              const Spacer(),
            ]);
          },
        ),
      ),
    );
  }
}
