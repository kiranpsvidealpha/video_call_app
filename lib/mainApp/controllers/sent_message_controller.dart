import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../localDb/registration/signIn/sign_in_box.dart';
import '../../services/firebase_helper.dart';
import '../../constants/app_constants.dart';
import '../model/chat_message_model.dart';
import 'chats_controller.dart';
import '../mixins/call_mixin.dart';

class SentMessageController extends GetxController {
  var isSubmitting = false.obs;
  FocusNode focusNode = FocusNode();
  ChatsController controller = Get.put(ChatsController());
  TextEditingController messageController = TextEditingController();
  final String currentUsersPhone = SignInInfoBox.signinInfoBox.fetchSignin?.phoneNumber ?? "";

  void onSubmitMessage() async {
    try {
      String text = messageController.text;
      var isNotBlock = await FirebaseHelper.checkUserBlock(Get.context!);

      if (isNotBlock == true) {
        isSubmitting.value = true;

        ///image
        senMessageToFirebase(text: text);
      }
    } catch (e) {
      log('Exception error:$e');
    }
  }

  void senMessageToFirebase({
    required String text,
  }) {
    try {
      MessagesModel onSubmitMessage = MessagesModel(
        text: text,
        isSentByMe: currentUsersPhone,
        timeMessageSend: Timestamp.now(),
        messageId: CallMixin.messageIdentifier(),
      );

      isSubmitting.value = false;
      messageController.clear();
      FocusScope.of(Get.context!).requestFocus(focusNode);
      controller.updateStream(chatRoomId: AppConstants.chatRoomModel!.chatRoomId);

      controller.cn.chatRooms.doc(AppConstants.chatRoomModel!.chatRoomId).collection('messages').doc(onSubmitMessage.messageId).set(onSubmitMessage.toMap());

      if (text.isNotEmpty) {
        controller.cn.chatRooms.doc(AppConstants.chatRoomModel!.chatRoomId).update({'lastMessage': onSubmitMessage.text, 'chatListTrailingTime': onSubmitMessage.timeMessageSend});
      }

      controller.isTapped.value = 0;
      AppConstants.latitude = '0';
      AppConstants.longitude = '0';
    } catch (e) {
      log('Exception error:$e');
    }
  }
}
