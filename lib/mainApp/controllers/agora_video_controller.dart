import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'chats_controller.dart';

const uid = 0;
const channel = "flutterapp";
const appId = "457eb0eb2e214598850033594e5dbd32";
const appCertificate = "64b67559934e4a27954e5722e964ce51";
String token = "007eJxTYKhRuLlwspfJ34WJGa0mVV5l6qqMLbMTwifZHupa9fiVjIMCg4mpeWqSQWqSUaqRoYmppYWFqYGBsbGppUmqaUpSirHRjE71tIZARoZ9/IuZGBkgEMTnYkjLKS0pSS1KLChgYAAAkAMgHA==";

class AgoraVideoController extends GetxController {
  ChatsController chatsController = Get.find<ChatsController>();
  late final RtcEngineEventHandler rtcEngineEventHandler;
  RxBool showToggleToSwitchVideos = false.obs;
  RxBool isAudioEnable = false.obs;
  RxBool isVideoEnable = false.obs;
  bool toggleVideoScreen = false;
  RxBool isCallEnded = false.obs;
  String firstWord = 'first-word';
  late final RtcEngine engine;
  Set<int> remoteUid = {};

  @override
  void onInit() {
    super.onInit();
    firstWord = 'AA';
    initEngine();
  }

  void getTokenDetails() async {
    try {
      DocumentSnapshot userData = await chatsController.cn.staticConstants.doc('agora').get();
      if (userData.exists) {
        log('refreshedAt: ${userData['refreshedAt']}');
        token = userData['token'];
        log('renew token: $token');
      } else {
        log('Document does not exist');
      }
    } catch (e) {
      log('Error fetching data: $e');
    }
  }

  @override
  void onClose() {
    _dispose();
    super.onClose();
  }

  Future<void> _dispose() async {
    await engine.leaveChannel();
    await engine.release();
  }

  Future<void> leaveChannel() async {
    chatsController.isRingingCall.value = false;
    chatsController.showVideoCallScreen.value = false;
    chatsController.isVideoCall.value = false;
    chatsController.isOnGoingCall.value = false;
    await engine.leaveChannel();
    await engine.disableVideo();
  }

  Future<void> joinChannel() async {
    getTokenDetails();
    await engine.joinChannel(
      uid: uid,
      token: token,
      channelId: channel,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> initEngine() async {
    await [Permission.microphone, Permission.camera].request();
    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(appId: appId));
    rtcEngineEventHandler = RtcEngineEventHandler(
      onError: (ErrorCodeType err, String msg) {
        log('[onError] err: $err, msg: $msg');
      },
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        log('[onJoinChannelSuccess] connection: ${connection.toJson()} elapsed: $elapsed');
      },
      onUserJoined: (RtcConnection connection, int rUid, int elapsed) {
        log('[onUserJoined] connection: ${connection.toJson()} remoteUid: $rUid elapsed: $elapsed');
        remoteUid.add(rUid);
      },
      onUserOffline: (RtcConnection connection, int rUid, UserOfflineReasonType reason) {
        log('[onUserOffline] connection: ${connection.toJson()}  rUid: $rUid reason: $reason');
        remoteUid.removeWhere((element) => element == rUid);
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        log('[onLeaveChannel] connection: ${connection.toJson()} stats: ${stats.toJson()}');
        remoteUid.clear();
      },
    );

    engine.registerEventHandler(rtcEngineEventHandler);
    await engine.enableVideo();
    await engine.startPreview();
  }

  void onSwitchCamera() {
    engine.switchCamera();
  }
}
