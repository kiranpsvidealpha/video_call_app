import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:developer';
import 'package:get/get.dart';

import '../mainApp/agora/agora_audio_screen.dart';
import '../mainApp/agora/agora_video_screen.dart';
import '../mainApp/model/toggle_call_data_model.dart';

class AwesomeNotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {}

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    log('awesome_notification_controller.dart', name: "onNotificationDisplayedMethod--");
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    log('awesome_notification_controller.dart', name: "--onDismissActionReceivedMethod");
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
    ToggleCallDataModel toggleCallData,
  ) async {
    if (toggleCallData.isVoiceCall == false) {
      Get.to(AgoraVideoScreen(startTimeStamp: toggleCallData.timestamp!));
    } else {
      Get.to(AgoraAudioScreen(
        docId: toggleCallData.docId!,
        profileImage: toggleCallData.profileImage!,
      ));
    }
  }
}
