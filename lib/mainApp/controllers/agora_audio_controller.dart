import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chats_controller.dart';
import 'agora_video_controller.dart';

class AgoraAudioController extends GetxController {
  Set<int> remoteUid = {};
  bool muted = false;
  RxBool mute = false.obs;
  RxBool isSpeakerOn = false.obs;
  late final RtcEngine engine;
  late final RtcEngineEventHandler rtcEngineEventHandler;
  ChatsController chatsController = Get.find<ChatsController>();
  ConnectionState connectionState = ConnectionState.none;
  ChannelProfileType channelProfileType = ChannelProfileType.channelProfileLiveBroadcasting;
  @override
  void onInit() {
    super.onInit();
    initEngine();
  }

  @override
  void onClose() {
    _dispose();
    super.onClose();
  }

  Future<void> _dispose() async {
    engine.unregisterEventHandler(rtcEngineEventHandler);
    await engine.leaveChannel();
    await engine.release();
  }

  Future<void> leaveAudioChannel() async {
    chatsController.isRingingCall.value = false;
    chatsController.showVideoCallScreen.value = false;
    chatsController.isVideoCall.value = false;
    chatsController.isOnGoingCall.value = false;
    await engine.leaveChannel();
    await engine.disableVideo();
  }

  Future<void> joinAudioChannel() async {
    await engine.joinChannel(
        uid: uid,
        token: token,
        channelId: channel,
        options: ChannelMediaOptions(
          channelProfile: channelProfileType,
          autoSubscribeAudio: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ));
  }

  Future<void> initEngine() async {
    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(appId: appId));

    rtcEngineEventHandler = RtcEngineEventHandler(
      onError: (ErrorCodeType err, String msg) {
         log('[onError] err: $err, msg: $msg'); 
      },
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
         log('[onJoinChannelSuccess] connection: ${connection.toJson()} elapsed: $elapsed');
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        log('[onLeaveChannel] connection: ${connection.toJson()} stats: ${stats.toJson()}');
      },
    );

    engine.registerEventHandler(rtcEngineEventHandler);

    await engine.enableAudio();
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioGameStreaming,
    );
  }



  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
    // engine.muteLocalAudioStream(!isSpeakerOn);
    engine.setDefaultAudioRouteToSpeakerphone(isSpeakerOn.value);
  }
}
