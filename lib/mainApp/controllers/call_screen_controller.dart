import 'dart:developer';

import 'package:get/get.dart';

import 'chats_controller.dart';
import '../model/user_call_model.dart';
import '../../constants/app_constants.dart';
import '../../constants/text_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CallScreenController extends GetxController {
  String callRoomId = '';
  RxString docId = ''.obs;
  bool _dialogShown = false;
  RxBool? isCalling = false.obs;
  RxString callInfoName = ''.obs;
  RxInt? currentTappedChat = 0.obs;
  RxBool videoCallComing = false.obs;
  RxString userNumberToCall = ''.obs;
  RxString userRoomIdToCall = ''.obs;
  RxList callInfoUserHistory = [].obs;
  bool get dialogShown => _dialogShown;
  RxString videoCallConnectingId = ''.obs;
  List<CallHistoryModel> filteredCallHistory = [];
  List<QueryDocumentSnapshot<Object?>> filteredDocuments = [];
  RxString callInfoProfilePic = AppConstants.firstProfilePic.obs;
  ChatsController chatsController = Get.put(ChatsController());
  void showDialog() {
    _dialogShown = true;
    update();
  }

  void hideDialog() {
    _dialogShown = false;
    update();
  }

// Define a function to calculate the call duration.
  Duration calculateCallDuration(Timestamp startTime, Timestamp endTime) {
    final start = startTime.toDate();
    final end = endTime.toDate();
    return end.difference(start);
  }

  String formatCallDuration(Timestamp startTime, Timestamp endTime) {
    final duration = calculateCallDuration(startTime, endTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours == 0) {
      return '$minutes minutes $seconds seconds';
    } else {
      return '$hours ${TextConstants.hours} $minutes ${TextConstants.minutes} $seconds ${TextConstants.seconds}';
    }
  }

  Future<void> generateVoiceRoomId(String docId) async {
    log('from generatingVoiceRoomId: docId is $docId, and callRoomId is $callRoomId');
    // await chatsController.cn.callHistory.doc(docId).update({'connectingId': callRoomId});
  }
}
