import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../services/firebase_helper.dart';
import '../../../constants/text_constants.dart';
import '../chatScreen/chat_widgets.dart';
import '../../../reusable/style.dart';
import '../mixins/call_mixin.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/navigator.dart';
import '../agora/agora_video_screen.dart';
import 'chatting_user_profile_widgets.dart';
import '../../../reusable/sized_box_hw.dart';
import '../controllers/chats_controller.dart';
import '../../../constants/app_constants.dart';
import '../../../localDb/registration/signIn/sign_in_box.dart';

class ChattingUserProfile extends StatefulWidget {
  const ChattingUserProfile({super.key});

  @override
  State<ChattingUserProfile> createState() => _ChattingUserProfileState();
}

class _ChattingUserProfileState extends State<ChattingUserProfile> with CallMixin {
  final ChatsController controller = Get.find<ChatsController>();
  final String currentUsersPhone = SignInInfoBox.signinInfoBox.fetchSignin?.phoneNumber ?? "";
  String connectingId = '';
  @override
  void initState() {
    super.initState();
    checkUserIsBlock();
  }

  void checkUserIsBlock() async {
    controller.isBlockContact.value = await FirebaseHelper.checkUserBlock(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        centerTitle: true,
        title: const Text('Profile', style: TextStyle(color: white)),
        leading: IconButton(
          onPressed: () => removeScreen(context),
          icon: const Icon(Icons.arrow_back_ios, color: white),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ReusableIconContainer(
                icon: Icons.video_call,
                onTap: controller.isAudioCalling.value == false
                    ? () async {
                        startVideoCall(context);
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx > 0) {
            Get.back();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
          child: ListView(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(controller.currentChatDetails!.profileImage),
              ),
              sh25,
              Align(
                alignment: Alignment.center,
                child: Text(
                  controller.currentChatDetails!.name,
                  style: tStyleBold18,
                ),
              ),
              sh10,
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: size.width * 0.3,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, color: controller.currentChatDetails!.status == TextConstants.active ? green : red, size: 12),
                    sw12,
                    Expanded(child: Text(controller.currentChatDetails!.status, style: tStyleFont13.copyWith(color: white)))
                  ],
                ),
              ),
              sh10,
              const Divider(thickness: 1.5, color: greyLight),
              sh20,
              ContactInfoTile(width: size.width, label: 'Email', infoText: controller.currentChatDetails!.email),
              sh20,
              ContactInfoTile(width: size.width, label: 'Mobile Number', infoText: controller.currentChatDetails!.phoneNumber),
              sh20,
              ContactInfoTile(width: size.width, label: 'Location', infoText: 'India'),
              sh10,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> startVideoCall(BuildContext context) async {
    controller.showVideoCallScreen.value = true;
    controller.isRingingCall.value = true;
    controller.isVideoCall.value = true;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd_HH:mm:ss').format(now);
    callScreenController.docId.value = '${AppConstants.chatRoomModel!.chatRoomId}_$formattedDate';
    callScreenController.videoCallConnectingId.value = AppConstants.chatRoomModel!.chatRoomId;
    AppConstants.profileImageToVideoCall.value = AppConstants.profileImageToChat.value;
    AppConstants.nameToVideoCall.value = AppConstants.userNameToChat.value;
    AppConstants.docIdToVideoCall = '${AppConstants.chatRoomModel!.chatRoomId}_$formattedDate';
    await controller.cn.callHistory.doc(callScreenController.docId.value).set({
      'caller': currentUsersPhone,
      'callId': AppConstants.chatRoomModel!.chatRoomId,
      'timestamp': FieldValue.serverTimestamp(),
      'callee': '${AppConstants.userNameToChat}',
      'callOff': false,
      'connectingId': '',
      'startTime': null,
      'received': false,
      'callType': 'V',
      'endTime': null
    }).then((value) {
      Get.off(AgoraVideoScreen(
        startTimeStamp: Timestamp.now(),
      ));
    });
  }
}
