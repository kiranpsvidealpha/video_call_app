import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../reusable/colors.dart';
import '../../../reusable/style.dart';
import '../../../constants/app_constants.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../agora/agora_video_screen.dart';
import '../../agora/agora_audio_screen.dart';
import '../../../reusable/firebase_streams.dart';
import '../../controllers/chats_controller.dart';
import '../../controllers/call_screen_controller.dart';
import '../../../localDb/registration/signIn/sign_in_box.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class CallingDialogbox extends StatefulWidget {
  final Color color;
  final String title;
  final String docId;
  final bool isCalling;
  final String subTitle;
  final String ringingMusic;
  final String profileImage;
  final bool showBackgroundImage;
  final String callingStatusText;

  const CallingDialogbox({
    super.key,
    required this.title,
    required this.color,
    required this.docId,
    required this.subTitle,
    required this.isCalling,
    required this.ringingMusic,
    required this.profileImage,
    required this.callingStatusText,
    required this.showBackgroundImage,
  });

  @override
  State<CallingDialogbox> createState() => _CallingDialogboxState();
}

class _CallingDialogboxState extends State<CallingDialogbox> {
  String? roomId;
  ChatsController chatsController = Get.put(ChatsController());
  TextEditingController textEditingController = TextEditingController(text: '');
  CallScreenController controller = Get.put(CallScreenController());
  final String currentUsersPhone = SignInInfoBox.signinInfoBox.fetchSignin?.phoneNumber ?? "";

  late AudioPlayer audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.onPlayerComplete.listen((event) {
      playMusic();
    });
    playMusic();
  }

  void playMusic() async {
    await audioPlayer.play(AssetSource(widget.ringingMusic));
  }

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> showAwesomeNotification(
    int id,
    String title,
    String body,
    BuildContext context,
  ) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'channel',
        title: title,
        body: body,
        wakeUpScreen: true,
        backgroundColor: white,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder(
          stream: callingDialogBoxStream(widget.docId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final specificDocData = snapshot.data!.data() as Map<String, dynamic>;
            bool received = specificDocData['received'];
            if (specificDocData['callOff'] == true) {
              chatsController.isRingingCall.value = false;
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.of(context).pop();
              });
            } else if (received == true) {
              Future.delayed(const Duration(seconds: 1), () {
                if (specificDocData['callType'] == 'A') {
                  Get.off(AgoraAudioScreen(
                    docId: widget.docId,
                    profileImage: widget.profileImage,
                  ));
                } else {
                  Get.off(AgoraVideoScreen(startTimeStamp: Timestamp.now()));
                }
                audioPlayer.stop();
              });
            }
            return SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: black, image: widget.showBackgroundImage == true ? DecorationImage(image: NetworkImage(widget.profileImage), fit: BoxFit.cover) : null),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.color,
                          ),
                          child: CircleAvatar(
                            radius: 80,
                            backgroundImage: NetworkImage(widget.profileImage),
                          ),
                        ),
                        sh20,
                        Text(widget.title, style: tStyleBold18.copyWith(color: white)),
                        sh7,
                        Text(widget.callingStatusText, style: tStyle16.copyWith(color: amber)),
                      ]),
                    ),
                  ),
                  Positioned(
                    bottom: 55,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => callEnd(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                backgroundColor: red,
                                radius: 25,
                                child: Icon(Icons.call_end, color: white),
                              ),
                              Text('Reject', style: tStyle16.copyWith(color: white)),
                            ],
                          ),
                        ),
                        sw20,
                        GestureDetector(
                          onTap: () {
                            showAwesomeNotification(0, specificDocData['callee'], 'OnGoing call', context);
                            // Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(horizontal: 25),
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: white, width: 1)),
                            child: const Icon(Icons.message, color: white),
                          ),
                        ),
                        sw20,
                        if (specificDocData['caller'] != currentUsersPhone && received == false && specificDocData['callType'] == 'A')
                          GestureDetector(
                            onTap: () async {
                              await chatsController.cn.callHistory.doc(widget.docId).update({'received': true, 'startTime': Timestamp.now()});
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: green.shade900,
                                  radius: 25,
                                  child: const Icon(Icons.call, color: white),
                                ),
                                Text('Receive', style: tStyle16.copyWith(color: white)),
                              ],
                            ),
                          ),
                        if (specificDocData['callType'] == 'V')
                          GestureDetector(
                            onTap: () async => receiveVideoCall(context, specificDocData['callId']),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: green.shade400,
                                  radius: 25,
                                  child: const Icon(
                                    Icons.video_camera_back_rounded,
                                    color: white,
                                  ),
                                ),
                                Text('Receive', style: tStyle16.copyWith(color: white)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> receiveVideoCall(BuildContext context, String callId) async {
    controller.videoCallConnectingId.value = callId;
    controller.docId.value = widget.docId;
    controller.videoCallComing.value = true;
    chatsController.isOnGoingCall.value = true;
    AppConstants.docIdToVideoCall = widget.docId;
    chatsController.showVideoCallScreen.value = true;
    const Duration(seconds: 1);
    await chatsController.cn.callHistory.doc(widget.docId).update({'received': true, 'startTime': Timestamp.now()});
  }

  Future<void> callEnd() async {
    Get.back();
    chatsController.isAudioCalling.value = false;
    chatsController.isOnGoingCall.value = false;
    chatsController.isRingingCall.value = false;
    await chatsController.cn.callHistory.doc(widget.docId).update({'callOff': true, 'endTime': Timestamp.now()});
  }
}
